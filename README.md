# Kondangyuk API

Rails 8.1 API-only dengan autentikasi httpOnly cookie dan Role-Based Access Control (RBAC).

---

## Stack

- Ruby 4.0.5 / Rails 8.1.3 (API-only)
- PostgreSQL
- Solid Cache / Solid Queue / Solid Cable (tanpa Redis)
- Autentikasi: httpOnly cookie session (tanpa JWT)

---

## Setup

```bash
bin/setup           # Install gems + buat database + jalankan seed
bin/dev             # Jalankan server (localhost:3000)
```

### Manual setup

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

### Konfigurasi credentials

```bash
bin/rails credentials:edit
```

Tambahkan nilai berikut:

```yaml
cors:
  allowed_origins:
    - http://localhost:3000      # development frontend
    - https://yourapp.com        # production frontend
```

---

## Roles

| Role | Deskripsi |
|---|---|
| `admin` | Staff admin — akses ke fitur admin dan profil sendiri |
| `super_admin` | Super admin — akses penuh termasuk manajemen role user |

---

## Endpoint

### Autentikasi

#### `POST /api/v1/session` — Login

Tidak memerlukan autentikasi. Rate limit: 10 request/menit per IP.

**Request:**
```json
{
  "session": {
    "email": "admin@kondangyuk.test",
    "password": "AdminKondangyuk@2024"
  }
}
```

**Response sukses `201 Created`:**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "email": "admin@kondangyuk.test"
    }
  }
}
```
Token disimpan sebagai httpOnly cookie `session_token`.

**Response gagal `422 Unprocessable Entity`:**
```json
{
  "status": "fail",
  "data": {
    "email": ["not found"]
  }
}
```

---

#### `DELETE /api/v1/session` — Logout

Tidak memerlukan autentikasi. Menghapus session dari DB dan menghapus cookie.

**Response `204 No Content`** — tidak ada body.

---

### Profil

#### `GET /api/v1/profile` — Lihat profil sendiri

Memerlukan autentikasi (cookie `session_token`). Bisa diakses oleh `admin` dan `super_admin`.

**Response sukses `200 OK`:**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "email": "admin@kondangyuk.test",
      "role": "admin"
    }
  }
}
```

**Response tidak terautentikasi `401 Unauthorized`:**
```json
{
  "status": "fail",
  "data": {
    "base": ["Not authenticated"]
  }
}
```

**Response akses ditolak `403 Forbidden`:**
```json
{
  "status": "fail",
  "data": {
    "base": ["Forbidden"]
  }
}
```

---

## Format Response (JSend)

Semua response mengikuti spesifikasi [JSend](https://github.com/omniti-labs/jsend):

| Status | HTTP | Digunakan untuk |
|---|---|---|
| `success` | 2xx | Request berhasil, data tersedia |
| `fail` | 4xx | Request ditolak (validasi gagal, tidak terautentikasi, dsb.) |
| `error` | 5xx | Server error |

```json
{ "status": "success", "data": { ... } }
{ "status": "fail",    "data": { "field": ["pesan error"] } }
{ "status": "error",   "message": "Pesan error yang aman" }
```

---

## Keamanan

- **Cookie**: httpOnly, Secure (production), SameSite=Lax
- **CORS**: origins dari Rails credentials, `credentials: true`
- **SSL**: `force_ssl = true` di production
- **Rate limiting**: 10 req/menit per IP pada endpoint login
- **Password**: minimal 12 karakter, disimpan dengan bcrypt

---

## Arsitektur

```
controllers/        <- Terima request, panggil service, render response
services/           <- Semua business logic
repositories/       <- Semua query database (ActiveRecord)
models/             <- Validasi, asosiasi, callbacks
views/**/*.jbuilder <- Format JSON sukses (JSend envelope)
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
