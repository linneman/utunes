class CreateHc12Sources < ActiveRecord::Migration
  def self.up
    create_table :hc12_sources do |t|
      t.integer :bundle_id
      t.integer :user_id
      t.integer :version
      
      t.timestamps
    end
  end

  def self.down
    drop_table :hc12_sources
  end
end
