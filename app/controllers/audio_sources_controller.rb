class AudioSourcesController < ApplicationController
  
  require 'set'
  
  before_filter :find_bundle_source
  
  # GET /audio_sources
  # GET /audio_sources.xml
  def index
    @audio_sources = @bundle_source.audio_sources

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @audio_sources }
    end
  end

  # GET /audio_sources/1
  # GET /audio_sources/1.xml
  def show
    @audio_source = @bundle_source.audio_sources.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @audio_source }
    end
  end

  # GET /audio_sources/new
  # GET /audio_sources/new.xml
  def new
    @audio_source = AudioSource.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @audio_source }
    end
  end

  # GET /audio_sources/1/edit
  def edit
    @audio_source = @bundle_source.audio_sources.find(params[:id])
   
  end

  # POST /audio_sources
  # POST /audio_sources.xml
  def create
    @audio_source = @bundle_source.audio_sources.build(params[:audio_source])
    
    respond_to do |format|
      if @audio_source.save
        flash[:notice] = 'The audio data was successfully uploaded. You can upload further files or publish the bundle by going back to its description with the buttons below'
        format.html { redirect_to bundle_source_audio_sources_url(@bundle_source) }
        format.xml  { render :xml => @audio_source, :status => :created, :location => @audio_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @audio_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /audio_sources/1
  # PUT /audio_sources/1.xml
  def update
    @audio_source = @bundle_source.audio_sources.find(params[:id])

    respond_to do |format|     
      if @audio_source.update_attributes(params[:audio_source])
        flash[:notice] = 'prompt was successfully updated.'
        format.html { redirect_to bundle_source_audio_sources_url(@bundle_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @audio_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /audio_sources/1
  # DELETE /audio_sources/1.xml
  def destroy
    @audio_source = @bundle_source.audio_sources.find(params[:id])
    @audio_source.destroy

    respond_to do |format|
      format.html { redirect_to bundle_source_audio_sources_url(@bundle_source) }
      format.xml  { head :ok }
    end
  end
  
    
  private 
    
  def find_bundle_source
    @bundle_source = BundleSource.find( params[:bundle_source_id] )
    
    unless  @bundle_source.user_id == @user.id
      flash[:notice] = 'You are not allowed to do this'
      redirect_to bundle_sources_url
		else
      @language = @bundle_source.language.downcase

      excluded = Set.new
      excluded |= @bundle_source.audio_sources.collect{ |x| x.file_id }.to_set
      excluded |= Translation.find(:all, :conditions => ["#{@language}=''"]).collect{ |x| x.id }.to_set
      excluded << -1  # we need at least one element
      @translations = Translation.find(:all, :conditions => ["id NOT IN (?)", excluded.to_a], :order=>@language )
      Translation.shortform_lang_attributes( [ "enu", "frc", "spm", "eng", "frf", "dun", "spe", "ged", "iti" ] )
    end

  end    
  
end
