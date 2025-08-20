# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:bill_of_ladings).inverse_of(:customer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    
    it 'validates uniqueness of code when present' do
      create(:customer, code: 'UNIQUE123')
      expect(build(:customer, code: 'UNIQUE123')).to validate_uniqueness_of(:code).case_insensitive
    end
    
    it { is_expected.to allow_value(nil).for(:code) }
  end
end
