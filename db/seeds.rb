# frozen_string_literal: true

# Sample seed data for manual testing of demurrage service.
# Run with:
#   bin/rails db:setup   # on fresh DB (creates + seeds)
#   bin/rails db:seed    # on existing DB
# The script is idempotent – running multiple times will not create duplicates.

require 'securerandom'

ActiveRecord::Base.transaction do
  puts "Seeding sample data…"

  # ---------- Customers ----------
  customers = [
    { name: "ACME Shipping", code: "ACM" },
    { name: "Globex Corp",   code: "GLX" },
    { name: "Initech",       code: "INT" },
    { name: "Umbrella Co",    code: "UMB" },
    { name: "Soylent Ltd",   code: "SOY" }
  ].map do |attrs|
    Customer.find_or_create_by!(code: attrs[:code]) { |c| c.name = attrs[:name] }
  end

  # ---------- Bill of Ladings ----------
  bols = []
  customers.each do |customer|
    2.times do
      number = loop do
        n = "BL#{rand(1_000_0000).to_s.rjust(7, '0')}"[0..8]
        break n unless BillOfLading.exists?(number: n)
      end

      arrival_date = rand(10..30).days.ago.to_date
      free_time_days = rand(3..7)

      bols << BillOfLading.find_or_create_by!(number: number) do |bl|
        bl.customer = customer
        bl.arrival_date = arrival_date
        bl.free_time_days = free_time_days
        # Random container counts
        bl.containers_20ft_dry_count     = rand(0..3)
        bl.containers_40ft_dry_count     = rand(0..2)
        bl.containers_20ft_reefer_count  = rand(0..2)
        bl.containers_40ft_reefer_count  = rand(0..1)
        bl.containers_20ft_special_count = rand(0..1)
        bl.containers_40ft_special_count = rand(0..1)
        bl.statut = 'active'
      end
    end
  end

  # ---------- Invoices ----------
  bols.each do |bl|
    # 50% chance BL already invoiced
    next unless rand < 0.5

    reference = loop do
      ref = SecureRandom.hex(5)
      break ref unless Invoice.exists?(reference: ref)
    end

    containers_total = bl.containers_total
    amount = containers_total * 80

    # Roughly half the invoices should already be overdue so that
    # GET /invoices/overdue always returns data.
    overdue = rand < 0.5
    invoiced_at_time = overdue ? rand(20..40).days.ago : Time.current
    due_date_value   = overdue ? rand(5..15).days.ago.to_date : (invoiced_at_time.to_date + 15.days)
    status_value     = overdue ? 'open' : %w[paid cancelled].sample

    Invoice.find_or_create_by!(reference: reference) do |inv|
      inv.bill_of_lading         = bl
      inv.bill_of_lading_number  = bl.number
      inv.amount                = amount
      inv.currency              = 'USD'
      inv.invoiced_at           = invoiced_at_time
      inv.due_date              = due_date_value
      inv.status                = status_value
    end
  end

  puts "Seeding completed.\nCustomers: #{Customer.count}, BLs: #{BillOfLading.count}, Invoices: #{Invoice.count}"
end
