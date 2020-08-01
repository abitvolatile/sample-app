class RemoveCounterCacheFromSpreeVariantsToSpreeStockItems < ActiveRecord::Migration[4.2]
  def up
    if column_exists?(:spree_variants, :stock_items_count)
      remove_column :spree_variants, :stock_items_count
    end
  end

  def down
  end
end
