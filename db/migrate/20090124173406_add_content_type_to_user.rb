class AddContentTypeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :content_type, :string
  end

  def self.down
    remove_column :users, :content_type
  end
end
