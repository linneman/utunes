require 'digest/sha1'
require 'ecuparser.rb'

class User < ActiveRecord::Base
  
  has_many :order_items
  has_many :bundle_comments
  
  validates_presence_of       :name
  validates_uniqueness_of     :name
  
  validates_presence_of       :email
  validates_uniqueness_of     :email
  
  attr_accessor               :password_confirmation
  validates_confirmation_of   :password  
  
	attr_reader									:ecuparser

  attr_accessor               :password_reminder_link


  # returns the user's upload folder within the upload directory
  def userfolder
    "public/upload/user_id_" + self.id.to_s
  end
  

  def validate
		ecuparser = EcuParser.new(ecudata)
    errors.add_to_base("Missing password") if hashed_password.blank?
		if ecudata  &&  !ecuparser.check
			errors.add_to_base("version file has wrong format" )
		end
		
		errors.add_to_base("user level not supported") if ( level < 0 || level > 2 )
  end
  
  
  # file system maintainance
  def after_destroy
    logger.info("==================> Remove all bundle files for user: " +  userfolder )
    logger.info(" !!!!!!!!!!!!!!! cmd: rm -f -R #{userfolder}")
    %x[rm -f -R #{userfolder}]
  end

  
  def self.authenticate( name, password )
    user = self.find_by_name(name) || self.find_by_email(name)
    if user
      expected_password = encrypted_password( password, user.salt )
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  
  
  # virtual attribute 'password'
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password( self.password, self.salt )
  end



  def upload_licence_file=(licence_file)
    unless( licence_file.blank? )
      filename = base_part_of(licence_file.original_filename) 
      self.content_type = "binary"
      if( self.name )
				if licence_file.length > 1024
					self.ecudata = "error"
				else		
        	self.ecudata = licence_file.read 
					logger.info("licence file assigned")
				end
      end
    end
  end  
  

  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "z82Vp" + salt # 'z82Vp' makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)  
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def base_part_of(file_name) 
  	File.basename(file_name).gsub(/[^\w._-]/, '') 
  end  
  
end
