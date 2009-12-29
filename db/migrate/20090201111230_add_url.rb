class AddUrl < ActiveRecord::Migration
  def self.up
		add_column	:order_items, :url, :string
  end

  def self.down
		remove_column	:order_items, :url
  end
end
