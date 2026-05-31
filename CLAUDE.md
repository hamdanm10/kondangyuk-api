# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
All rules in this file are **mandatory and must be followed without exception**.

---

## Stack

- **Ruby 4.0.5**, **Rails 8.1.3** (API-only — no views, helpers, or asset pipeline)
- **PostgreSQL** — development database is `kondangyuk_api_development`, username `hamdan`
- No Redis: caching, background jobs, and Action Cable all use DB-backed Solid adapters (Solid Cache, Solid Queue, Solid Cable)

---

## Commands

```bash
bin/setup          # Install gems and prepare databases
bin/dev            # Start the Rails server
bin/rails console  # Open a Rails console
bin/rails db:migrate
bin/rails db:schema:load  # Faster than running all migrations on fresh DBs
```

### Linting and security (the full CI suite)

```bash
bin/ci             # Runs setup → rubocop → bundler-audit → brakeman
bin/rubocop        # Ruby style (rubocop-rails-omakase)
bin/brakeman --quiet --no-pager  # Static security analysis
bin/bundler-audit  # Check gems for known CVEs
```

### Testing and API documentation

```bash
bundle exec rspec spec/requests/                        # Run all request specs
bundle exec rspec spec/requests/api/v1/users_spec.rb   # Run specific spec file

# Generate swagger.yaml from specs (always run after editing specs)
SWAGGER_DRY_RUN=0 bundle exec rspec spec/requests/ \
  --format Rswag::Specs::SwaggerFormatter --order defined
```

Swagger UI tersedia di `/api-docs` setelah server dijalankan.

> `rails/test_unit/railtie` is intentionally commented out — the project uses RSpec instead.

---

## Architecture & Folder Structure

```
app/
├── controllers/
│   └── api/
│       └── v1/          # All controllers live here, namespaced under Api::V1
├── views/
│   └── api/
│       └── v1/          # JBuilder files mirror the controller structure
├── services/            # All business logic
│   └── base_service.rb
├── repositories/        # All database queries
│   └── base_repository.rb
├── models/              # Validations, associations, and model-level callbacks only
└── jobs/                # Background jobs (Solid Queue)
```

### Layer responsibilities

| Layer | Responsibility | Forbidden |
|---|---|---|
| `controllers/` | Receive request, call service, render response | Business logic, ActiveRecord queries |
| `services/` | Business logic, orchestration | Direct rendering, ActiveRecord queries |
| `repositories/` | All database queries | Business logic, rendering |
| `views/*.json.jbuilder` | Format JSON output for success responses | Business logic, queries, sensitive fields |
| `models/` | Validations, associations, model-level callbacks | Business logic, query scopes used outside the model |

---

## Controller Hierarchy

Every controller MUST inherit from the appropriate base controller — never directly from `ApplicationController`.

```
ApplicationController
└── Api::V1::BaseController
    ├── Api::V1::GuestApplicationController      # public endpoints, no auth
    ├── Api::V1::AdminApplicationController      # admin staff only
    └── Api::V1::SuperAdminApplicationController # super admin only
```

| Base controller | Auth required | Role check | Use for |
|---|---|---|---|
| `ApplicationController` | — | — | Global config only — JSend helpers, `rescue_from`, error handling |
| `Api::V1::BaseController` | Yes (`require_authentication`) | — | Foundation for all API v1 controllers |
| `Api::V1::GuestApplicationController` | No (skipped) | — | Public endpoints: login, register, password reset |
| `Api::V1::AdminApplicationController` | Yes | `admin` | Admin staff features |
| `Api::V1::SuperAdminApplicationController` | Yes | `super_admin` | Super admin features |

```ruby
# Public endpoint
class Api::V1::SessionsController < Api::V1::GuestApplicationController
end

# Admin staff endpoint
class Api::V1::UsersController < Api::V1::AdminApplicationController
end

# Super admin endpoint
class Api::V1::RolesController < Api::V1::SuperAdminApplicationController
end
```

**Mandatory rules:**
- NEVER inherit directly from `ApplicationController` for any endpoint controller
- NEVER inherit from `Api::V1::BaseController` directly — always choose the correct access-level subclass
- `GuestApplicationController` is ONLY for truly public endpoints — when in doubt, require authentication

---

## Controller Rules

Controllers must be **thin**. A controller action does exactly three things: receive the request, call a service, render the response.

```ruby
# CORRECT
module Api
  module V1
    class SessionsController < ApplicationController
      def create
        result = Authentication::LoginService.call(login_params)
        if result.success?
          render_success(result.data, :created)
        else
          render_fail(result.errors, :unprocessable_entity)
        end
      end

      private

      def login_params
        params.require(:session).permit(:email, :password)
      end
    end
  end
end
```

