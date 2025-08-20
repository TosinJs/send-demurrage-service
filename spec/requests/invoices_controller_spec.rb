# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "InvoicesController", type: :request do
  let(:json) { JSON.parse(response.body) }

  describe "GET /invoices/overdue" do
    let!(:overdue_invoice) do
      create(
        :invoice,
        due_date: 1.day.ago.to_date,
        status: "init"
      )
    end
    let!(:future_invoice) do
      create(
        :invoice,
        due_date: 2.days.from_now.to_date,
        status: "pending"
      )
    end

    it "returns a successful response" do
      get "/invoices/overdue", headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
    end

    it "returns only overdue invoices" do
      get "/invoices/overdue", headers: { 'ACCEPT' => 'application/json' }

      expect(json).to be_an(Array)
      expect(json.size).to eq(1)
      ids = json.map { |invoice| invoice["id"] }
      expect(ids).to include(overdue_invoice.id)
      expect(ids).not_to include(future_invoice.id)
    end
  end

  describe "POST /invoices/generate" do
    context "when there are overdue bills of lading" do
      let!(:overdue_bl) do  
        create(
          :bill_of_lading,  
          :overdue_today,
          containers_20ft_dry_count: 2,
          containers_40ft_dry_count: 1
        )
      end

      it "creates invoices via Demurrage::InvoiceGenerator and returns summary" do
        expect do
          post "/invoices/generate", headers: { 'ACCEPT' => 'application/json' }
        end.to change(Invoice, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json["message"]).to eq("Invoice generation completed.")
        expect(json["invoices"]).to be_an(Array)
        expect(json["invoices"].size).to eq(1)
        invoice_summary = json["invoices"].first
        expect(invoice_summary["bl_id"]).to eq(overdue_bl.number)
      end
    end

    context "when no bills are overdue" do
      it "does not create invoices and returns empty summary" do
        expect do
          post "/invoices/generate", headers: { 'ACCEPT' => 'application/json' }
        end.not_to change(Invoice, :count)

        expect(response).to have_http_status(:ok)
        expect(json["invoices"]).to eq([])
      end
    end
  end
end
