class OrderItemMailer < ActionMailer::Base
  
  def download_url( user, url )
    subject    'U-Tunes Bundle File Ready for Download'
    recipients  user.email
    from       'utunes.webservices@googlemail.com'
    sent_on    Time.now
    body( { :user=>user, :url=>url } )  
  end

end
