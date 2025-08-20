require "securerandom"

module Demurrage
  class InvoiceGenerator
    DEMURRAGE_RATE_USD = 80
    INVOICE_DUE_DAYS = 15
    CURRENCY = "USD"

    # Runs invoice generation and returns an array of invoices that were created
    def self.run
      created_invoices = []

      BillOfLading.overdue_today.find_each do |bill_of_lading|
        if bill_of_lading.invoices.where.not(status: "paid").exists?
          Rails.logger.info "Skipping BL ##{bill_of_lading.number}: unpaid invoice already exists"
          next
        end

        invoice = create_invoice_for(bill_of_lading)
        created_invoices << invoice if invoice.present?
      end

      created_invoices
    end

    private_class_method

    def self.create_invoice_for(bill_of_lading)
      amount = bill_of_lading.containers_total * DEMURRAGE_RATE_USD

      invoice = Invoice.create!(
        reference: SecureRandom.hex(5),
        bill_of_lading_number: bill_of_lading.number,
        amount: amount,
        currency: CURRENCY,
        due_date: Time.current.to_date + INVOICE_DUE_DAYS.days,
        status: "open",
        invoiced_at: Time.current
      )

      Rails.logger.info "Created Invoice ##{invoice.reference} for BL ##{bill_of_lading.number} (#{bill_of_lading.containers_total} containers, $#{amount})"

      invoice
    end
  end
end
