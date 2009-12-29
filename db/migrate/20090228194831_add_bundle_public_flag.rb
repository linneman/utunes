class AddBundlePublicFlag < ActiveRecord::Migration
  def self.up
    add_column :bundles, :public, :boolean, :default=>false
  end

  def self.down
    remove_column :bundles, :public
  end
end
