# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_08_20_052400) do
  create_table "bill_of_ladings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "id_upload"
    t.datetime "date_upload"
    t.string "number", limit: 9, null: false
    t.bigint "customer_id"
    t.string "arrival_date"
    t.integer "free_time_days"
    t.integer "containers_20ft_dry_count"
    t.integer "containers_40ft_dry_count"
    t.integer "containers_20ft_reefer_count"
    t.integer "containers_40ft_reefer_count"
    t.integer "containers_20ft_special_count"
    t.integer "containers_40ft_special_count"
    t.string "statut"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["arrival_date"], name: "index_bill_of_ladings_on_arrival_date"
    t.index ["customer_id"], name: "index_bill_of_ladings_on_customer_id"
    t.index ["number"], name: "index_bill_of_ladings_on_number", unique: true
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 60, null: false
    t.string "statut"
    t.string "code", limit: 20
    t.string "nom_groupe", limit: 150
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reference", limit: 10, null: false
    t.string "bill_of_lading_number", limit: 9, null: false
    t.string "code_client", limit: 20, null: false
    t.string "nom_client", limit: 60, null: false
    t.decimal "amount", precision: 12, null: false
    t.decimal "montant_orig", precision: 12
    t.string "currency", limit: 6, default: "XOF"
    t.string "status", limit: 10, default: "init", null: false
    t.datetime "invoiced_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.date "due_date", null: false
    t.index ["bill_of_lading_number"], name: "index_invoices_on_bill_of_lading_number"
    t.index ["reference"], name: "index_invoices_on_reference", unique: true
  end

  create_table "refund_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "bill_of_lading_number", limit: 9, null: false
    t.string "requested_amount", limit: 15
    t.string "status", limit: 10, default: "PENDING"
    t.datetime "date_demande"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bill_of_lading_number"], name: "index_refund_requests_on_bill_of_lading_number"
  end

  add_foreign_key "bill_of_ladings", "customers", name: "fk_bill_of_ladings_on_customer_id"
  add_foreign_key "invoices", "bill_of_ladings", column: "bill_of_lading_number", primary_key: "number", name: "fk_invoices_on_bill_of_lading_number"
  add_foreign_key "refund_requests", "bill_of_ladings", column: "bill_of_lading_number", primary_key: "number", name: "fk_refund_requests_on_bill_of_lading_number"
end
