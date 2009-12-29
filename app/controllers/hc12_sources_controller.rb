class Hc12SourcesController < ApplicationController
  
  before_filter	:authorize_team_member

  # GET /hc12_sources
  # GET /hc12_sources.xml
  def index
    @hc12_sources = Hc12Source.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @hc12_sources }
    end
  end

  # GET /hc12_sources/1
  # GET /hc12_sources/1.xml
  def show
    @hc12_source = Hc12Source.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @hc12_source }
    end
  end

  # GET /hc12_sources/new
  # GET /hc12_sources/new.xml
  def new    
    @hc12_source = Hc12Source.new
    @hc12_source.user_id = @user.id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @hc12_source }
    end
  end

  # GET /hc12_sources/1/edit
  def edit
    @hc12_source = Hc12Source.find(params[:id])
  end

  # POST /hc12_sources
  # POST /hc12_sources.xml
  def create
    @hc12_source = Hc12Source.new(params[:hc12_source])
    @hc12_source.user_id = @user.id

    respond_to do |format|
      if @hc12_source.save
        
        #
        # Create new bundle table row
        #  

        version_str = sprintf("%.2d", @hc12_source.version )
        bundle_title = "hc12_v#{version_str}"
                  
        bundle = Bundle.new( \
          :title=>bundle_title, \
          :description=>"Update for HC12 CAN Controller Software", \
          :created_by_user_id=>@user.id, \
          :level=>TEAM_USER_LEVEL, \
          :price=>0, \
          :ENU=>true, \
          :SPM=>true, \
          :FRC=>true, \
          :ENG=>true, \
          :ITI=>true, \
          :FRF=>true, \
          :GED=>true, \
          :SPE=>true, \
          :DUN=>true, \
          :public=>true
          )
          
        bundle.save(perform_validation = false)
        @hc12_source.bundle_id = bundle.id        
        @hc12_source.save
          
        flash[:notice] = 'HC12 archive was successfully created.'
        format.html { redirect_to(@hc12_source) }
        format.xml  { render :xml => @hc12_source, :status => :created, :location => @hc12_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @hc12_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /hc12_sources/1
  # PUT /hc12_sources/1.xml
  def update
    @hc12_source = Hc12Source.find(params[:id])
    @hc12_source.user_id = @user
    
    respond_to do |format|
      if @hc12_source.update_attributes(params[:hc12_source])
        flash[:notice] = 'Hc12Source was successfully updated.'
        format.html { redirect_to(@hc12_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @hc12_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /hc12_sources/1
  # DELETE /hc12_sources/1.xml
  def destroy
    @hc12_source = Hc12Source.find(params[:id])
    
    #
    # destroy bundle database entry
    #
    version_str = sprintf("%.2d", @hc12_source.version )
    bundle_title = "hc12_v#{version_str}"    
    bundle = Bundle.find_by_title(bundle_title)
    if bundle
      BundleComment.delete( bundle.bundle_comments )
      bundle.destroy
    end
        
    @hc12_source.destroy

    respond_to do |format|
      format.html { redirect_to(hc12_sources_url) }
      format.xml  { head :ok }
    end
  end  
  
end

