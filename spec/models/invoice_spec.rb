# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:bill_of_lading).with_primary_key(:number).inverse_of(:invoices) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_presence_of(:bill_of_lading_number) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:invoiced_at) }
  end

  describe 'scopes' do
    describe '.overdue' do
      let!(:overdue_invoice) { create(:invoice, due_date: Date.current - 1.day, status: 'init') }
      let!(:paid_invoice)    { create(:invoice, due_date: Date.current - 10.days, status: 'paid') }
      let!(:future_invoice)  { create(:invoice, due_date: Date.current + 5.days, status: 'init') }

      it 'returns unpaid invoices whose due_date has passed' do
        expect(described_class.overdue).to include(overdue_invoice)
        expect(described_class.overdue).not_to include(paid_invoice)
        expect(described_class.overdue).not_to include(future_invoice)
      end
    end
  end
end
