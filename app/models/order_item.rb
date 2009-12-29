require 'digest/sha1'

class OrderItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :bundle
  
	after_validation :create_url

	def create_url 
		self.url= Digest::SHA1.hexdigest( user_id.to_s + bundle_id.to_s )	
	end


end
