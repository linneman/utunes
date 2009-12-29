class BundleSourcesController < ApplicationController
  
  before_filter :authorize_logged_in
  before_filter :check_user
  
  # GET /bundle_sources
  # GET /bundle_sources.xml
  def index
    @bundle_sources = BundleSource.find(:all, :conditions => ["user_id=#{@user.id}"])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bundle_sources }
    end
  end

  # GET /bundle_sources/1
  # GET /bundle_sources/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bundle_source }
    end
  end

  # GET /bundle_sources/new
  # GET /bundle_sources/new.xml
  def new
    @bundle_source = BundleSource.new
     respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bundle_source }
    end
  end

  # GET /bundle_sources/1/edit
  def edit    
    @bundle_source = BundleSource.find(params[:id] )
  end

  # POST /bundle_sources
  # POST /bundle_sources.xml
  def create
    args = params[:bundle_source].merge( :user_id => @user.id )
    @bundle_source = BundleSource.new( args )

    respond_to do |format|
      if @bundle_source.save
        flash[:notice] = 'Your bundle source containter was successfully created. You should now add some audio files to it.'
        format.html { redirect_to(@bundle_source) }
        format.xml  { render :xml => @bundle_source, :status => :created, :location => @bundle_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bundle_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bundle_sources/1
  # PUT /bundle_sources/1.xml
  def update
    @bundle_source.user_id = @user.id
    respond_to do |format|
      if @bundle_source.update_attributes(params[:bundle_source])
        flash[:notice] = 'BundleSource was successfully updated. The changes have to published by clicking the button below to make them available within the download section.'
        format.html { redirect_to(@bundle_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bundle_sources/1
  # DELETE /bundle_sources/1.xml
  def destroy
    AudioSource.delete( @bundle_source.audio_sources )
    
    corresponding_bundle = @bundle_source.bundle_id
    if( @bundle_source.bundle_id )
      corresponding_bundle = Bundle.find_by_id( @bundle_source.bundle_id )
      if( corresponding_bundle && corresponding_bundle.created_by_user_id == @user.id )
        logger.info("****** DESROY invoked ****** ")
        corresponding_bundle.destroy
      end
    end

    @bundle_source.destroy

    respond_to do |format|
      format.html { redirect_to(bundle_sources_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def publish
    respond_to do |format|
      if @bundle_source.audio_sources.length < 1
         flash[:notice] = 'You have to upload audio prompts before publishing!'
         format.html { redirect_to(@bundle_source) }
         format.xml  { head :ok }   
      elsif generate_bundle( @bundle_source )
        flash[:notice] = 'BundleSource was successfully published.'
        format.html { redirect_to(@bundle_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle_source.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  
  private 
  
  
  
  
	def check_user
	  if( params[:id] )
	    @bundle_source = BundleSource.find(params[:id])
	  
  		unless  @bundle_source.user_id == @user.id
        flash[:notice] = 'You are not allowed to do this'
        redirect_to :action=>"index"
  		else
        @language = @bundle_source.language.downcase
        included = @bundle_source.audio_sources.collect{ |x| x.file_id }
        @sample_prompt_selection = Translation.find(:all, :conditions => ["id IN (?)", included], :order=>@language )
        @sample_prompt_selection << Translation.new(:id=>nil)
  		end
  	end
	end
  


  def generate_bundle( bundle_source )
    
    # first generate respectively bundle database entry
    # make the bundle private to avoid access file its
    # files are generated
    
    bundle = Bundle.find_by_title( bundle_source.title )
    unless( bundle )
      bundle = Bundle.new( 
        :title => bundle_source.title, 
        :price => 0, 
        :created_by_user_id => bundle_source.user_id, 
        :level => 0 )
    end
      
    bundle.description = bundle_source.description
    bundle.public = 0   
    
    bundle.ENU = bundle_source.ENU
    bundle.FRC = bundle_source.FRC
    bundle.SPM = bundle_source.SPM
    
    bundle.ENG = bundle_source.ENG
    bundle.FRC = bundle_source.FRC
    bundle.ITI = bundle_source.ITI
    bundle.SPM = bundle_source.SPM
    bundle.DUN = bundle_source.DUN
    bundle.GED = bundle_source.GED    
    save_result = bundle.save
    
    
    # create bundle script generator
    
    template_script_dir = 'lib/build_bundle/templates/build_voicebundle'
    gen_script_dir      = 'lib/build_bundle/build_'+bundle_source.title.gsub(/\s/, "_" ).downcase
    
    %x[rm -R #{gen_script_dir}]
    %x[cp -R #{template_script_dir} #{gen_script_dir}]
    %w[ENU FRC SPM ENG FRF SPM DUN GED ITI].each do |lang|
      if bundle_source.send(lang)
        langdir    = File.join( gen_script_dir, "prompts", lang.downcase )
        %x[mkdir #{langdir}]
        bundle_source.audio_sources.each do |prompt| 
          targetfile = File.join( langdir, lang.downcase+sprintf("%.5d", prompt.file_id ) )+".spx"
          logger.info("cp #{prompt.fq_spx_filename} #{targetfile}")
          %x[cp #{prompt.fq_spx_filename} #{targetfile}] 
        end
      end
    end
    
    
    # setup user defined access rights 
    
    bundle.public = bundle_source.public
    save_result &= bundle.save

    if save_result
      bundle_source.bundle_id = bundle.id
      bundle_source.save
    end
    
    save_result
  end


end
