# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
All rules in this file are **mandatory and must be followed without exception**.

---

## Project Overview

**Kondangyuk** is a back-end API for a **digital invitation platform** with the following characteristics:

- **Digital invitations are reusable and layout-customizable** — a single invitation template can be modified per order (layout, content, styling) and reused across many orders.
- **Orders come from third-party marketplaces** (e.g., Shopee) — there is **no API integration** with these platforms. Orders are managed manually inside this application after a buyer places an order on the marketplace.
- The application handles the full post-order workflow: receiving order data, assigning/customizing an invitation template for the order, and delivering the final digital invitation.

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

Swagger UI is available at `/api-docs` once the server is running.

> `rails/test_unit/railtie` is intentionally commented out — the project uses RSpec instead.

---

## Architecture & Folder Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   └── api/
│       └── v1/
│           ├── base_controller.rb          # parent for all API v1 controllers
│           ├── guest/                       # public endpoints, no auth
│           │   ├── base_controller.rb
│           │   └── sessions_controller.rb
│           ├── super_admin/                 # super_admin only
│           │   ├── base_controller.rb
│           │   ├── users_controller.rb
│           │   └── settings_controller.rb
│           ├── admin/                       # admin only
│           │   ├── base_controller.rb
│           │   ├── users_controller.rb
│           │   └── projects_controller.rb
│           └── designer/                    # designer only
│               ├── base_controller.rb
│               ├── projects_controller.rb
│               └── assets_controller.rb
├── views/
│   └── api/
│       └── v1/          # JBuilder files mirror the controller structure (incl. role folder)
├── services/            # All business logic
│   └── base_service.rb
├── repositories/        # All database queries
│   └── base_repository.rb
├── models/              # Validations, associations, and model-level callbacks only
└── jobs/                # Background jobs (Solid Queue)

config/
├── routes.rb           # Draws each per-role route file — no resources defined here
└── routes/             # One file per role, drawn from routes.rb
    ├── guest.rb
    ├── super_admin.rb
    ├── admin.rb
    └── designer.rb
```

Controllers are grouped into a **per-role folder** under `api/v1/` (`guest/`, `super_admin/`,
`admin/`, `designer/`). Each role folder has its own `base_controller.rb` that handles that
role's authentication and authorization.

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

Every controller MUST inherit from its **role's** base controller — never directly from
`ApplicationController` or `Api::V1::BaseController`.

```
ApplicationController
└── Api::V1::BaseController
    ├── Api::V1::Guest::BaseController       # public endpoints, no auth
    ├── Api::V1::SuperAdmin::BaseController  # super_admin only
    ├── Api::V1::Admin::BaseController       # admin only
    └── Api::V1::Designer::BaseController    # designer only
```

| Base controller | Auth required | Role check | Use for |
|---|---|---|---|
| `ApplicationController` | — | — | Global config only — JSend helpers, `rescue_from`, error handling |
| `Api::V1::BaseController` | Yes (`require_authentication`) | — | Foundation for all API v1 controllers |
| `Api::V1::Guest::BaseController` | No (skipped) | — | Public endpoints: login, register, password reset |
| `Api::V1::SuperAdmin::BaseController` | Yes | `super_admin` | Super admin features |
| `Api::V1::Admin::BaseController` | Yes | `admin` | Admin staff features |
| `Api::V1::Designer::BaseController` | Yes | `designer` | Designer features |

```ruby
# Public endpoint
class Api::V1::Guest::SessionsController < Api::V1::Guest::BaseController
end

# Super admin endpoint
class Api::V1::SuperAdmin::UsersController < Api::V1::SuperAdmin::BaseController
end

# Admin staff endpoint
class Api::V1::Admin::ProjectsController < Api::V1::Admin::BaseController
end

