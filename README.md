# Send Demurrage – Rails 7 API

Modernised service for demurrage billing and overdue-invoice tracking built on top of a legacy shipping schema.

---

## ✨ Features
* Generates demurrage invoices for overdue Bills of Lading (BLs)
* Lists invoices that are themselves overdue
* Clean, opinionated Rails 7 API with specs (>80 % coverage)
* Seeds generate random but realistic data & are safe to run repeatedly.

## 🛠 Requirements
* Ruby 3.2+
* Rails 7.2
* MySQL 

## ⚡ Setup
```bash
# clone & install deps
git clone <repo>
cd send_demurrage
bundle install

# data
# ➡️ DEVELOPMENT
bin/rails db:setup          # create, migrate & seed development DB

# run the server locally
bin/rails server -p 3000
# => http://localhost:3000 (e.g. GET /invoices/overdue)
```

### 🐳 Docker quick-start
All you need is **Docker Desktop** (or engine) + **Docker Compose v2+**.

Run the stack:
```bash
# build images & start in foreground
docker compose up --build
# or, detached mode (recommended)
docker compose up -d --build   # <- keeps terminal free
```
It brings up two services:
* **db** – MySQL 8 accessible from host at **localhost:3306**  
  (root pwd `root`, DB `send_demurrage_development`)
* **app** – Puma server exposed on **http://localhost:3000**

The `app` container waits for MySQL to be ready, then executes:
`rails db:create db:migrate db:seed && rails server -b 0.0.0.0`
so **no manual DB step is required inside Docker**.

Quick smoke-test once containers are healthy:
```bash
curl http://localhost:3000/invoices/overdue
```

Stop & remove containers/volumes when done:
```bash
docker compose down -v   # -v also drops the named volume `db_data`
```

Environment variables (edit in [`docker-compose.yml`](./docker-compose.yml) or override):
```yaml
RAILS_ENV: development
DB_HOST: db
MYSQL_ROOT_PASSWORD: root
```

The seed script creates 5 customers, ~10 Bills of Lading and a handful of invoices.

## 🚀 Usage
### Endpoints
| Verb | Path                | Purpose                               |
|------|---------------------|---------------------------------------|
| GET  | /invoices/overdue   | List unpaid invoices whose `due_date` has passed |
| POST | /invoices/generate  | Generate demurrage invoices for BLs overdue *today* |

### Sample `curl`
```bash
# List overdue invoices
curl -s http://localhost:3000/invoices/overdue
```

```bash
# Trigger invoice generation
curl -X POST http://localhost:3000/invoices/generate
```

Responses are JSON and follow the serializer included in `app/serializers/invoice_serializer.rb`.

## 🧪 Tests & Linting

### ➡️ TEST
```bash
RAILS_ENV=test bin/rails db:create db:migrate
```

```bash
bundle exec rspec        # 44 examples, 0 failures
```
SimpleCov is enabled; run specs to see coverage in `coverage/`.

## 🤔 Design Decisions & Assumptions
* **Modular migrations** – each logical database change lives in its own migration so it can be rolled back or re-run in isolation.
* **Schema hardening & constraints** – the legacy dump had no foreign keys and many nullable fields. Some database-level safety nets were added:
  • FKs (`fk_invoices_on_bill_of_lading_number`, `fk_bill_of_ladings_on_customer_id`, …)
  • unique indexes (`index_invoices_on_reference`, `index_bill_of_ladings_on_number`)
  • NOT-NULL constraints on business-critical columns (`reference`, `amount`, `due_date`, …).
  These let the DB, not the app code, guarantee referential integrity.
* **Automatic timestamps** – `created_at`/`updated_at` were added to *all* business tables (BLs, invoices, customers, refund_requests).  They provide an audit trail and can help power future analytics.
* **Back-filling `due_date`** – legacy invoices never recorded a due date.  Because `created_at` was already present **and non-null**, it was deterministically restored: `due_date = created_at + 15 days`.
* **Duplicate protection** – an invoice is considered *open* if its `status` is one of (`open`, `init`, `pending`).  When generating new invoices the service skips BLs that already have an open invoice, providing idempotency and preventing double billing.
* **Demurrage rate** – fixed at **80 USD per container** (`DEMURRAGE_RATE_USD`).  
* **Invoice due date for new invoices** – calculated as *today + 15 days* (`INVOICE_DUE_DAYS`), matching the back-fill rule above for historical rows.
* **Free-time rename** – legacy `freetime` column became `free_time_days`; invoices are only generated when `arrival_date + free_time_days == today` (`BillOfLading.overdue_today`).

