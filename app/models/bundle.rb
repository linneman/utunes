class Bundle < ActiveRecord::Base

  has_many  :order_items
  has_many  :bundle_comments

	validates_format_of	:currency_code, :with => /^(EUR|USD)$/
	validates_uniqueness_of :title	
	  
end
