class AddForeignKeyConstraints < ActiveRecord::Migration[7.2]
  def change
    # ----- BillOfLading.number uniqueness -----
    remove_index :bill_of_ladings, :number if index_exists?(:bill_of_ladings, :number)
    add_index :bill_of_ladings, :number, unique: true, name: "index_bill_of_ladings_on_number"

    # ----- FK: invoices → bill_of_ladings -----
    add_index :invoices, :bill_of_lading_number unless index_exists?(:invoices, :bill_of_lading_number)
    add_foreign_key :invoices, :bill_of_ladings,
                    column: :bill_of_lading_number,
                    primary_key: :number,
                    name: "fk_invoices_on_bill_of_lading_number"
    change_column_null :invoices, :bill_of_lading_number, false

    # ----- FK: bill_of_ladings → customers -----
    add_index :bill_of_ladings, :customer_id unless index_exists?(:bill_of_ladings, :customer_id)
    add_foreign_key :bill_of_ladings, :customers,
                    column: :customer_id,
                    primary_key: :id,
                    name: "fk_bill_of_ladings_on_customer_id"

    # ----- FK: refund_requests → bill_of_ladings -----
    add_foreign_key :refund_requests, :bill_of_ladings,
                    column: :bill_of_lading_number,
                    primary_key: :number,
                    name: "fk_refund_requests_on_bill_of_lading_number"
    change_column_null :refund_requests, :bill_of_lading_number, false
  end
end
