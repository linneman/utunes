class BundleSource < ActiveRecord::Base

  has_many  :audio_sources
  validates_uniqueness_of :title
  validates_presence_of   :title
  
  attr_accessor :content_type
  
  # setter/getter for the audio prompt sample (AudioSource id)
  # used by selection field in bundle_sources edit pane
  attr_accessor :sample_file_id 
  
  # setter/getter for the notification of the file handling
  # result to the final model validation routing
  attr_accessor :was_upload_successful   
  
  
  # validates_format_of :content_type, :with => /^image\/(png)|(jpeg)|(gif)/i, :message => " --- jpg, png or gif images" 
  
  def validate
    if( title =~ /^hc12/ || title =~ /^bthfck2/ )
      errors.add_to_base("Titles which begin with 'hc12' or 'bthfck2' are reserved!" )
    end
    
    if( title =~ /[^\s^_A-Z^a-z^0-9^-]/ )
      errors.add_to_base("Only digits, characters, '-' and blanks are allowed for the title!")
    end

    if( ( bundle = Bundle.find_by_title(title) ) != nil )
      if(  bundle.created_by_user_id != user_id )
        errors.add_to_base("This title is already used! Choose another one.")
      end
    end
    
    if content_type
      unless( content_type =~ /^image\/(png)|(jpeg)|(gif)/i )
        errors.add_to_base("Images must have the format jpg, png or gif")
      end
      
      unless was_upload_successful
        errors.add_to_base("Image file is too big. It must be smaller then 300K")
      end
      
    end
    
  end
    
    
  #
  # maps database language encoding (SSFT) to generalized language representation
  #
  def language
    case 
      when self.ENU || self.ENG then "ENG"
      when self.SPM || self.SPE then "SPE"
      when self.FRC || self.FRF then "FRF"
      when self.ITI then "ITI"
      when self.DUN then "DUN"
      when self.GED then "GED"
    end
  end
  
  # 
  # maps generalized language representation to database language encoding (SSFT)
  #
  def language=(lang)
    case
      when lang=="ENG" then self.ENU=true;  self.ENG=true;  self.SPM=false; self.SPE=false; self.FRC=false; self.FRF=false; self.ITI=false; self.DUN=false; self.GED=false
      when lang=="SPE" then self.ENU=false; self.ENG=false; self.SPM=true;  self.SPE=true;  self.FRC=false; self.FRF=false; self.ITI=false; self.DUN=false; self.GED=false
      when lang=="FRF" then self.ENU=false; self.ENG=false; self.SPM=false; self.SPE=false; self.FRC=true;  self.FRF=true;  self.ITI=false; self.DUN=false; self.GED=false
      when lang=="ITI" then self.ENU=false; self.ENG=false; self.SPM=false; self.SPE=false; self.FRC=false; self.FRF=false; self.ITI=true;  self.DUN=false; self.GED=false
      when lang=="DUN" then self.ENU=false; self.ENG=false; self.SPM=false; self.SPE=false; self.FRC=false; self.FRF=false; self.ITI=false; self.DUN=true;  self.GED=false
      when lang=="GED" then self.ENU=false; self.ENG=false; self.SPM=false; self.SPE=false; self.FRC=false; self.FRF=false; self.ITI=false; self.DUN=false; self.GED=true
    end
  end
  
  def language_name
    case
      when self.ENU || self.ENG then "English"
      when self.SPM || self.SPE then "Spain"
      when self.FRC || self.FRF then "French"
      when self.ITI then "Italien"
      when self.DUN then "Dutch"
      when self.GED then "German"
    end
  end
  
  
  # returns the user's upload folder within the upload directory
  def userfolder
    # "public/upload/user_id_" + self.user_id.to_s
    User.find_by_id( self.user_id ).userfolder
  end
  
  # returns the bundle directory within the user's folder
  def bundle_src_folder
    "bundle_src_id_" + self.id.to_s
  end
  
  
  # returns the name of the illustrating image and sample.mp3 
  # in the upload/images and upload/audio folders
  def bundle_resouce_file_name
    self.title.gsub(/\s/,"_")
  end
  
  
  # returns full qualified file name for bundle illustration picture
  def fq_bundle_image_filename( extention )
    # File.join( self.userfolder, self.bundle_src_folder, self.bundle_resouce_file_name ) + "." + extention
    File.join( "public/upload/images", self.bundle_resouce_file_name ) + "." + extention
  end  
  
  
  # returns full qualified file name for audio prompt sample MP3 file
  def fq_bundle_sample_prompt
    "public/upload/audio/" + bundle_resouce_file_name + ".mp3"
  end
  
  
  # takes temporary object, actual filehandling is done later in before_save
  def uploadicon=(file)
    unless( file.blank? )
      logger.info("original_filename: " + file.original_filename )
      self.content_type = file.content_type.chomp
      logger.info("content_type: " + self.content_type )
      filename = base_part_of( file.original_filename ) 
        
      if(file.length < 300000 )
        @uploadfile = file      
        self.was_upload_successful = true
      else
        self.was_upload_successful = false
      end
    
    end
  end



  # do the actual file house keeping
  # for performance reasons audio data is kept outside the database
  # but therefore we need the full record information to maintain
  # the users folder structure
  def before_save 
    
    #
    # upload bundle image
    #
    if( @uploadfile )
      
      # clean up first all existing image files
      ["jpeg", "gif", "png"].each do |ext| 
          f = fq_bundle_image_filename( ext )
          if File.exists?(f) 
            File.delete(f)
          end
      end
    
      # write the upload file
      extention = @uploadfile.content_type.gsub(/^image\//, '').downcase.chomp
      out = File.open( fq_bundle_image_filename( extention ), "w" )
      out.write( @uploadfile.read )
      out.close
    
      # integrate link in description
      desc = self.description 
      # filter operations can be inserted later on
      updated_img_lnk = "[[File:#{bundle_resouce_file_name}.#{extention}]]"
      desc = desc.gsub( /\[\[file:.*?\.((jpeg)|(jpg)|(png)|(gif))\]\]/i, updated_img_lnk )
      if( ! $~ )
        # if not already matched add link tag to the end of the description field
         desc << "\n" + updated_img_lnk
      end
      self.description = desc
    end


    #
    #  copy prompt sample for bundle description (/upload/audio)
    #
    if( @sample_file_id )
      audio_source = AudioSource.find_by_file_id( @sample_file_id, :conditions => { :bundle_source_id=>self.id } )
      logger.info( @sample_file_id )
      if( audio_source )
        # copy file
        audio_source = audio_source.fq_mp3_filename
        audio_target = "public/upload/audio/" + bundle_resouce_file_name + ".mp3"
      
        %x[cp #{audio_source} #{audio_target}]
        sample_prompt_file_tag = "[[File:#{bundle_resouce_file_name}.mp3]]"
      
        # integrate prompt sample in description
        desc = self.description
        desc = desc.gsub( /\[\[file:.*?\.((mp3))\]\]/i, sample_prompt_file_tag )

        if( ! $~ )
          # if not already matched add link tag to the end of the description field
          desc << "\n" +sample_prompt_file_tag
        end
      
        self.description = desc 
      end
    end

  end # before_save


  # file system maintainance
  def after_destroy
    bundle_dir = File.join( self.userfolder, self.bundle_src_folder )
    logger.info("==================> Remove all bundle files for: " +  bundle_dir )
    %x[rm -f -R #{bundle_dir}]
    
    # delete bundle image file name
    %x[rm #{fq_bundle_image_filename('*')}]
    
    #delete sample audio prompt
    %x[rm #{fq_bundle_sample_prompt}]
  end


  private

  def base_part_of(file_name) 
  	File.basename(file_name).gsub(/[^\w._-]/, '') 
  end  
  
  
end
