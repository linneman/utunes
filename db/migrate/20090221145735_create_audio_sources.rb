class CreateAudioSources < ActiveRecord::Migration
  def self.up
    create_table :audio_sources do |t|
      t.integer :bundle_source_id
      t.integer :file_id
      t.boolean :ENU
      t.boolean :SPM
      t.boolean :FRC
      t.boolean :GED
      t.boolean :ENG
      t.boolean :FRF
      t.boolean :ITI
      t.boolean :SPE
      t.boolean :DUN

      t.timestamps
    end
  end

  def self.down
    drop_table :audio_sources
  end
end
