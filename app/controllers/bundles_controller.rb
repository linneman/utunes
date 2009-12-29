class BundlesController < ApplicationController

	before_filter	:authorize_admin, :except => [ :index, :show ]
	before_filter :check_user_rights

  include ActiveMerchant::Billing::Integrations  
  require 'crypto42'
  require 'money'


	def initialize
    if ENV['RAILS_ENV'] == "production" 
			# Ensure the gateway is in production mode
			
			ActiveMerchant::Billing::Base.gateway_mode = :production
			ActiveMerchant::Billing::Base.integration_mode = :production
			ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(File.dirname(__FILE__) + '/../../paypal/paypal_cert.pem')
		else
			# Ensure the gateway is in test mode
			
			ActiveMerchant::Billing::Base.gateway_mode = :test
			ActiveMerchant::Billing::Base.integration_mode = :test
			ActiveMerchant::Billing::PaypalGateway.pem_file = File.read(File.dirname(__FILE__) + '/../../paypal/paypal_sandbox_cert.pem')
		end
	end

  # GET /bundles
  # GET /bundles.xml
  def index
    if( admin_authorized? )
      @bundles = Bundle.paginate(:all, :order => "Title", :page=>params[:page], :per_page=>3 )
    else
      @bundles = Bundle.paginate(:all, 
        :conditions => [ 'level <= ?  and  public > ?  or  created_by_user_id = ?', user_level, 0, ( @user ? @user.id : -1 )],
        :order => "Title",
        :page=>params[:page], 
        :per_page=>3 
        )
    end
    
		logger.info("------> Authorized?: #{@admin_authorized}" )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bundles }
    end
  end

  # GET /bundles/1
  # GET /bundles/1.xml
  def show
    @bundle = Bundle.find(params[:id])
    if @bundle.level <= user_level
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @bundle }
      end
    else
      render :action => "not_allowed" 
    end
  end
 


  # GET /bundles/new
  # GET /bundles/new.xml
  def new
    @bundle = Bundle.new
    @bundle.created_by_user_id=@user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bundle }
    end
  end

  # GET /bundles/1/edit
  def edit
    @bundle = Bundle.find(params[:id])
  end

  # POST /bundles
  # POST /bundles.xml
  def create
    @bundle = Bundle.new(params[:bundle])
    @bundle.created_by_user_id=@user
    
    respond_to do |format|
      if @bundle.save
        flash[:notice] = 'Bundle was successfully created.'
        format.html { redirect_to(@bundle) }
        format.xml  { render :xml => @bundle, :status => :created, :location => @bundle }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bundle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bundles/1
  # PUT /bundles/1.xml
  def update
    @bundle = Bundle.find(params[:id])

    respond_to do |format|
      if @bundle.update_attributes(params[:bundle])
        flash[:notice] = 'Bundle was successfully updated.'
        format.html { redirect_to(@bundle) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bundles/1
  # DELETE /bundles/1.xml
  def destroy
    @bundle = Bundle.find(params[:id])
    BundleComment.delete( @bundle.bundle_comments )
    @bundle.destroy

    respond_to do |format|
      format.html { redirect_to(bundles_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def not_allowed
  end
  
  private 
  
  
  
  # protection against non-authorized resource access for 
  # private bundles
  def check_user_rights
    if( params[:id] &&  !admin_authorized? )
      @bundle = Bundle.find(params[:id])
      if( ! @bundle.public )
        if( @bundle.created_by_user_id != @user.id )
  				render :action => "not_allowed" 
        end
      end
    end
  end
  
  
end
