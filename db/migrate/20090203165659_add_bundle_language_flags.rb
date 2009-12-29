class AddBundleLanguageFlags < ActiveRecord::Migration
  def self.up
		add_column :bundles, :ENU, :boolean, :default=>true
		add_column :bundles, :SPM, :boolean, :default=>false
		add_column :bundles, :FRC, :boolean, :default=>false
		add_column :bundles, :GED, :boolean, :default=>false
		add_column :bundles, :ENG, :boolean, :default=>true
		add_column :bundles, :FRF, :boolean, :default=>false
		add_column :bundles, :ITI, :boolean, :default=>false
		add_column :bundles, :SPE, :boolean, :default=>false
		add_column :bundles, :DUN, :boolean, :default=>false
  end

  def self.down
  end
end
