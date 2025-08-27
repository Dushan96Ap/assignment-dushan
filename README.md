
---

# ASE Auth (Angular + Node + MSSQL)

Simple login/registration app:

* **Frontend:** Angular
* **Backend:** Node/Express + JWT
* **DB:** SQL Server (tables + stored procedures)

## Quick start

### 1) Database

**Option A – Docker (Win/macOS)**

```bash
# start SQL Server in Docker (host 1433 → container 1433)
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Str0ngP@ssw0rd123!" \
  -p 1433:1433 --name ase-sql -d mcr.microsoft.com/mssql/server:2022-latest
```


**Create DB & run scripts (Azure Data Studio / SSMS)**

```sql
CREATE DATABASE ASEAuthDb;
GO
-- Then run in ASEAuthDb:
--   sql/create_tables.sql
--   sql/stored_procedures.sql
```

### 2) Backend (Node/Express)

```bash
cd backend
cp .env.example .env
```

`backend/.env`:

```env
PORT=4000
JWT_SECRET=change_me
JWT_EXPIRES_IN=1d

DB_USER=sa
DB_PASSWORD=Str0ngP@ssw0rd123!
DB_SERVER=localhost
DB_DATABASE=ASEAuthDb
DB_OPTIONS_ENCRYPT=false
DB_PORT=1433
```

Run:

```bash
npm install
npm run dev   # http://localhost:4000
```

### 3) Frontend (Angular)

```bash
cd frontend
npm install
ng serve      # http://localhost:4200
```

> If the repo only contains `frontend_src/src`, create an Angular app with
> `ng new ase-auth-frontend --no-standalone --routing --style=css --ssr=false`, then replace its `src/` with `frontend_src/src`.

## API (summary)

* `POST /api/auth/register`
* `POST /api/auth/login` → `{ token }`
* `GET /api/auth/me` (Bearer token)

A Postman collection is in `/postman`.

---
