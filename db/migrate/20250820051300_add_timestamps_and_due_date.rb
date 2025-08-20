class AddTimestampsAndDueDate < ActiveRecord::Migration[7.2]
  def change
    # ------------- Timestamps ----------------
    add_timestamps :bill_of_ladings,  null: true unless column_exists?(:bill_of_ladings, :created_at)
    add_timestamps :customers,        null: true unless column_exists?(:customers, :created_at)
    add_timestamps :refund_requests,  null: true unless column_exists?(:refund_requests, :created_at)

    unless column_exists?(:invoices, :created_at)
      add_timestamps :invoices, null: true
    end

    # ------------- due_date ------------------
    add_column :invoices, :due_date, :date unless column_exists?(:invoices, :due_date)

    reversible do |dir|
      dir.up do
        # -------- Backfill due_date ----------
        execute <<~SQL.squish
          UPDATE invoices
          SET due_date = COALESCE(
            DATE_ADD(invoiced_at, INTERVAL 15 DAY),
            DATE_ADD(created_at,   INTERVAL 15 DAY)
          )
        SQL

        change_column_null :invoices, :due_date, false
      end
    end
  end
end