**Mandatory rules:**
- Controllers MUST inherit from `ApplicationController`
- Controllers MUST use strong parameters for every action that accepts input
- Controllers MUST use `render_success`, `render_fail`, or `render_error` — never `render json:` directly
- Controllers MUST NOT contain ActiveRecord queries
- Controllers MUST NOT contain business logic
- Controllers MUST NOT rescue exceptions inline — all rescue happens in `ApplicationController`

---

## Service Pattern

All business logic lives in service classes. Services are the only place where decisions are made.

```ruby
# app/services/base_service.rb
class BaseService
  def self.call(...)
    new(...).call
  end
end

# app/services/authentication/login_service.rb
module Authentication
  class LoginService < BaseService
    def initialize(params)
      @params = params
    end

    def call
      user = UserRepository.new.find_by_email(@params[:email])
      return ServiceResult.failure(email: ["not found"]) unless user
      return ServiceResult.failure(password: ["invalid"]) unless user.authenticate(@params[:password])

      ServiceResult.success({ user: UserSerializer.new(user).as_json })
    end
  end
end
```

**Mandatory rules:**
- Every service MUST inherit from `BaseService`
- Every service MUST expose a `self.call` entry point (provided by `BaseService`)
- Every service MUST return a `ServiceResult` with `success?`, `data`, and `errors`
- Services MUST NOT call ActiveRecord directly — use a repository
- Services MUST NOT render responses
- Service names MUST be descriptive and scoped: `Namespace::VerbNounService`
  - Examples: `Authentication::LoginService`, `Users::CreateService`, `Orders::CancelService`
- Service folder names MUST use **plural** form — NEVER singular that matches a model name
  - CORRECT: `app/services/users/`, `app/services/orders/`
  - WRONG: `app/services/user/`, `app/services/order/` — singular collides with the model constant and breaks Rails autoloading

---

## Repository Pattern

All database access lives in repository classes. Nothing else touches ActiveRecord queries.

```ruby
# app/repositories/base_repository.rb
class BaseRepository
  private

  def model
    raise NotImplementedError
  end
end

# app/repositories/user_repository.rb
class UserRepository < BaseRepository
  def find_by_email(email)
    User.find_by(email: email)
  end

  def find_active_sessions(user_id)
    Session.where(user_id: user_id, active: true)
  end
end
```

**Mandatory rules:**
- Every repository MUST inherit from `BaseRepository`
- All ActiveRecord queries MUST live in a repository — no exceptions
- Controllers MUST NOT call repositories directly — only services call repositories
- Repository method names MUST be descriptive: `find_by_email`, `find_active_sessions`, `list_recent_orders`
- Repositories MUST NOT contain business logic or branching decisions
- ALL queries that load associations MUST use `includes`, `preload`, or `eager_load` to prevent N+1 queries
  - CORRECT: `User.includes(:sessions).where(role: :admin)`
  - WRONG: iterating over users and calling `user.sessions` inside the loop

---

## Response Format with JBuilder

All success JSON responses MUST use JBuilder view files. `render json:` is forbidden for success responses.

### File structure

JBuilder files mirror the controller namespace exactly:

```
app/
└── views/
    └── api/
        └── v1/
            ├── sessions/
            │   └── create.json.jbuilder
            └── profiles/
                └── show.json.jbuilder
```

### JSend wrapper in JBuilder

Every JBuilder file MUST wrap its output in the JSend `success` envelope:

```ruby
# app/views/api/v1/sessions/create.json.jbuilder
json.status "success"
json.data do
  json.user do
    json.id    @user.id
    json.email @user.email
    json.name  @user.name
  end
end
```

### render_fail and render_error

`render_fail` and `render_error` do NOT use JBuilder — they render JSON directly because there is no model data to format. These are already handled by the helpers in `ApplicationController`.

**Mandatory rules:**
- NEVER use `render json:` for success responses — always use a JBuilder view
- NEVER expose sensitive fields in any JBuilder file: `password_digest`, `reset_password_token`, raw tokens
- Every new controller action that returns data MUST have a corresponding `.json.jbuilder` view file
- JBuilder files MUST follow the JSend `success` envelope structure shown above

---

## Response Format: JSend

