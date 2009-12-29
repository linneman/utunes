class CreateBundleSources < ActiveRecord::Migration
  def self.up
    create_table :bundle_sources do |t|
      t.integer :bundle_id
      t.integer :user_id
      t.boolean :ENU
      t.boolean :SPM
      t.boolean :FRC
      t.boolean :GED
      t.boolean :ENG
      t.boolean :FRF
      t.boolean :ITI
      t.boolean :SPE
      t.boolean :DUN
      t.boolean :public

      t.timestamps
    end
  end

  def self.down
    drop_table :bundle_sources
  end
end
