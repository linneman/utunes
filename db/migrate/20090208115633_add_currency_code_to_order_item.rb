class AddCurrencyCodeToOrderItem < ActiveRecord::Migration
  def self.up
    add_column    :order_items, :currency_code, :string
  end

  def self.down
    remove_column :order_items, :currency_code
  end
end
