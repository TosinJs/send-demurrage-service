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

# database
bin/rails db:setup   # creates, migrates & seeds sample data

# run the server
bin/rails server -p 3000
```

### 🐳 Docker quick-start
If you prefer containers you only need **Docker** & **Docker Compose**:
```bash
docker compose up --build
```
The compose file spins up:
* `db` – MySQL 8 (official image) listening on **localhost:3306**  
  Docs: https://hub.docker.com/_/mysql
* `app` – this Rails API (built from the included Dockerfile) on **localhost:3000**

The `app` service waits for MySQL, runs `db:create migrate seed`, then launches Puma. Hot-reloading works via the bind-mount.

Environment variables (pre-set in [`docker-compose.yml`](./docker-compose.yml) — edit there or override on the command line):
```yaml
DB_HOST: db               # Container hostname used by Rails
MYSQL_ROOT_PASSWORD: root # Change for non-demo use
RAILS_ENV: development
```
Shut everything down with:
```bash
docker compose down
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
```bash
bundle exec rspec        # 44 examples, 0 failures
```
SimpleCov is enabled; run specs to see coverage in `coverage/`.

## 🤔 Design Decisions & Assumptions
* **Modular migrations** – the migrations are split into separate migrations so each concern can be rolled back or reapplied independently.
* **Demurrage rate** the rate is fixed at **80 USD per container** (see `Demurrage::InvoiceGenerator::DEMURRAGE_RATE_USD`).
* **Invoice due date** the due date is set to `invoiced_at + 15 days` (constant `INVOICE_DUE_DAYS`).
* Legacy BL `freetime` column renamed to `free_time_days`; overdue BLs are those where `arrival_date + free_time_days <= today`.

## 🗂 Project Structure (highlights)
```
app/
  models/ (Customer, BillOfLading, Invoice, RefundRequest)
  services/demurrage/invoice_generator.rb
  controllers/invoices_controller.rb
  serializers/invoice_serializer.rb
spec/ (factories, models, services, requests)
```

