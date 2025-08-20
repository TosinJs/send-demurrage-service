class RenameAndCleanLegacyTables < ActiveRecord::Migration[7.2]
  # This migration cleans up the legacy schema that was imported in
  # 20250820034719_import_legacy_schema.rb.

  def change
    # ------------------- Table renames -------------------
    rename_table :bl,            :bill_of_ladings
    rename_table :client,        :customers
    rename_table :facture,       :invoices
    rename_table :remboursement, :refund_requests

    # ---------------- Column renames ---------------------
    # bill_of_ladings
    change_table :bill_of_ladings do |t|
      t.rename :id_bl,                  :id
      t.rename :numero_bl,              :number
      t.rename :id_client,              :customer_id
      t.rename :freetime,               :free_time_days
      t.rename :nbre_20pieds_sec,       :containers_20ft_dry_count
      t.rename :nbre_40pieds_sec,       :containers_40ft_dry_count
      t.rename :nbre_20pieds_frigo,     :containers_20ft_reefer_count
      t.rename :nbre_40pieds_frigo,     :containers_40ft_reefer_count
      t.rename :nbre_20pieds_special,   :containers_20ft_special_count
      t.rename :nbre_40pieds_special,   :containers_40ft_special_count
    end

    # customers
    change_table :customers do |t|
      t.rename :id_client,  :id
      t.rename :nom,        :name
      t.rename :code_client,:code
    end

    # invoices
    change_table :invoices do |t|
      t.rename :id_facture,       :id
      t.rename :numero_bl,        :bill_of_lading_number
      t.rename :montant_facture,  :amount
      t.rename :devise,           :currency
      t.rename :statut,           :status
      t.rename :date_facture,     :invoiced_at
    end

    # refund_requests
    change_table :refund_requests do |t|
      t.rename :id_remboursement, :id
      t.rename :numero_bl,        :bill_of_lading_number
      t.rename :montant_demande,  :requested_amount
      t.rename :statut,           :status
    end
  end
end