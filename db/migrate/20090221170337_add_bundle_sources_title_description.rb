class AddBundleSourcesTitleDescription < ActiveRecord::Migration
  def self.up
    add_column :bundle_sources, :title, :string
    add_column :bundle_sources, :description, :text
  end

  def self.down
    remove_column :bundle_sources, :title
    remove_column :bundle_sources, :description
  end
end
