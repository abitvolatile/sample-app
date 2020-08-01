require 'spec_helper'

describe Spree::Variant, type: :model do
  let!(:variant) { create(:variant) }
  let(:master_variant) { create(:master_variant) }

  it_behaves_like 'default_price'

  context 'sorting' do
    it 'responds to set_list_position' do
      expect(variant.respond_to?(:set_list_position)).to eq(true)
    end
  end

  context 'validations' do
    it 'validates price is greater than 0' do
      variant.price = -1
      expect(variant).to be_invalid
    end

    it 'validates price is 0' do
      variant.price = 0
      expect(variant).to be_valid
    end
  end

  context 'after create' do
    let!(:product) { create(:product) }

    it 'propagate to stock items' do
      expect_any_instance_of(Spree::StockLocation).to receive(:propagate_variant)
      create(:variant, product: product)
    end

    context 'stock location has disable propagate all variants' do
      before { Spree::StockLocation.update_all propagate_all_variants: false }

      it 'propagate to stock items' do
        expect_any_instance_of(Spree::StockLocation).not_to receive(:propagate_variant)
        product.variants.create
      end
    end

    describe 'mark_master_out_of_stock' do
      before do
        product.master.stock_items.first.set_count_on_hand(5)
      end

      context 'when product is created without variants but with stock' do
        it { expect(product.master).to be_in_stock }
      end

      context 'when a variant is created' do
        let!(:new_variant) { create(:variant, product: product) }

        it { expect(product.master).not_to be_in_stock }
      end
    end
  end

  describe 'scope' do
    describe '.eligible' do
      context 'when only master variants' do
        let!(:product_1) { create(:product) }
        let!(:product_2) { create(:product) }

        it 'returns all of them' do
          expect(Spree::Variant.eligible).to include(product_1.master)
          expect(Spree::Variant.eligible).to include(product_2.master)
        end
      end

      context 'when product has more than 1 variant' do
        let!(:product) { create(:product) }
        let!(:variant) { create(:variant, product: product) }

        it 'filters master variant out' do
          expect(Spree::Variant.eligible).to include(variant)
          expect(Spree::Variant.eligible).not_to include(product.master)
        end
      end
    end

    describe '.not_discontinued' do
      context 'when discontinued' do
        let!(:discontinued_variant) { create(:variant, discontinue_on: Time.current - 1.day) }

        it { expect(Spree::Variant.not_discontinued).not_to include(discontinued_variant) }
      end

      context 'when not discontinued' do
        let!(:variant_2) { create(:variant, discontinue_on: Time.current + 1.day) }

        it { expect(Spree::Variant.not_discontinued).to include(variant_2) }
      end

      context 'when discontinue_on not present' do
        let!(:variant_2) { create(:variant, discontinue_on: nil) }

        it { expect(Spree::Variant.not_discontinued).to include(variant_2) }
      end
    end

    describe '.not_deleted' do
      context 'when deleted' do
        let!(:deleted_variant) { create(:variant, deleted_at: Time.current) }

        it { expect(Spree::Variant.not_deleted).not_to include(deleted_variant) }
      end

      context 'when not deleted' do
        let!(:variant_2) { create(:variant, deleted_at: nil) }

        it { expect(Spree::Variant.not_deleted).to include(variant_2) }
      end
    end

    describe '.for_currency_and_available_price_amount' do
      let(:currency) { 'EUR' }

      context 'when price with currency present' do
        context 'when price has amount' do
          let!(:price_1) { create(:price, currency: currency, variant: variant, amount: 10) }

          it { expect(Spree::Variant.for_currency_and_available_price_amount(currency)).to include(variant) }
        end

        context 'when price do not have amount' do
          let!(:price_1) { create(:price, currency: currency, variant: variant, amount: nil) }

          it { expect(Spree::Variant.for_currency_and_available_price_amount(currency)).not_to include(variant) }
        end
      end

      context 'when price with currency not present' do
        let!(:unavailable_currency) { 'INR' }

        context 'when price has amount' do
          let!(:price_1) { create(:price, currency: unavailable_currency, variant: variant, amount: 10) }

          it { expect(Spree::Variant.for_currency_and_available_price_amount(currency)).not_to include(variant) }
        end

        context 'when price do not have amount' do
          let!(:price_1) { create(:price, currency: unavailable_currency, variant: variant, amount: nil) }

          it { expect(Spree::Variant.for_currency_and_available_price_amount(currency)).not_to include(variant) }
        end
      end

      context 'when multiple prices for same currency present' do
        let!(:price_1) { create(:price, currency: currency, variant: variant) }
        let!(:price_2) { create(:price, currency: currency, variant: variant) }

        it 'does not duplicate variant' do
          expect(Spree::Variant.for_currency_and_available_price_amount(currency)).to eq([variant])
        end
      end

      context 'when currency parameter is nil' do
        let!(:price_1) { create(:price, currency: currency, variant: variant, amount: 10) }

        before { Spree::Config[:currency] = currency }

        it { expect(Spree::Variant.for_currency_and_available_price_amount).to include(variant) }
      end
    end

    describe '.active' do
      let!(:variants) { [variant] }
      let!(:currency) { 'EUR' }

      before do
        allow(Spree::Variant).to receive(:not_discontinued).and_return(variants)
        allow(variants).to receive(:not_deleted).and_return(variants)
        allow(variants).to receive(:for_currency_and_available_price_amount).with(currency).and_return(variants)
      end

      it 'finds not_discontinued variants' do
        expect(Spree::Variant).to receive(:not_discontinued).and_return(variants)
        Spree::Variant.active(currency)
      end

      it 'finds not_deleted variants' do
        expect(variants).to receive(:not_deleted).and_return(variants)
        Spree::Variant.active(currency)
      end

      it 'finds variants for_currency_and_available_price_amount' do
        expect(variants).to receive(:for_currency_and_available_price_amount).with(currency).and_return(variants)
        Spree::Variant.active(currency)
      end

      it { expect(Spree::Variant.active(currency)).to eq(variants) }
    end
  end

  context 'product has other variants' do
    describe 'option value accessors' do
      before do
        @multi_variant = FactoryBot.create :variant, product: variant.product
        variant.product.reload
      end

      let(:multi_variant) { @multi_variant }

      it 'sets option value' do
        expect(multi_variant.option_value('media_type')).to be_nil

        multi_variant.set_option_value('media_type', 'DVD')
        expect(multi_variant.option_value('media_type')).to eql 'DVD'

        multi_variant.set_option_value('media_type', 'CD')
        expect(multi_variant.option_value('media_type')).to eql 'CD'
      end

      it 'does not duplicate associated option values when set multiple times' do
        multi_variant.set_option_value('media_type', 'CD')

        expect do
          multi_variant.set_option_value('media_type', 'DVD')
        end.not_to change(multi_variant.option_values, :count)

        expect do
          multi_variant.set_option_value('coolness_type', 'awesome')
        end.to change(multi_variant.option_values, :count).by(1)
      end
    end

    context 'product has other variants' do
      describe 'option value accessors' do
        before do
          @multi_variant = create(:variant, product: variant.product)
          variant.product.reload
        end

        let(:multi_variant) { @multi_variant }

        it 'sets option value' do
          expect(multi_variant.option_value('media_type')).to be_nil

          multi_variant.set_option_value('media_type', 'DVD')
          expect(multi_variant.option_value('media_type')).to eql 'DVD'

          multi_variant.set_option_value('media_type', 'CD')
          expect(multi_variant.option_value('media_type')).to eql 'CD'
        end

        it 'does not duplicate associated option values when set multiple times' do
          multi_variant.set_option_value('media_type', 'CD')

          expect do
            multi_variant.set_option_value('media_type', 'DVD')
          end.not_to change(multi_variant.option_values, :count)

          expect do
            multi_variant.set_option_value('coolness_type', 'awesome')
          end.to change(multi_variant.option_values, :count).by(1)
        end
      end
    end
  end

  context '#cost_price=' do
    it 'uses LocalizedNumber.parse' do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.cost_price = '1,599.99'
    end
  end

  context '#price=' do
    it 'uses LocalizedNumber.parse' do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.price = '1,599.99'
    end
  end

  context '#weight=' do
    it 'uses LocalizedNumber.parse' do
      expect(Spree::LocalizedNumber).to receive(:parse).with('1,599.99')
      subject.weight = '1,599.99'
    end
  end

  context '#currency' do
    it 'returns the globally configured currency' do
      expect(variant.currency).to eql 'USD'
    end
  end

  context '#display_amount' do
    it 'returns a Spree::Money' do
      variant.price = 21.22
      expect(variant.display_amount.to_s).to eql '$21.22'
    end
  end

  context '#cost_currency' do
    context 'when cost currency is nil' do
      before { variant.cost_currency = nil }

      it 'populates cost currency with the default value on save' do
        variant.save!
        expect(variant.cost_currency).to eql 'USD'
      end
    end
  end

  describe '.price_in' do
    subject { variant.price_in(currency).display_amount }

    before do
      variant.prices << create(:price, variant: variant, currency: 'EUR', amount: 33.33)
    end

    context 'when currency is not specified' do
      let(:currency) { nil }

      it 'returns 0' do
        expect(subject.to_s).to eql '$0.00'
      end
    end

    context 'when currency is EUR' do
      let(:currency) { 'EUR' }

      it 'returns the value in the EUR' do
        expect(subject.to_s).to eql '€33.33'
      end
    end

    context 'when currency is USD' do
      let(:currency) { 'USD' }

      it 'returns the value in the USD' do
        expect(subject.to_s).to eql '$19.99'
      end
    end
  end

  describe '.amount_in' do
    subject { variant.amount_in(currency) }

    before do
      variant.prices << create(:price, variant: variant, currency: 'EUR', amount: 33.33)
    end

    context 'when currency is not specified' do
      let(:currency) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when currency is EUR' do
      let(:currency) { 'EUR' }

      it 'returns the value in the EUR' do
        expect(subject).to eq(33.33)
      end
    end

    context 'when currency is USD' do
      let(:currency) { 'USD' }

      it 'returns the value in the USD' do
        expect(subject).to eq(19.99)
      end
    end
  end

  # Regression test for #2432
  describe 'options_text' do
    let!(:variant) { build(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      # Order bar than foo
      variant.option_values << create(:option_value, name: 'Foo', presentation: 'Foo', option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type'))
      variant.option_values << create(:option_value, name: 'Bar', presentation: 'Bar', option_type: create(:option_type, position: 1, name: 'Bar Type', presentation: 'Bar Type'))
      variant.save
    end

    it 'orders by bar than foo' do
      expect(variant.options_text).to eql 'Bar Type: Bar, Foo Type: Foo'
    end
  end

  describe 'exchange_name' do
    let!(:variant) { build(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value,                                                      name: 'Foo',
                                                                                                          presentation: 'Foo',
                                                                                                          option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type'))
      variant.save
    end

    context 'master variant' do
      it 'returns name' do
        expect(master.exchange_name).to eql master.name
      end
    end

    context 'variant' do
      it 'returns options text' do
        expect(variant.exchange_name).to eql 'Foo Type: Foo'
      end
    end
  end

  describe 'exchange_name' do
    let!(:variant) { build(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value,                                                      name: 'Foo',
                                                                                                          presentation: 'Foo',
                                                                                                          option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type'))
      variant.save
    end

    context 'master variant' do
      it 'returns name' do
        expect(master.exchange_name).to eql master.name
      end
    end

    context 'variant' do
      it 'returns options text' do
        expect(variant.exchange_name).to eql 'Foo Type: Foo'
      end
    end
  end

  describe 'descriptive_name' do
    let!(:variant) { build(:variant, option_values: []) }
    let!(:master) { create(:master_variant) }

    before do
      variant.option_values << create(:option_value,                                                      name: 'Foo',
                                                                                                          presentation: 'Foo',
                                                                                                          option_type: create(:option_type, position: 2, name: 'Foo Type', presentation: 'Foo Type'))
      variant.save
    end

    context 'master variant' do
      it 'returns name with Master identifier' do
        expect(master.descriptive_name).to eql master.name + ' - Master'
      end
    end

    context 'variant' do
      it 'returns options text with name' do
        expect(variant.descriptive_name).to eql variant.name + ' - Foo Type: Foo'
      end
    end
  end

  # Regression test for #2744
  describe 'set_position' do
    it 'sets variant position after creation' do
      variant = create(:variant)
      expect(variant.position).not_to be_nil
    end
  end

  describe '#in_stock?' do
    before do
      Spree::Config.track_inventory_levels = true
    end

    context 'when stock_items are not backorderable' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
      end

      context 'when stock_items in stock' do
        before do
          variant.stock_items.first.update_column(:count_on_hand, 10)
        end

        it 'returns true if stock_items in stock' do
          expect(variant.in_stock?).to be true
        end
      end

      context 'when stock_items out of stock' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
          allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
        end

        it 'return false if stock_items out of stock' do
          expect(variant.in_stock?).to be false
        end
      end
    end

    describe '#can_supply?' do
      it 'calls out to quantifier' do
        expect(Spree::Stock::Quantifier).to receive(:new).and_return(quantifier = double)
        expect(quantifier).to receive(:can_supply?).with(10)
        variant.can_supply?(10)
      end
    end

    context 'when stock_items are backorderable' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: true)
      end

      context 'when stock_items out of stock' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
        end

        it 'in_stock? returns false' do
          expect(variant.in_stock?).to be false
        end

        it 'can_supply? return true' do
          expect(variant.can_supply?).to be true
        end
      end
    end
  end

  describe '#is_backorderable' do
    subject { variant.is_backorderable? }

    let(:variant) { build(:variant) }

    it 'invokes Spree::Stock::Quantifier' do
      expect_any_instance_of(Spree::Stock::Quantifier).to receive(:backorderable?).and_return(true)
      subject
    end
  end

  describe '#purchasable?' do
    context 'when stock_items are not backorderable' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
      end

      context 'when stock_items in stock' do
        before do
          variant.stock_items.first.update_column(:count_on_hand, 10)
        end

        it 'returns true if stock_items in stock' do
          expect(variant.purchasable?).to be true
        end
      end

      context 'when stock_items out of stock' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
        end

        it 'return false if stock_items out of stock' do
          expect(variant.purchasable?).to be false
        end
      end
    end

    context 'when stock_items are out of stock' do
      before do
        allow_any_instance_of(Spree::StockItem).to receive_messages(count_on_hand: 0)
      end

      context 'when stock item are backorderable' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: true)
        end

        it 'returns true if stock_items are backorderable' do
          expect(variant.purchasable?).to be true
        end
      end

      context 'when stock_items are not backorderable' do
        before do
          allow_any_instance_of(Spree::StockItem).to receive_messages(backorderable: false)
        end

        it 'return false if stock_items are not backorderable' do
          expect(variant.purchasable?).to be false
        end
      end
    end
  end

  describe '#total_on_hand' do
    it 'is infinite if track_inventory_levels is false' do
      Spree::Config[:track_inventory_levels] = false
      expect(build(:variant).total_on_hand).to eql(Float::INFINITY)
    end

    it 'matches quantifier total_on_hand' do
      variant = build(:variant)
      expect(variant.total_on_hand).to eq(Spree::Stock::Quantifier.new(variant).total_on_hand)
    end
  end

  describe '#tax_category' do
    context 'when tax_category is nil' do
      let(:product) { build(:product) }
      let(:variant) { build(:variant, product: product, tax_category_id: nil) }

      it 'returns the parent products tax_category' do
        expect(variant.tax_category).to eq(product.tax_category)
      end
    end

    context 'when tax_category is set' do
      let(:tax_category) { create(:tax_category) }
      let(:variant) { build(:variant, tax_category: tax_category) }

      it 'returns the tax_category set on itself' do
        expect(variant.tax_category).to eq(tax_category)
      end
    end
  end

  describe 'touching' do
    it 'updates a product' do
      variant.product.update_column(:updated_at, 1.day.ago)
      variant.touch
      expect(variant.product.reload.updated_at).to be_within(3.seconds).of(Time.current)
    end

    it 'clears the in_stock cache key' do
      expect(Rails.cache).to receive(:delete).with(variant.send(:in_stock_cache_key))
      variant.touch
    end
  end

  describe '#should_track_inventory?' do
    it 'does not track inventory when global setting is off' do
      Spree::Config[:track_inventory_levels] = false

      expect(build(:variant).should_track_inventory?).to eq(false)
    end

    it 'does not track inventory when variant is turned off' do
      Spree::Config[:track_inventory_levels] = true

      expect(build(:on_demand_variant).should_track_inventory?).to eq(false)
    end

    it 'tracks inventory when global and variant are on' do
      Spree::Config[:track_inventory_levels] = true

      expect(build(:variant).should_track_inventory?).to eq(true)
    end
  end

  describe 'deleted_at scope' do
    before { variant.destroy && variant.reload }

    it 'has a price if deleted' do
      variant.price = 10
      expect(variant.price).to eq(10)
    end
  end

  describe 'stock movements' do
    let!(:movement) { create(:stock_movement, stock_item: variant.stock_items.first) }

    it 'builds out collection just fine through stock items' do
      expect(variant.stock_movements.to_a).not_to be_empty
    end
  end

  describe 'in_stock scope' do
    it 'returns all in stock variants' do
      in_stock_variant = create(:variant)
      create(:variant) # out_of_stock_variant

      in_stock_variant.stock_items.first.update_column(:count_on_hand, 10)

      expect(Spree::Variant.in_stock).to eq [in_stock_variant]
    end
  end

  context '#volume' do
    let(:variant_zero_width) { create(:variant, width: 0) }
    let(:variant) { create(:variant) }

    it 'is zero if any dimension parameter is zero' do
      expect(variant_zero_width.volume).to eq 0
    end

    it 'return the volume if the dimension parameters are different of zero' do
      volume_expected = variant.width * variant.depth * variant.height
      expect(variant.volume).to eq volume_expected
    end
  end

  context '#dimension' do
    let(:variant) { create(:variant) }

    it 'return the dimension if the dimension parameters are different of zero' do
      dimension_expected = variant.width + variant.depth + variant.height
      expect(variant.dimension).to eq dimension_expected
    end
  end

  context '#discontinue!' do
    let(:variant) { create(:variant) }

    it 'sets the discontinued' do
      variant.discontinue!
      variant.reload
      expect(variant.discontinued?).to be(true)
    end

    it 'changes updated_at' do
      Timecop.scale(1000) do
        expect { variant.discontinue! }.to change(variant.reload, :updated_at)
      end
    end
  end

  context '#discontinued?' do
    let(:variant_live) { build(:variant) }
    let(:variant_discontinued) { build(:variant, discontinue_on: Time.now - 1.day) }

    it 'is false' do
      expect(variant_live.discontinued?).to be(false)
    end

    it 'is true' do
      expect(variant_discontinued.discontinued?).to be(true)
    end
  end

  describe '#available?' do
    let(:variant) { create(:variant) }

    context 'when discontinued' do
      before do
        variant.discontinue_on = Time.current - 1.day
      end

      context 'when product is available' do
        before do
          allow(variant.product).to receive(:available?).and_return(true)
        end

        it { expect(variant.available?).to be(false) }
      end

      context 'when product is not available' do
        before do
          allow(variant.product).to receive(:available?).and_return(false)
        end

        it { expect(variant.available?).to be(false) }
      end
    end

    context 'when not discontinued' do
      before do
        variant.discontinue_on = Time.current + 1.day
      end

      context 'when product is available' do
        before do
          allow(variant.product).to receive(:available?).and_return(true)
        end

        it { expect(variant.available?).to be(true) }
      end

      context 'when product is not available' do
        before do
          allow(variant.product).to receive(:available?).and_return(false)
        end

        it { expect(variant.available?).to be(false) }
      end
    end
  end

  describe '#check_price' do
    let(:variant) { create(:variant) }
    let(:variant2) { create(:variant) }

    context 'require_master_price set false' do
      before { Spree::Config.set(require_master_price: false) }

      context 'price present and currency present' do
        it { expect(variant.send(:check_price)).to be(nil) }
      end

      context 'price present and currency nil' do
        before { variant.currency = nil }

        it { expect(variant.send(:check_price)).to be(Spree::Config[:currency]) }
      end

      context 'price nil and currency present' do
        before { variant.price = nil }

        it { expect(variant.send(:check_price)).to be(nil) }
      end

      context 'price nil and currency nil' do
        before { variant.price = nil }

        it { expect(variant.send(:check_price)).to be(nil) }
      end
    end

    context 'require_master_price set true' do
      before { Spree::Config.set(require_master_price: true) }

      context 'price present and currency present' do
        it { expect(variant.send(:check_price)).to be(nil) }
      end

      context 'price present and currency nil' do
        before { variant.currency = nil }

        it { expect(variant.send(:check_price)).to be(Spree::Config[:currency]) }
      end

      context 'product and master_variant present and equal' do
        context 'price nil and currency present' do
          before { variant.price = nil }

          it { expect(variant.send(:check_price)).to be(nil) }

          context 'check variant price' do
            before { variant.send(:check_price) }

            it { expect(variant.price).to eq(variant.product.master.price) }
          end
        end

        context 'price nil and currency nil' do
          before do
            variant.price = nil
            variant.send(:check_price)
          end

          it { expect(variant.price).to eq(variant.product.master.price) }
          it { expect(variant.currency).to eq(Spree::Config[:currency]) }
        end
      end

      context 'product not present' do
        context 'product not present' do
          before { variant.product = nil }

          context 'price nil and currency present' do
            before { variant.price = nil }

            it 'adds absence of master error' do
              variant.send(:check_price)
              expect(variant.errors[:base]).to include I18n.t('activerecord.errors.models.spree/variant.attributes.base.no_master_variant_found_to_infer_price')
            end
          end

          context 'price nil and currency nil' do
            before { variant.price = nil }

            it 'adds absence of master error' do
              variant.send(:check_price)
              expect(variant.errors[:base]).to include I18n.t('activerecord.errors.models.spree/variant.attributes.base.no_master_variant_found_to_infer_price')
            end
          end
        end
      end
    end
  end

  describe '#created_at' do
    it 'creates variant with created_at timestamp' do
      expect(variant.created_at).not_to be_nil
    end
  end

  describe '#updated_at' do
    it 'creates variant with updated_at timestamp' do
      expect(variant.updated_at).not_to be_nil
    end
  end

  context '#backordered?' do
    let!(:variant) { create(:variant) }

    it 'returns true when out of stock and backorderable' do
      expect(variant.backordered?).to eq(true)
    end

    it 'returns false when out of stock and not backorderable' do
      variant.stock_items.first.update(backorderable: false)
      expect(variant.backordered?).to eq(false)
    end

    it 'returns false when there is available item in stock' do
      variant.stock_items.first.update(count_on_hand: 10)
      expect(variant.backordered?).to eq(false)
    end
  end

  describe '#ensure_no_line_items' do
    let!(:line_item) { create(:line_item, variant: variant) }

    it 'adds error on product destroy' do
      expect(variant.destroy).to eq false
      expect(variant.errors[:base]).to include I18n.t('activerecord.errors.models.spree/variant.attributes.base.cannot_destroy_if_attached_to_line_items')
    end
  end
end
