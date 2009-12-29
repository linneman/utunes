class CreateBundleComments < ActiveRecord::Migration
  def self.up
    create_table :bundle_comments do |t|
      t.integer :bundle_id
      t.integer :user_id
      t.string  :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :bundle_comments
  end
end
