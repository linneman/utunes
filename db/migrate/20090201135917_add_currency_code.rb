class AddCurrencyCode < ActiveRecord::Migration
  def self.up
		add_column :bundles, :currency_code, :string, :default=>"EUR"
  end

  def self.down
		remove_column :bundles, :currency_code
  end
end
