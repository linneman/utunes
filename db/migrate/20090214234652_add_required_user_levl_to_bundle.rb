class AddRequiredUserLevlToBundle < ActiveRecord::Migration
  def self.up
    add_column :bundles, :level, :integer, :default => 0
  end

  def self.down
    remove_column :bundles, :level
  end
end
