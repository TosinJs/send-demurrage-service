class ImportLegacySchema < ActiveRecord::Migration[7.2]
  def change
    # ---- Legacy BL table ----
    create_table :bl, primary_key: :id_bl, id: :bigint do |t|
      t.bigint   :id_upload
      t.datetime :date_upload
      t.string   :numero_bl, limit: 9, null: false
      t.bigint   :id_client
      t.datetime :arrival_date
      t.integer  :freetime


      # container counts
      t.integer :nbre_20pieds_sec
      t.integer :nbre_40pieds_sec
      t.integer :nbre_20pieds_frigo
      t.integer :nbre_40pieds_frigo
      t.integer :nbre_20pieds_special
      t.integer :nbre_40pieds_special


      t.string  :statut
    end
    add_index :bl, :numero_bl
    add_index :bl, :arrival_date


    # ---- Legacy CLIENT table ----
    create_table :client, primary_key: :id_client, id: :bigint do |t|
      t.string :nom, limit: 60, null: false
      t.string :statut
      t.string :code_client, limit: 20
      t.string :nom_groupe, limit: 150
    end


    # ---- Legacy FACTURE table ----
    create_table :facture, primary_key: :id_facture, id: :bigint do |t|
      t.string   :reference, limit: 10, null: false
      t.string   :numero_bl, limit: 9, null: false
      t.decimal  :montant_facture, precision: 12, scale: 0, null: false
      t.string   :devise, limit: 6, default: 'XOF'
      t.string   :statut, limit: 10, null: false, default: 'init'
      t.datetime :created_at, null: false
      t.datetime :updated_at
    end
    add_index :facture, :reference, unique: true


    # ---- Legacy REMBOURSEMENT table ----
    create_table :remboursement, primary_key: :id_remboursement, id: :bigint do |t|
      t.string   :numero_bl, limit: 9, null: false
      t.string   :montant_demande, limit: 15
      t.string   :statut, limit: 10, default: 'PENDING'
      t.datetime :date_demande
    end
    add_index :remboursement, :numero_bl
  end
end
