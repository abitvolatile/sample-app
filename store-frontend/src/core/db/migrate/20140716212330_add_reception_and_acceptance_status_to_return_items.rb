class AddReceptionAndAcceptanceStatusToReturnItems < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_return_items, :reception_status, :string
    add_column :spree_return_items, :acceptance_status, :string
  end
end
