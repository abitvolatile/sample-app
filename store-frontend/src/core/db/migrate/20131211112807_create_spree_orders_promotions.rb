class CreateSpreeOrdersPromotions < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_orders_promotions, id: false do |t|
      t.references :order
      t.references :promotion
    end
  end
end