# Designer endpoint
class Api::V1::Designer::AssetsController < Api::V1::Designer::BaseController
end
```

**Mandatory rules:**
- NEVER inherit directly from `ApplicationController` for any endpoint controller
- NEVER inherit from `Api::V1::BaseController` directly — always choose the correct role's base controller
- Every controller MUST live in its role folder and be namespaced under that role module
  (e.g. `Api::V1::Admin::UsersController` in `app/controllers/api/v1/admin/users_controller.rb`)
- The same resource may exist under multiple roles (e.g. `Admin::UsersController` and
  `SuperAdmin::UsersController`) — each is a separate controller scoped to its role
- `Api::V1::Guest::BaseController` is ONLY for truly public endpoints — when in doubt, require authentication

---

## Controller Rules

Controllers must be **thin**. A controller action does exactly three things: receive the request, call a service, render the response.

```ruby
# CORRECT
module Api
  module V1
    module Guest
      class SessionsController < Api::V1::Guest::BaseController
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
end
```

**Mandatory rules:**
- Controllers MUST inherit from their role's base controller (`Api::V1::<Role>::BaseController`)
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
      return ServiceResult.failure(email: [I18n.t("messages.errors.not_found")]) unless user
      unless user.authenticate(@params[:password])
        return ServiceResult.failure(password: [I18n.t("messages.errors.invalid_credentials")])
      end

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

JBuilder files mirror the controller namespace exactly — including the role folder:

```
app/
└── views/
    └── api/
        └── v1/
            ├── guest/
            │   └── sessions/
            │       └── create.json.jbuilder
            └── admin/
                └── projects/
                    └── show.json.jbuilder
```

### JSend wrapper in JBuilder

Every JBuilder file MUST wrap its output in the JSend `success` envelope:

```ruby
# app/views/api/v1/guest/sessions/create.json.jbuilder
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
- The success envelope is exactly `{ "status": "success", "data": { ... } }` — there is NO `message`
  field on success responses. NEVER add `json.message` to a JBuilder view.
