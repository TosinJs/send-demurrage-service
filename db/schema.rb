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

ActiveRecord::Schema[7.2].define(version: 2025_08_20_034719) do
  create_table "bl", primary_key: "id_bl", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "id_upload"
    t.datetime "date_upload"
    t.string "numero_bl", limit: 9, null: false
    t.bigint "id_client"
    t.string "arrival_date"
    t.integer "freetime"
    t.integer "nbre_20pieds_sec"
    t.integer "nbre_40pieds_sec"
    t.integer "nbre_20pieds_frigo"
    t.integer "nbre_40pieds_frigo"
    t.integer "nbre_20pieds_special"
    t.integer "nbre_40pieds_special"
    t.string "statut"
    t.index ["arrival_date"], name: "index_bl_on_arrival_date"
    t.index ["numero_bl"], name: "index_bl_on_numero_bl"
  end

  create_table "client", primary_key: "id_client", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "nom", limit: 60, null: false
    t.string "statut"
    t.string "code_client", limit: 20
    t.string "nom_groupe", limit: 150
  end

  create_table "facture", primary_key: "id_facture", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reference", limit: 10, null: false
    t.string "numero_bl", limit: 9, null: false
    t.string "code_client", limit: 20, null: false
    t.string "nom_client", limit: 60, null: false
    t.decimal "montant_facture", precision: 12, null: false
    t.decimal "montant_orig", precision: 12
    t.string "devise", limit: 6, default: "XOF"
    t.string "statut", limit: 10, default: "init", null: false
    t.datetime "date_facture", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at"
    t.index ["reference"], name: "index_facture_on_reference", unique: true
  end

  create_table "remboursement", primary_key: "id_remboursement", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "numero_bl", limit: 9, null: false
    t.string "montant_demande", limit: 15
    t.string "statut", limit: 10, default: "PENDING"
    t.datetime "date_demande"
    t.index ["numero_bl"], name: "index_remboursement_on_numero_bl"
  end
end
