class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string   :enu
      t.string   :frc
      t.string   :spm
      t.string   :ged
      t.string   :dun
      t.string   :eng
      t.string   :frf
      t.string   :spe
      t.string   :iti
      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
