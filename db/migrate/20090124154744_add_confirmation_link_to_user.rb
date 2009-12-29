class AddConfirmationLinkToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmation_link, :string
  end

  def self.down
    remove_column :users, :confirmation_link
  end
end
