module BundlesHelper
  
  
  def generate_encrypted_buy_button( bundle )

		if session[:user_id]  
			# user is logged in
			user = User.find( session[:user_id] )

			if user.ecudata
				# user has a valid version file uploaded (ecu.ini)


				if bundle.price < 0.1
					# link to direct download button
					link_to image_tag( "download.gif", :border=>"0" ), :controller=>"order_item", :action=>"download_request", :user=>user.id.to_s, :bundle=>bundle.id.to_s
				else
					# link to paypal
					action_url, encrypted_basic = fetch_decrypted( bundle )
					%Q|
					<form action="#{action_url}" method="post">
										<input type="hidden" name="cmd" value="_s-xclick" />
										<input type="hidden" name="encrypted" value="#{encrypted_basic}" />
										<input type="image" src="#{url_for :controller=>"images/btn_buynow.gif"}" border="0" name="submit" alt="">
										<img alt="" border="0" src="#{url_for :controller=>"images/pixel.gif"}" width="1" height="1">

					</form>
					| 
				end


			else # if no user.ecudata

				# link_to "upload licence file", :controller=>"user", :action=>"upload_licence"
				session[:original_uri] = request.request_uri
				if bundle.price < 0.1
					link_to image_tag( "download.gif", :border=>"0" ), :controller=>"user", :action=>"upload_licence", :info=>"You have to upload your U-Connect version file first"
				else
					link_to image_tag( "btn_buynow.gif", :border=>"0" ), :controller=>"user", :action=>"upload_licence", :info=>"You have to upload your U-Connect version file first"
				end

			end

		else # user is not logged in
			# link_to "register", :controller=>"user", :action=>"register"
			session[:original_uri] = request.request_uri
			if bundle.price < 0.1
				link_to image_tag( "download.gif", :border=>"0" ), :controller=>"user", :action=>"login", :info=>"You have to login or register first"
		else
				link_to image_tag( "btn_buynow.gif", :border=>"0" ), :controller=>"user", :action=>"login", :info=>"You have to login or register first"
			end

		end # if user.ecudata

	end


  def fetch_decrypted( bundle )
  
    # cert_id is the certificate if we see in paypal when we upload our own certificates
    # cmd _xclick need for buttons
    # item name is what the user will see at the paypal page
    # custom and invoice are passthrough vars which we will get back with the asunchronous
    # notification
    # no_note and no_shipping means the client want see these extra fields on the paypal payment
    # page
    # return is the url the user will be redirected to by paypal when the transaction is completed.
    if ENV['RAILS_ENV'] == "production" 
			decrypted = {
				"cert_id" => "8323CDQ4NVUPW",
				"cmd" => "_xclick",
				"business" => "linneman@gmx.de",			# "MWWM6HNNTPFGA" 
				"item_name" => "#{bundle.title}",
				"item_number" => "#{bundle.id}",
				"custom" =>"#{User.find(session[:user_id]).id}",
				"amount" => "#{bundle.price}",
				"currency_code" => "#{bundle.currency_code}",
				"country" => "DE",
				"no_note" => "1",
				"no_shipping" => "1"
				}	
		else
			decrypted = {
				"cert_id" => "223DLXQRRZDEL",
				"cmd" => "_xclick",
				"business" => "linnem_1232895815_biz@gmx.de",	# "KC3BTKYCAXGVS",
				"item_name" => "#{bundle.title}",
				"item_number" => "#{bundle.id}",
				"custom" =>"#{User.find(session[:user_id]).id}",
				"amount" => "#{bundle.price}",
				"currency_code" => "#{bundle.currency_code}",
				"country" => "US",
				"no_note" => "1",
				"no_shipping" => "1"
    		}
		end

    encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text
  
  
    action_url = ENV['RAILS_ENV'] == "production" ? "https://www.paypal.com/cgi-bin/webscr" : "https://www.sandbox.paypal.com/cgi-bin/webscr"
 
		# logger.info( encrypted_basic + action_url )
 
		[ action_url, encrypted_basic ]
		# [ action_url, decrypted ]
	end
	
	
	
	# Filters pseudo HTML code to allow linking of images or
	# multimedia content similar to mediawiki
	
	def filter_content( content )   
	  
	  # we do not want to touch the reference
	  filtered_content = content.dup
	  
	  # replaces [[File:file.jpg]] or [[File:file.png]] or [[File:file.gif]] 
    # with 
    # <img src="upload/images/file.ext  height=300px border="0"  ALIGN=RIGHT />
    
    url_image_root_path = url_for :controller=>"upload/images"
    img_link_prefix = '<img src="' + url_image_root_path + '/'
    img_link_postfix = '"  height=300px border="0"  ALIGN=RIGHT />'
    filtered_content.gsub!(/(\[\[)([Ff]ile:)([\w\.]+)(\.png|\.jpg|\.jpeg|\.gif)(\]\])/, img_link_prefix + '\3\4' + img_link_postfix)
 
 
    # replaces [[File:file.wav]] or [[File:file.mp3]] 
    # <embed src="/audio/file.ext" width="140" height="60" loop=false autostart=false>

    url_audio_root_path = url_for :controller=>"upload/audio"
    audio_link_prefix = '<embed src="' + url_audio_root_path + '/'
    audio_link_postfix = '"  width="140" height="60" loop=false autostart=false>'
    filtered_content.gsub!(/(\[\[)([Ff]ile:)([\w\.]+)(\.wav|\.mp3)(\]\])/, audio_link_prefix + '\3\4' + audio_link_postfix)

 
    filtered_content
  end
	
	

end

