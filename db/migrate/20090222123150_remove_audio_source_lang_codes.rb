class RemoveAudioSourceLangCodes < ActiveRecord::Migration
  def self.up
		remove_column :audio_sources, :ENU
		remove_column :audio_sources, :SPM
		remove_column :audio_sources, :FRC
		remove_column :audio_sources, :GED
		remove_column :audio_sources, :ENG
		remove_column :audio_sources, :FRF
		remove_column :audio_sources, :ITI
		remove_column :audio_sources, :SPE
		remove_column :audio_sources, :DUN
  end

  def self.down
  end
end
