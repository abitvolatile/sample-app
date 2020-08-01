require 'spec_helper'

describe Spree::TaxCategory, type: :model do
  context 'default tax category' do
    let(:tax_category) { create(:tax_category) }
    let(:new_tax_category) { create(:tax_category) }

    before do
      tax_category.update_column(:is_default, true)
    end

    it 'undefaults the previous default tax category' do
      new_tax_category.update(is_default: true)
      expect(new_tax_category.is_default).to be true

      tax_category.reload
      expect(tax_category.is_default).to be false
    end

    it 'undefaults the previous default tax category except when updating the existing default tax category' do
      tax_category.update_column(:description, 'Updated description')

      tax_category.reload
      expect(tax_category.is_default).to be true
    end
  end
end
