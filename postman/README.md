# Postman collection — Kondangyuk API

Files:

- `kondangyuk-api.postman_collection.json` — the collection (51 requests, grouped by area).
- `kondangyuk-api.postman_environment.json` — environment with `baseUrl`, `email`, `password`.
- `generate_collection.rb` — regenerates both from `swagger/v1/swagger.yaml`.

## Import

1. In Postman: **Import** → drop both JSON files.
2. Select the **Kondangyuk — Local** environment (top-right) and adjust `baseUrl`, `email`, `password`.

## Authentication (cookie-based)

The API uses an httpOnly `session_token` cookie — there is no bearer token to copy.

1. Run **Public | Sessions → Create session** (login). It sends `{{email}}` / `{{password}}` and the
   server replies with `Set-Cookie: session_token=…`.
2. Postman stores that cookie in its cookie jar for `baseUrl` and **sends it automatically** on every
   subsequent request. Just run the admin/super-admin requests after logging in.
3. **Public | Sessions → Destroy session** (logout) clears it server-side.

Roles: `Admin | …` folders need an admin or super_admin account; `Super Admin | …` folders need a
super_admin. Log in with an account that has the required role.

## Path & query variables

Requests with `:id`, `:slug`, `:template_id`, etc. expose them under the request's **Path Variables**
(default `1` / `my-slug`). Query params (pagination, filters) are included but **disabled** by default —
tick them to use.

## File uploads

Media/thumbnail uploads use `multipart/form-data` with a single file field (`file` for media,
`thumbnail` for thumbnails). Open the request **Body → form-data**, click the file field, and choose a
local file.

## Regenerating

After changing specs and regenerating the OpenAPI doc:

```bash
SWAGGER_DRY_RUN=0 bundle exec rspec spec/requests/ \
  --format Rswag::Specs::SwaggerFormatter --order defined
ruby postman/generate_collection.rb
```