All responses MUST follow the [JSend specification](https://github.com/omniti-labs/jsend).

`ApplicationController` provides three helper methods:

```ruby
render_success(data, status = :ok)
render_fail(errors, status = :unprocessable_entity)
render_error(message, status = :internal_server_error)
```

**Response shapes:**

```json
// render_success
{ "status": "success", "data": { ... } }

// render_fail — client error (invalid input, failed precondition)
{ "status": "fail", "data": { "field": ["message"] } }

// render_error — server error
{ "status": "error", "message": "Something went wrong" }
```

**Mandatory rules:**
- Success (2xx) responses MUST use a JBuilder view — the view handles the `status: "success"` envelope
- Use `render_fail` for 4xx client errors (validation failures, not found, unauthorized)
- Use `render_error` for 5xx server errors
- HTTP status codes MUST be correct even though status is also in the body
- NEVER use `render json:` directly in a controller for success responses

---

## Error Handling

All exception handling is centralized in `ApplicationController` via `rescue_from`.

```ruby
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid,  with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found(e)
    render_fail({ base: [e.message] }, :not_found)
  end

  def record_invalid(e)
    render_fail(e.record.errors.as_json, :unprocessable_entity)
  end

  def bad_request(e)
    render_fail({ base: [e.message] }, :bad_request)
  end
end
```

**Mandatory rules:**
- NEVER rescue exceptions inline in a controller action
- NEVER let a raw exception reach the client
- Validation errors MUST use `render_fail` with per-field detail
- Server errors MUST use `render_error` with a safe, generic message — no stack traces, no internal details

---

## Security

**Cookies (when used):**
- MUST set `HttpOnly: true`
- MUST set `Secure: true` in production
- MUST set `SameSite: :lax`

**CORS:**
- `rack-cors` is commented out by default — uncomment only when needed
- `origins` MUST list only explicitly approved domains — never `*` in production

**CSRF:**
- CSRF protection MUST remain active (verify `ActionController::API` CSRF settings per Rails 8 defaults)

**Parameters:**
- Strong parameters are MANDATORY in every controller action that accepts input
- NEVER use `params` directly without `.permit()`

**Credentials:**
- ALL secrets and environment-specific values MUST use Rails credentials (`Rails.application.credentials`)
- NEVER hardcode secrets, tokens, passwords, or API keys in source code

**Rate limiting:**
- Authentication endpoints (`/sessions`, `/passwords`, etc.) MUST have rate limiting configured

**Input validation:**
- MUST exist at the model level via ActiveRecord validations
- NEVER skip validations with `save(validate: false)` or `update_columns`

---

## Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:show, :create, :update, :destroy]
      resource  :session, only: [:create, :destroy]
    end
  end
end
```

**Mandatory rules:**
- ALL routes MUST be defined inside `namespace :api` > `namespace :v1`
- ALWAYS use `resources` or `resource` — NEVER define routes manually with `get`, `post`, `delete`, etc.
- Use `only:` or `except:` to restrict to the actions actually implemented

---

## Background Jobs

Solid Queue runs inside the Puma process in development and production (`SOLID_QUEUE_IN_PUMA=true`).
Jobs live in `app/jobs/`. To run a dedicated worker: `bin/jobs`.

---

## Production Databases

Production uses four separate PostgreSQL databases:
- `primary` — application data
- `cache` — Solid Cache
- `queue` — Solid Queue
- `cable` — Solid Cable

Migrations for non-primary databases go in `db/cache_migrate`, `db/queue_migrate`, and `db/cable_migrate`.

---

## Deployment

Deployed via **Kamal** (`bin/kamal`) as a Docker container to `192.168.0.1`. Container registry: `localhost:5555`. `RAILS_MASTER_KEY` is injected as a secret at deploy time.

```bash
bin/kamal console   # Rails console on the server
bin/kamal logs      # Tail production logs
bin/kamal shell     # bash on the server
```

---

## Testing & API Documentation (RSpec + rswag)

Proyek ini menggunakan **RSpec** untuk testing dan **rswag** untuk generate dokumentasi Swagger/OpenAPI dari specs.

### Struktur direktori

```
spec/
├── factories/          # FactoryBot factories (satu file per model)
├── requests/
│   └── api/
│       └── v1/         # Request specs (satu file per controller)
├── support/
│   └── request_helpers.rb
├── rails_helper.rb
└── swagger_helper.rb   # Konfigurasi rswag
swagger/
└── v1/
    └── swagger.yaml    # Auto-generated — JANGAN edit manual
```

### Anatomi rswag request spec

```ruby
require 'swagger_helper'

RSpec.describe 'API V1 Users', type: :request do
  path '/api/v1/users' do
    post 'Create admin user' do
      tags     'Users'
      consumes 'application/json'
      produces 'application/json'
      security [ cookieAuth: [] ]

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email:    { type: :string },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      response '201', 'user created' do
        let(:super_admin) { create(:user, :super_admin) }
        let(:body) { { user: { email: 'new@test.com', password: 'Password12345!' } } }
        before { login_as(super_admin) }
        schema type: :object, properties: { status: { type: :string } }
        run_test!
      end
    end
  end
end
```

### Helper yang tersedia

```ruby
login_as(user)   # POST /api/v1/session dengan kredensial user (set cookie otomatis)
```

### Mandatory rules

- Setiap endpoint baru **WAJIB** memiliki rswag request spec di `spec/requests/api/v1/`
- Setiap spec **WAJIB** mencakup semua response codes yang mungkin (sukses, validasi gagal, unauthorized, forbidden)
- Setiap spec **WAJIB** menggunakan `swagger_helper` — bukan `rails_helper`
- Factories **WAJIB** dibuat untuk setiap model baru di `spec/factories/`
- `swagger/v1/swagger.yaml` **WAJIB** di-regenerate setelah menambah atau mengubah spec:
  ```bash
  SWAGGER_DRY_RUN=0 bundle exec rspec spec/requests/ --format Rswag::Specs::SwaggerFormatter --order defined
  ```
- **JANGAN** edit `swagger/v1/swagger.yaml` secara manual — file ini auto-generated dari specs
- Request ke authenticated endpoint dalam specs **WAJIB** menggunakan `before { login_as(user) }`
- Endpoint yang memerlukan auth **WAJIB** ditandai dengan `security [ cookieAuth: [] ]`

---

## Commit Message Rules

Semua commit MUST mengikuti format berikut (referensi: [Conventional Commits](https://gist.github.com/nyancodeid/63f19941c81252bb0cca9c14497cf9f7)):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **Header** wajib ada. **Scope** opsional. **Body** dan **footer** opsional.
- Semua baris TIDAK BOLEH melebihi **100 karakter**.

### Tipe Commit

| Tipe | Digunakan untuk |
|---|---|
| `feat` | Penambahan fitur baru |
| `fix` | Perbaikan bug |
| `refactor` | Restrukturisasi kode tanpa menambah fitur atau memperbaiki bug |
| `docs` | Perubahan dokumentasi saja |
| `style` | Perubahan formatting yang tidak mempengaruhi logika kode |
| `perf` | Perubahan kode untuk meningkatkan performa |
| `build` | Perubahan yang mempengaruhi build system atau dependency eksternal |
| `ci` | Perubahan konfigurasi CI |
| `test` | Menambah atau memperbaiki test |

### Aturan Subject

- Gunakan **imperative present tense**: `add`, `fix`, `update` — bukan `added`, `fixed`, `updated`
- Awali dengan **huruf kecil**
- **Tanpa tanda titik** di akhir

### Body

- Gunakan konvensi yang sama dengan subject
- Jelaskan **motivasi** perubahan dan kontras dengan perilaku sebelumnya

### Footer

- Cantumkan breaking changes dengan prefix `BREAKING CHANGE:`
- Cantumkan referensi issue GitHub jika ada

### Revert

Commit revert diawali dengan `revert:` diikuti header commit asli, dengan body:
`This reverts commit <hash>.`

### Contoh

```
feat(auth): add httpOnly cookie session authentication

Implements login and logout using signed httpOnly cookies instead of
JWT in Authorization header, preventing XSS token theft.

BREAKING CHANGE: clients must send cookies instead of Bearer tokens
```

```
fix(sessions): destroy session record on logout
```

```
refactor(repositories): extract session queries to SessionRepository
```

**Mandatory rules:**
- ALWAYS use one of the 9 commit types listed above — no custom types
- NEVER write subject in past tense (`added`, `fixed`) — always imperative present tense
- NEVER exceed 100 characters per line
- NEVER commit secrets, tokens, or credentials

---

## General Rules (Non-Negotiable)

1. **New file** → confirm it follows the naming convention and is in the correct folder before creating it.
2. **Need a database query** → always use or create a repository. Never query inline.
3. **Need business logic** → always use or create a service. Never put logic in a controller.
4. **Never skip validations** for any reason.
5. **Never expose stack traces or internal error messages** to the client.
6. **Never expose sensitive fields** (`password_digest`, tokens, internal keys) in any JSON response.
7. **Never hardcode secrets** — use `Rails.application.credentials`.
8. **Always use strong parameters** — never trust raw `params`.
