# email configuration 
# 

module UTunes
  
  def UTunes.setMailConfig( config )

      # add your email client account (e.g. googlemail) in the following way here


      # Sample configuration for normal SMTP server (here GMX)
      # uncomment and edit the following for your SMTP email acoount
      # 
      # config.action_mailer.delivery_method       = :smtp
      # config.action_mailer.smtp_settings = {
      #    :address => 'mail.gmx.net',
      #    :port => 25,
      #    :domain => 'gmx.net',
      #    :user_name => 'yourgmxid',
      #    :password => 'yourgmxpassword',
      #    :authentication => :login
      #  }


      # Sample configuration for google mail using TLS
      # uncomment and edit the following lines for your google email acoount
      #
      # config.action_mailer.smtp_settings = {
      # :address => "smtp.gmail.com",
      # :port => 587,
      # :authentication => :plain,
      # :user_name => "youruserid@googlemail.com",
      # :password => 'yourpasswd'}

                
  end # def UTunes.setMailConfig( config )
    
end  # module UTunes
