class AddRequiredUserLevlToHc12Source < ActiveRecord::Migration
  def self.up
    add_column :hc12_sources, :level, :integer, :default => 1
  end

  def self.down
    remove_column :hc12_sources, :level
  end
end
