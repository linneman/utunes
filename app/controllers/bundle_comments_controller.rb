class BundleCommentsController < ApplicationController

  before_filter	:authorize_admin, :except => [ :index, :show, :new, :create ]
  before_filter	:authorize_logged_in, :except => [ :index, :show ]
  before_filter :find_bundle
  
  
  # GET /bundle_comments
  # GET /bundle_comments.xml
  def index
    @bundle_comments = @bundle.bundle_comments

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bundle_comments }
    end
  end

  # GET /bundle_comments/1
  # GET /bundle_comments/1.xml
  def show
    @bundle_comment = @bundle.bundle_comments.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bundle_comment }
    end
  end

  # GET /bundle_comments/new
  # GET /bundle_comments/new.xml
  def new
    @bundle_comment = BundleComment.new
    @bundle_comment.user_id = @user
 
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bundle_comment }
    end
  end

  # GET /bundle_comments/1/edit
  def edit
    # @bundle_comment = BundleComment.find(params[:id])
    @bundle_comment = @bundle.bundle_comments.find( params[:id] )
  end

  # POST /bundle_comments
  # POST /bundle_comments.xml
  def create
    # @bundle_comment = BundleComment.new(params[:bundle_comment])
    @bundle_comment = @bundle.bundle_comments.build( params[:bundle_comment] )
    @bundle_comment.user_id = @user.id

    respond_to do |format|
      if @bundle_comment.save
        flash[:notice] = 'Your comment was successfully created.'
        format.html { redirect_to bundle_url(@bundle) }
        format.xml  { render :xml => @bundle_comment, :status => :created, :location => bundle_comment_url( @bbundle, @bundle_comment ) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bundle_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bundle_comments/1
  # PUT /bundle_comments/1.xml
  def update
    # @bundle_comment = BundleComment.find(params[:id])
    @bundle_comment = @bundle.bundle_comments.find( params[:id] )
    
    respond_to do |format|
      if @bundle_comment.update_attributes(params[:bundle_comment])
        flash[:notice] = 'BundleComment was successfully updated.'
        format.html { redirect_to bundle_bundle_comment_url( @bundle, @bundle_comment ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bundle_comments/1
  # DELETE /bundle_comments/1.xml
  def destroy
    # @bundle_comment = BundleComment.find(params[:id])
    @bundle_comment = @bundle.bundle_comments.find(params[:id])
    @bundle_comment.destroy

    respond_to do |format|
      format.html { redirect_to bundle_url(@bundle) }
      format.xml  { head :ok }
    end
  end
  
  
  
  private 
    
  def find_bundle
    @bundle = Bundle.find( params[:bundle_id] )
  end
  
end
