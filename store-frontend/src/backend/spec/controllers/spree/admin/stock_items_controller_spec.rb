require 'spec_helper'

module Spree
  module Admin
    describe StockItemsController, type: :controller do
      stub_authorization!

      context 'formats' do
        let!(:stock_item) { create(:variant).stock_items.first }

        it 'destroy stock item via js' do
          expect do
            delete :destroy, params: { format: :js, id: stock_item }
          end.to change(StockItem, :count).by(-1)
        end
      end
    end
  end
end
