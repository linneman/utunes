class Translation < ActiveRecord::Base
      
  # This class method defines for the given array of 
  # database fields correspondig getter methods which
  # deliver an abriation text
  # 
  # example: Translation.short_form_lang_attributes( ["enu", "ged"] )
  #          defines the methods shortform_enu, shrotform_ged
  
  def self.shortform_lang_attributes( lang_array )
    
    lang_array.each do |symbol|
      getter = "shortform_" + symbol
      
      define_method getter do
        if self.respond_to? getter
           sprintf( "%.90s", self.send( symbol ) )
         else
           nil
        end
      end
      
    end # array.each do
    
  end
    
  
end