- Use `render_fail` for 4xx client errors (validation failures, not found, unauthorized)
- Use `render_error` for 5xx server errors
- HTTP status codes MUST be correct even though status is also in the body
- NEVER use `render json:` directly in a controller for success responses
- ALL user-facing messages in responses (fail/error messages, validation messages) MUST be
  internationalized — see the [Internationalization (i18n)](#internationalization-i18n) section.
  NEVER hardcode an English string as a response message.

---

## Internationalization (i18n)

The front-end supports **Indonesian (`id`)** and **English (`en`)**. Every user-facing message
returned by the API (validation errors, `render_fail`/`render_error` messages) MUST be localized.
Success responses carry no message, so i18n applies only to error/validation output.

- The request locale is resolved from the **`Accept-Language`** header by an `around_action` in
  `ApplicationController` (`switch_locale`), falling back to `:en` when absent or unsupported.
  Supported locales are configured in `config/application.rb` (`available_locales [:en, :id]`,
  `default_locale :en`).
- Translations live in `config/locales/en.yml` and `config/locales/id.yml` under the
  `messages.errors.*` namespace. The `rails-i18n` gem provides the Indonesian translations for
  default ActiveRecord/ActiveModel validation messages — model validation errors returned via
  `record.errors.as_json` are localized automatically.

**Mandatory rules:**
- NEVER hardcode a user-facing message string. Always use `I18n.t("messages.errors.<key>")`.
- Service `ServiceResult.failure` messages MUST use `I18n.t`, NOT literal strings.
- Both `en.yml` and `id.yml` MUST be updated together — every key MUST exist in both locales.
- NEVER call `I18n.t` where it is evaluated at class-load time (frozen constants, the `message:`
  argument of `validates`). It would freeze the locale at boot. Use a per-request method call, or a
  Proc for validation messages — e.g. `format: { with: SLUG_FORMAT, message: ->(*) { I18n.t(...) } }`.
- A new endpoint that can return a localized message MUST cover it in a request spec for at least
  one non-default locale (send `Accept-Language: id` and assert the translated message).

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

Routes are **split per role**. Each role has its own file under `config/routes/` that is loaded
from `config/routes.rb` via Rails' `draw` helper. `config/routes.rb` itself MUST NOT define any
`resources`/`resource` — it only draws the per-role files.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  draw(:guest)
  draw(:super_admin)
  draw(:admin)
  draw(:designer)
end
```

```ruby
# config/routes/super_admin.rb
namespace :api do
  namespace :v1 do
    namespace :super_admin do
      resources :users,    only: [:index, :show, :create, :update, :destroy]
      resources :settings, only: [:index, :update]
    end
  end
end
```

```ruby
# config/routes/guest.rb
namespace :api do
  namespace :v1 do
    namespace :guest do
      resource :session, only: [:create, :destroy]
    end
  end
end
```

**Mandatory rules:**
- Each role's routes MUST live in its own file: `config/routes/<role>.rb`
  (`guest.rb`, `super_admin.rb`, `admin.rb`, `designer.rb`)
- `config/routes.rb` MUST only call `draw(:<role>)` for each role — NEVER define routes there directly
- ALL routes MUST be nested inside `namespace :api` > `namespace :v1` > `namespace :<role>`
- ALWAYS use `resources` or `resource` — NEVER define routes manually with `get`, `post`, `delete`, etc.
- Use `only:` or `except:` to restrict to the actions actually implemented
- Every route that returns a list of data (index actions) MUST implement pagination using the `pagy` gem — call `pagy(:offset, collection)` in the controller and include `pagination` metadata in the JBuilder response. Never return unbounded collections.
- Every DELETE endpoint MUST explicitly state in its rswag `description` whether it is a **soft delete** or **hard delete**:
  - **Soft delete** (master data tables, e.g. themes): set `deleted_at` timestamp — record is retained and excluded from queries. Description example: `"Soft deletes a ... by ID (sets deleted_at). Record is retained in the database and excluded from all queries."`
  - **Hard delete** (transactional/non-master data): record is permanently removed. Description example: `"Permanently deletes a ... by ID."`
- **Soft delete `deleted_at` column MUST use `timestamp` type** — NEVER `datetime`. Using `datetime` does not work correctly in this stack (PostgreSQL + Rails 8). Always define the migration as `t.timestamp :deleted_at` or `add_column :table, :deleted_at, :timestamp`.

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

This project uses **RSpec** for testing and **rswag** to generate Swagger/OpenAPI documentation from specs.

### Directory structure

```
spec/
├── factories/          # FactoryBot factories (one file per model)
├── requests/
│   └── api/
│       └── v1/         # Request specs mirror the controller role folders
│           ├── guest/
│           ├── super_admin/
│           ├── admin/
│           └── designer/
├── support/
│   └── request_helpers.rb
├── rails_helper.rb
└── swagger_helper.rb   # rswag configuration
swagger/
└── v1/
    └── swagger.yaml    # Auto-generated — DO NOT edit manually
```

### rswag request spec anatomy

```ruby
require 'swagger_helper'

RSpec.describe 'API V1 SuperAdmin Users', type: :request do
  path '/api/v1/super_admin/users' do
    post 'Create user' do
      tags     'SuperAdmin Users'
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

### Available helpers

```ruby
login_as(user)   # POST /api/v1/guest/session with user credentials (sets cookie automatically)
```

### Mandatory rules

- Every new endpoint MUST have a rswag request spec in `spec/requests/api/v1/`
- Every spec MUST cover all possible response codes (success, validation failure, unauthorized, forbidden)
- Every spec MUST require `swagger_helper` — not `rails_helper`
- A factory MUST be created for every new model in `spec/factories/`
- `swagger/v1/swagger.yaml` MUST be regenerated after adding or changing specs:
  ```bash
  SWAGGER_DRY_RUN=0 bundle exec rspec spec/requests/ --format Rswag::Specs::SwaggerFormatter --order defined
  ```
- NEVER edit `swagger/v1/swagger.yaml` manually — it is auto-generated from specs
- Requests to authenticated endpoints in specs MUST use `before { login_as(user) }`
- Endpoints that require auth MUST be marked with `security [ cookieAuth: [] ]`

---

## Commit Message Rules

All commits MUST follow the format below (reference: [Conventional Commits](https://gist.github.com/nyancodeid/63f19941c81252bb0cca9c14497cf9f7)):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **Header** is mandatory. **Scope** is optional. **Body** and **footer** are optional.
- All lines MUST NOT exceed **100 characters**.

### Commit Types

| Type | Used for |
|---|---|
| `feat` | Introduction of new functionality |
| `fix` | Bug corrections |
| `refactor` | Code restructuring without feature additions or bug fixes |
| `docs` | Documentation-only modifications |
| `style` | Formatting changes that do not affect code logic |
| `perf` | Performance-enhancing code changes |
| `build` | Changes that affect the build system or external dependencies |
| `ci` | Changes to CI configuration files and scripts |
| `test` | Adding or correcting tests |

### Subject Rules

- Use **imperative present tense**: `add`, `fix`, `update` — not `added`, `fixed`, `updated`
- Begin with a **lowercase letter**
- **No trailing punctuation**

### Body

- Mirror subject conventions
- Explain the **motivation** behind the change and contrast with prior behavior

### Footer

- Include breaking changes prefaced with `BREAKING CHANGE:`
- Include GitHub issue references when applicable

### Revert

Reverted commits must start with `revert:` followed by the original commit header, with body:
`This reverts commit <hash>.`

### Examples

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
