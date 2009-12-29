class CreateBundles < ActiveRecord::Migration
  def self.up
    create_table :bundles do |t|
      t.string :title
      t.text :description
      t.decimal :price, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :bundles
  end
end
