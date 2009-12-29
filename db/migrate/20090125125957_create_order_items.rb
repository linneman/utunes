class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.integer :bundle_id
      t.integer :user_id
      t.decimal :price
      t.datetime  :placed_at, :default => Time.now
      t.datetime  :payment_received_at, :default => nil
      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
