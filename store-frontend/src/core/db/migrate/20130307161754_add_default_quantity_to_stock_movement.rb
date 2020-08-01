class AddDefaultQuantityToStockMovement < ActiveRecord::Migration[4.2]
  def change
    change_column :spree_stock_movements, :quantity, :integer, default: 0
  end
end
