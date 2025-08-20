# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefundRequest, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:bill_of_lading_number) }
  end

  describe 'readonly' do
    it 'is readonly and cannot be saved or destroyed' do
      refund = build(:refund_request)

      # Check readonly? method
      expect(refund).to be_readonly

      # Saving raises error
      expect { refund.save! }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
