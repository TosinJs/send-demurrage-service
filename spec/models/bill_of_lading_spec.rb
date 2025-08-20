# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillOfLading, type: :model do
  let(:customer) { create(:customer) }
  let(:valid_attributes) do
    {
      number: 'BL12345',  # 7 chars - within 9 char limit
      customer: customer,
      arrival_date: Date.current,
      free_time_days: 5
    }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer).inverse_of(:bill_of_ladings) }
    it { is_expected.to have_many(:invoices).with_foreign_key(:bill_of_lading_number).inverse_of(:bill_of_lading) }
  end

  describe 'validations' do
    subject { build(:bill_of_lading) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_uniqueness_of(:number).case_insensitive }
    it { is_expected.to validate_presence_of(:arrival_date) }

    it do
      is_expected.to validate_numericality_of(:free_time_days)
        .is_greater_than_or_equal_to(0)
        .allow_nil
    end

    %i[
      containers_20ft_dry_count
      containers_40ft_dry_count
      containers_20ft_reefer_count
      containers_40ft_reefer_count
      containers_20ft_special_count
      containers_40ft_special_count
    ].each do |column|
      it { is_expected.to validate_numericality_of(column).is_greater_than_or_equal_to(0).allow_nil }
    end
  end

  describe 'instance methods' do
    describe '#containers_total' do
      subject(:bill_of_lading) { build(:bill_of_lading) }

      it 'returns 0 when no containers' do
        expect(bill_of_lading.containers_total).to eq(0)
      end

      it 'sums up all container counts' do
        bill_of_lading.containers_20ft_dry_count = 2
        bill_of_lading.containers_40ft_dry_count = 1
        bill_of_lading.containers_20ft_reefer_count = 3

        expect(bill_of_lading.containers_total).to eq(6)
      end
    end
  end

  describe 'scopes' do
    describe '.overdue_today' do
      # BL with due_date == today should be returned
      let!(:overdue) { create(:bill_of_lading, arrival_date: Date.current - 3.days, free_time_days: 3) }
      # Due date in the future should not be returned
      let!(:fresh)   { create(:bill_of_lading, arrival_date: Date.current - 1.day, free_time_days: 5) }
      let!(:ignored) { create(:bill_of_lading, arrival_date: 1.day.ago, free_time_days: nil) }

      it 'returns BLs where arrival_date + free_time_days equals today' do
        result = described_class.overdue_today

        expect(result).to include(overdue)
        expect(result).not_to include(fresh)
        expect(result).not_to include(ignored)
      end
    end
  end
end
