class OrderItemController < ApplicationController

  include ActiveMerchant::Billing::Integrations  
  require 'crypto42'
  require 'money'
	require 'ecuparser.rb'

  # temporary required for paypal test tool which is not authentificated
  skip_before_filter :verify_authenticity_token

	
	# This method is invoked from Paypal to notify payment status
	# If the bundle to download specifies a price, this is the
	# only way to trigger the download process
  def notify
    logger.info("----> notify handler invoked")
    # Paypal.service_url = "https://www.sandbox.paypal.com/cgi-bin/webscr"
    logger.info("Paypal service URL: "+Paypal.service_url)
    # logger.info("raw post -->: "+request.raw_post)

    notify = Paypal::Notification.new(request.raw_post)

		logger.info( " item id  --->: " + notify.item_id )
		logger.info( " customer --->: " + params["custom"] ) 
	
    if notify.acknowledge
      logger.info("----> notify acknowledge received!")
      begin
        if notify.complete?
	  			logger.info("----> notification clompete, item_id: "+notify.item_id+ ", invoice: "+notify.invoice.to_s + ", status: "+notify.status + ", gross: " + notify.gross  )
			
					order_item = OrderItem.new( { :user_id=>params["custom"], :bundle_id=>notify.item_id, :price=>notify.gross, :currency_code=>params["mc_currency"] } )
					order_item.save

					generate_download_file( order_item )
					send_download_email( order_item )
        else
          logger.error("Failed to verify Paypal's notification, please investigate")
        end
      rescue => e
        raise
      ensure
      
      end
    else
      logger.info("transaction was not acknowledged!")
    end
    render :nothing => true
  end

	
	# This method is displaying a "Thank you for shopping message" when
	# the payment process at PayPal is completed. (Paypal redirection)
	def paypal_return
	end




	# this method creates an order without payment clearing
	#	for free availabe downloads
	def download_request
		logger.info(params[:user])
		logger.info(params[:bundle])
		bundle = Bundle.find( params[:bundle])
		if bundle.price > 0
			logger.info("Somebody tried to download a unfree bundle without paying!")
			redirect_to :action=>"not_allowed"
		elsif bundle.level > user_level
		  logger.info("Somebody tried to download a bundle without authorization!")
		  redirect_to :action=>"not_allowed"
		else
			order_item = OrderItem.new( { :user_id=>params[:user], :bundle_id=>params[:bundle], :price=>0 } )
			order_item.save

			generate_download_file( order_item )
			# send_download_email( order_item )
			redirect_to :action=>"download", :id=>order_item.url
		end
	end


# this method generates the actual download link which
#	is rendered together with the download page 

def download
	@downloadlink = generate_download_ref( params[:id] )
end


# not authorized or user did not pay
# 
def not_allowed
end


private

	# helper for generating the bundle
	def generate_download_file( order_item )
		user = User.find_by_id( order_item.user_id )
		bundle = Bundle.find_by_id( order_item.bundle_id )

		ecuparser = EcuParser.new(user.ecudata)

		sw_version = ecuparser.version
		sw_version_minor = sw_version[0..5]+'00'
		sw_version_major = sw_version[0..5]+'99'

		serial_nr = ecuparser.serialnr

		target_dir  = "public/download/#{order_item.url}"
		target_file = "#{target_dir}/uconnect.upd"
 
		gen_script_dir = 'lib/bundles/build_'+bundle.title.gsub(/\s/, "_" ).downcase
		gen_script = 'build_main.sh'


		bash_cmd = 	"mkdir #{target_dir}; " 
		bash_cmd << "cd #{gen_script_dir}; "
		bash_cmd << "./#{gen_script} #{sw_version_minor} #{sw_version_major} #{serial_nr}; "
		bash_cmd << "./sign_archive.sh; "
		bash_cmd << "mv command.tar ../../../#{target_file}" 

 
		# create temporary file
		# `mkdir #{target_dir}` 
		# `echo "#{ecuparser.version}" >  public/download/#{order_item.url}/uconnect.upd` 

		logger.info(bash_cmd)
		# `#{bash}`
		pipe= IO.popen("/bin/bash", 'w+') 
    pipe << bash_cmd 
    pipe.close_write
    result=pipe.read

		logger.info(result)
	end
	

	# reference to the actual file resouce
	def generate_download_ref( hashkey )
  	# %Q|<a href="/download/#{hashkey}/uconnect.upd" type="application/binary">Click here to download your update file</a><br>|

  	'<a href="' + url_for(:controller=>"download", :action=>"#{hashkey}", :id=>"uconnect.upd") + %Q|" type="application/binary">Click here to download your update file</a><br>|
	end


	# link to a download html page
	def generate_download_url( hashkey )
		url_for(:controller=>:order_item, :action=>"download", :id=>"#{hashkey}" )
	end




	def send_download_email( order_item )
		user = User.find( order_item.user_id )
		downloadlink = generate_download_url( order_item.url )
 		OrderItemMailer.deliver_download_url( user, downloadlink )
	end


end
