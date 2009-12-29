class UserController < ApplicationController
 
	before_filter	:authorize, \
	                :except => [ :login, :register, :confirm, \
	                              :confirmation_send, :confirmation_error, \
	                              :forgot_password, :password_reminder_send, :reactivate_account, :reactivation_error ]
 

  def login
    if request.post?
      user = User.authenticate( params[:name], params[:password] )
      if user
				if user.confirmed
					session[:user_id] = user.id
					uri = session[:original_uri]
					session[:original_uri] = nil
					# flash[:notice] = "Login was successful"
					redirect_to( uri || { :action => "index" } )
				else
        	flash.now[:notice] = "You have to confirm your registration by clicking the link in the confirmation email!"
				end
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end


  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged Out"
    redirect_to(:action=>"login")
  end


  def register
    session[:user_id] = nil
    @user = User.new(params[:user])
    @user.confirmation_link = url_for(:action=>"confirm", :name=>@user.name, :hp=>@user.hashed_password)
    if request.post? and @user.save
      flash.now[:notice] = "User #{@user.name} created"
      UserMailer.deliver_confirm(@user)
      @user = User.new
      redirect_to(:action=>"confirmation_send")
			# logger.info( "---> session[:user_id] after registering: " + session[:user_id] )
    end
  end
  
  
  # allows to change password when logged in
  def chpasswd
		if request.post?
		  @user.password = params[:user][:password]
		  @user.password_confirmation = params[:user][:password_confirmation]
		  if @user.save
		    redirect_to(:action=>"password_changed")
	    end
    end   
  end
  
  
  # allows to get a new password when entering a valid email address
  def forgot_password
    if @user
      flash[:notice] = "You are already logged in"
      redirect_to(:action=>"chpasswd")
    else 
      logger.info(@user) 
      if request.post?
        email = params[:user][:email] 
        if @user = User.find_by_email( email )
          @user.password_reminder_link = url_for(:action=>"reactivate_account", :name=>@user.name, :hp=>@user.hashed_password)
          UserMailer.deliver_password_reminder(@user)
          redirect_to(:action=>"password_reminder_send")
        else
          flash.now[:notice] = "There is no account with this email address!"
        end
      end
    end
  end
  

	def upload_licence
		@user = User.find( session[:user_id] )
		if request.post?
			file = params["user"]["upload_licence_file"]
			logger.info( "data: " + file.class.to_s)
			@user.upload_licence_file=file
			
			if @user.save
				uri = session[:original_uri]
				session[:original_uri] = nil
        flash.now[:notice] = "Upload was successful"
        redirect_to( uri || { :action => "index" } )
			end
		end
	end


  def confirmation_send
    # invoked when confirmation has been send
  end
        
  def password_reminder_send
    # invoked when user has clicked on password reminder (change) url
  end
        
  
  def confirm
    # invoked form email link
    begin
      user_to_confirm = User.find_by_name(params[:name]) 
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Invalid Link"
      redirect_to(:action=>:index)
    else
      if user_to_confirm.hashed_password == params[:hp]
        user_to_confirm.confirmed = 1
        user_to_confirm.save
        session[:user_id] = user_to_confirm.id
        redirect_to(:action=>"confirmation_successful")
      else
        redirect_to(:action=>"confirmation_error")
      end
    end
  end
  
  
  def reactivate_account
    # invoked form email link
    begin
      user_to_reativate = User.find_by_name(params[:name]) 
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Invalid Link"
      redirect_to(:action=>:index)
    else
      if user_to_reativate.hashed_password == params[:hp]
        session[:user_id] = user_to_reativate.id
        flash[:notice] = "Reactivation of you account was succcessful. Please change your password:"
        redirect_to(:action=>"chpasswd")
      else
        redirect_to(:action=>"reactivation_error")
      end
    end
  end
  
  
  
  def change_user
    # allows admin to login under another user id
    if !admin_authorized?
      flash[:notice] = "Only administrators are allowed to change user id!"
      redirect_to(:action=>:login)
    elsif request.post?  
      user = User.find_by_name(params[:name]) || User.find_by_email(params[:name])
      if user
				session[:user_id] = user.id
				uri = session[:original_uri]
				session[:original_uri] = nil
				# flash[:notice] = "Login was successful"
				redirect_to( uri || { :action => "index" } )
      else
        flash.now[:notice] = "User not found"
      end
    end  
  end
  
  
  def test
    @user = User.find(:first)
    render :action => 'register'
  end
  
  def confirmation_successful
  end
  
  def confirmation_error
  end

  def reactivation_error
  end

	def index
		@user = User.find( session[:user_id] )
	end
  
end
