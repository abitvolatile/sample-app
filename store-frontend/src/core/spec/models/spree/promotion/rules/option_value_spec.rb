require 'spec_helper'

describe Spree::Promotion::Rules::OptionValue do
  let(:rule) { described_class.new }

  describe '#preferred_eligible_values' do
    subject { rule.preferred_eligible_values }

    it 'assigns a nicely formatted hash' do
      rule.preferred_eligible_values = Hash['5' => '1,2', '6' => '1']
      expect(subject).to eq Hash[5 => [1, 2], 6 => [1]]
    end
  end

  describe '#applicable?' do
    subject { rule.applicable?(promotable) }

    context 'when promotable is an order' do
      let(:promotable) { Spree::Order.new }

      it { is_expected.to be true }
    end

    context 'when promotable is not an order' do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe '#eligible?' do
    subject { rule.eligible?(promotable) }

    let(:variant) { create :variant }
    let(:line_item) { create :line_item, variant: variant }
    let(:promotable) { line_item.order }

    context 'when there are any applicable line items' do
      before do
        rule.preferred_eligible_values = Hash[variant.product.id => [
          variant.option_values.pluck(:id).first
        ]]
      end

      it { is_expected.to be true }
    end

    context 'when there are no applicable line items' do
      before do
        rule.preferred_eligible_values = Hash[99 => [99]]
      end

      it { is_expected.to be false }
    end
  end

  describe '#actionable?' do
    subject { rule.actionable?(line_item) }

    let(:line_item) { create :line_item }
    let(:option_value_blue) do
      create(
        :option_value,
        name: 'Blue',
        presentation: 'Blue',
        option_type: create(
          :option_type,
          name: 'foo-colour',
          presentation: 'Colour'
        )
      )
    end
    let(:option_value_medium) do
      create(
        :option_value,
        name: 'Medium',
        presentation: 'M'
      )
    end

    before do
      line_item.variant.option_values << option_value_blue
      rule.preferred_eligible_values = Hash[product_id => option_value_ids]
    end

    context 'when the line item has the correct product' do
      let(:product_id) { line_item.product.id }

      context 'when all of the option values match' do
        let(:option_value_ids) { [option_value_blue.id] }

        it { is_expected.to be true }
      end

      context 'when not all of the option values match' do
        let(:option_value_ids) { [option_value_blue.id, option_value_medium.id] }

        it { is_expected.to be true }
      end
    end

    context "when the line item's product doesn't match" do
      let(:product_id) { 99 }
      let(:option_value_ids) { [99] }

      it { is_expected.to be false }
    end
  end
end
