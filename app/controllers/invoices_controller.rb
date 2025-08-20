class InvoicesController < ApplicationController
  def overdue
    @invoices = Invoice.overdue.includes(bill_of_lading: :customer)
    render json: @invoices, each_serializer: InvoiceSerializer
  end

  # Generates demurrage invoices and returns a summary of what was created
  def generate
    invoices = Demurrage::InvoiceGenerator.run

    summary = invoices.map do |invoice|
      {
        bl_id: invoice.bill_of_lading_number,
        invoice_id: invoice.id,
        customer_name: invoice.bill_of_lading.customer.name,
        amount: invoice.amount,
        currency: invoice.currency
      }
    end

    render json: { message: "Invoice generation completed.", invoices: summary }, status: :ok
  end
end
