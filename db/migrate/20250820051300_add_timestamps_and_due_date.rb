class AddTimestampsAndDueDate < ActiveRecord::Migration[7.2]
  def change
    # ------------- Timestamps ----------------
    %i[
      bill_of_ladings
      customers
      refund_requests
      invoices
    ].each do |table|
      unless column_exists?(table, :created_at) && column_exists?(table, :updated_at)
        add_timestamps table, null: true
      end
    end

    # ------------- due_date ------------------
    add_column :invoices, :due_date, :date unless column_exists?(:invoices, :due_date)

    reversible do |dir|
      dir.up do
        # -------- Backfill due_date ----------
        execute <<~SQL.squish
          UPDATE invoices
          SET due_date = DATE_ADD(created_at, INTERVAL 15 DAY);
        SQL

        change_column_null :invoices, :due_date, false
      end
    end
  end
end
