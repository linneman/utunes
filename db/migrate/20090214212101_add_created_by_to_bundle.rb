class AddCreatedByToBundle < ActiveRecord::Migration
  def self.up
    add_column :bundles, :created_by_user_id, :integer
  end

  def self.down
    remove_column :bundles, :created_by_user_id
  end
end
