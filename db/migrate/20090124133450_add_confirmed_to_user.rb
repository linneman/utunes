class AddConfirmedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmed, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :confirmed
  end
end
