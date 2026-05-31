# Kondangyuk API

Rails 8.1 API-only with httpOnly cookie authentication and Role-Based Access Control (RBAC).

---

## Stack

- Ruby 4.0.5 / Rails 8.1.3 (API-only)
- PostgreSQL
- Solid Cache / Solid Queue / Solid Cable (no Redis)
- Authentication: httpOnly cookie session (no JWT)

---

## Setup

```bash
bin/setup    # Install gems + create database + run seeds
bin/dev      # Start server (localhost:3000)
```

### Manual setup

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

### Credentials configuration

```bash
bin/rails credentials:edit
```

Add the following values:

```yaml
cors:
  allowed_origins:
    - http://localhost:3000      # development frontend
    - https://yourapp.com        # production frontend
```

---

## API Documentation (Swagger UI)

After `git pull`, follow these steps to view the API documentation:

**1. Initial setup (once only)**
```bash
bin/setup
```

**2. Generate swagger.yaml from specs**
```bash
SWAGGER_DRY_RUN=0 bundle exec rspec spec/requests/ \
  --format Rswag::Specs::SwaggerFormatter --order defined
```

**3. Start the server**
```bash
bin/dev
```

**4. Open in browser**
```
http://localhost:3000/api-docs
```

> Step 2 must be re-run every time a new endpoint is added or a spec is changed.

---

## Roles

| Role | Description |
|---|---|
| `admin` | Admin staff — access to admin features and own profile |
| `super_admin` | Super admin — full access including user role management |

---

## Response Format (JSend)

All responses follow the [JSend specification](https://github.com/omniti-labs/jsend):

| Status | HTTP | Used for |
|---|---|---|
| `success` | 2xx | Request succeeded, data available |
| `fail` | 4xx | Request rejected (validation failed, unauthenticated, etc.) |
| `error` | 5xx | Server error |

```json
{ "status": "success", "data": { ... } }
{ "status": "fail",    "data": { "field": ["error message"] } }
{ "status": "error",   "message": "A safe error message" }
```

---

## Security

- **Cookie**: httpOnly, Secure (production), SameSite=Lax
- **CORS**: origins from Rails credentials, `credentials: true`
- **SSL**: `force_ssl = true` in production
- **Rate limiting**: 10 req/min per IP on login endpoint
- **Password**: minimum 8 characters, stored with bcrypt

---

## Architecture

```
controllers/        <- Receive request, call service, render response
services/           <- All business logic
repositories/       <- All database queries (ActiveRecord)
models/             <- Validations, associations, callbacks
views/**/*.jbuilder <- Format success JSON (JSend envelope)
```

---

## Seed Users (development)

| Email | Password | Role |
|---|---|---|
| `admin@kondangyuk.test` | `AdminKondangyuk@2024` | `admin` |
| `superadmin@kondangyuk.test` | `SuperAdminKondangyuk@2024` | `super_admin` |

---

## CI

```bash
bin/ci  # rubocop + bundler-audit + brakeman
```
