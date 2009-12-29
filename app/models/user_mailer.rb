class UserMailer < ActionMailer::Base
  
  def confirm(user)
    subject    'U-Tunes Registration Confirmation'
    recipients  user.email
    from       'utunes.webservices@googlemail.com'
    sent_on    Time.now
    
    body :user=>user
  end
  
  def password_reminder(user)
    subject    'U-Tunes Account Reactivation'
    recipients  user.email
    from       'utunes.webservices@googlemail.com'
    sent_on    Time.now
    
    body :user=>user
  end


end
