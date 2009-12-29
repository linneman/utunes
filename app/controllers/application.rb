# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout "utunes"
	before_filter :find_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '342441f4989327a650f621c5470a2e47'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  STD_USER_LEVEL   = 0  # Normal Users
	TEAM_USER_LEVEL  = 1	# Users of the dev team can create sw_upgrade_bundles
	ADMIN_USER_LEVEL = 2	# Admins can do everything


 	protected

	def find_user
		@user = User.find_by_id(session[:user_id])
		@logged_in_user = @user   # we need a copy here to avoid wrong indication for users admin panel
		@admin_authorized = admin_authorized?
		@team_member_authorized = team_member_authorized?
		
		# setup menu action for bundle_sources
		# new if no bundle_source have been added so far
		# index if the user has already added some bundles
		if @user
		  if BundleSource.find_by_user_id( @user.id )
		    @menu_action_bundle_sources = :index
	    else
	      @menu_action_bundle_sources = :new
      end
	  end
	end


	def determine_layout
		if admin_authorized?
			"utunes_admin"
		elsif @user
			"utunes_logged_in"
		else
			"utunes"
		end
	end

	
	def authorize( required_level=0 )
		unless @user
			flash[:notice] = "Please log in"
			session[:original_uri] = request.request_uri
			redirect_to( :controller => "user", :action => "login" )
		else 
			logger.info( "----> user.level: "+@user.level.to_s+" required_level: "+required_level.to_s )
			if @user.level < required_level
				flash[:notice] = "Your priveledges are not sufficient!"
				session[:original_uri] = nil
				redirect_to( :controller => "user", :action => "login" )
			end
		end
	end


	# called from access filters within several controllers

	def authorize_admin
		authorize( ADMIN_USER_LEVEL  ) 
	end

	def authorize_team_member
		authorize( TEAM_USER_LEVEL )
	end

  def authorize_logged_in
    authorize( STD_USER_LEVEL )
  end

  public

	# getters used for layout customization

	def admin_authorized?
		if @user
			@user.level >= ADMIN_USER_LEVEL 
		else
			nil
		end
	end

	def team_member_authorized?
		if @user
			@user.level >= TEAM_USER_LEVEL 
		else
			nil
		end
	end


  def user_level
    if @user
      @user.level
    else
      0
    end
  end

end
