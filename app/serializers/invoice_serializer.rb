class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :reference, :bill_of_lading_number, :amount, :currency,
             :due_date, :status, :invoiced_at, :bill_of_lading

  # Embed limited Bill of Lading data to avoid extra queries
  def bill_of_lading
    bol = object.bill_of_lading
    {
      number: bol.number,
      arrival_date: bol.arrival_date,
      customer_name: bol.customer&.name
    }
  end
end
