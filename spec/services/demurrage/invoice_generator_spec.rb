
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Demurrage::InvoiceGenerator do
  describe '.run' do
    let!(:fresh_bill) { create(:bill_of_lading, arrival_date: Date.current, free_time_days: 5) }

    context 'when no bills are overdue' do
      it 'creates no invoices' do
        expect { described_class.run }.not_to change(Invoice, :count)
      end

      it 'returns an empty array' do
        expect(described_class.run).to be_empty
      end
    end

    context 'when bills are overdue' do
      let!(:overdue_bill) { create(:bill_of_lading, :overdue_today, containers_20ft_dry_count: 2, containers_40ft_dry_count: 1) }

      it 'creates an invoice for each overdue bill without unpaid invoices' do
        expect { described_class.run }.to change(Invoice, :count).by(1)
      end

      it 'calculates the correct amount based on container count' do
        described_class.run
        invoice = Invoice.last
        total_containers = overdue_bill.containers_total
        expected_amount = total_containers * described_class::DEMURRAGE_RATE_USD
        expect(invoice.amount).to eq(expected_amount)
      end

      it 'sets the correct due date' do
        described_class.run
        invoice = Invoice.last
        expected_due_date = Time.current.to_date + described_class::INVOICE_DUE_DAYS.days
        expect(invoice.due_date).to eq(expected_due_date)
      end

      it 'skips bills with unpaid invoices' do
        create(:invoice, bill_of_lading: overdue_bill, status: 'open')
        expect { described_class.run }.not_to change(Invoice, :count)
      end

      it 'includes created invoices in the return value' do
        result = described_class.run
        expect(result).to be_an(Array)
        expect(result.size).to eq(1)
        expect(result.first).to be_an(Invoice)
      end
    end

    context 'when multiple bills are overdue' do
      let!(:overdue_bill) { create(:bill_of_lading, :overdue_today, containers_20ft_dry_count: 2, containers_40ft_dry_count: 1) }
      let!(:another_overdue_bill) { create(:bill_of_lading, :overdue_today, containers_20ft_reefer_count: 1) }

      it 'creates invoices for all overdue bills' do
        expect { described_class.run }.to change(Invoice, :count).by(2)
      end

      it 'returns all created invoices' do
        result = described_class.run
        expect(result.size).to eq(2)
      end
    end

    context 'when an error occurs during invoice creation' do
      let!(:overdue_bill) { create(:bill_of_lading, :overdue_today, containers_20ft_dry_count: 2, containers_40ft_dry_count: 1) }

      before do
        allow(Invoice).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'logs the error and continues processing' do
        expect(Rails.logger).to receive(:error).at_least(:once)
        expect { described_class.run }.not_to raise_error
      end
    end

    describe 'private methods' do
      describe '.create_invoice_for' do
        let(:bill) { create(:bill_of_lading, containers_20ft_dry_count: 3) }

        it 'creates an invoice with the correct attributes' do
          invoice = described_class.send(:create_invoice_for, bill)

          expect(invoice).to be_persisted
          expect(invoice.bill_of_lading_number).to eq(bill.number)
          expect(invoice.amount).to eq(bill.containers_total * described_class::DEMURRAGE_RATE_USD)
          expect(invoice.currency).to eq(described_class::CURRENCY)
          expect(invoice.status).to eq('open')
          expect(invoice.due_date).to be_present
          expect(invoice.reference).to be_present
        end
      end
    end
  end
end
