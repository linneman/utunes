class AudioSource < ActiveRecord::Base
  belongs_to  :bundle_source
  
  attr_accessor :content_type
  attr_accessor :was_upload_successful   
  
  validates_format_of :content_type, :with => /^audio\/(mpeg|mpg|mp3)/i, :message => " --- only mp3 encoding supported" 
  
  def validate
    unless was_upload_successful
      errors.add_to_base("decoding error or mp3 file to long!")
    end
  end

  def translation( lang_code )
    str = Translation.find_by_id( self.file_id ).send( lang_code.downcase )
    str.gsub( /<|>/,"")
  end


  # returns the user's upload folder within the upload directory
  def userfolder
    bundle_source.userfolder
  end
  
  
  # returns the bundle directory within the user's folder
  def bundle_src_folder
    bundle_source.bundle_src_folder
  end
  
  
  # returns the name of the MP3 file the user's has uploaded
  # this is converted into the U-Connects own codec format later on
  def prompt_upload_file
    "prompt_id_"+ self.id.to_s + ".mp3"
  end
  
  
  # full qualified directory for the download
  def fq_bundel_src_folder
    File.join( self.userfolder, self.bundle_src_folder )
  end
  
  
  # returns full qualified MP3 file name for backend file storage
  def fq_mp3_filename
    File.join( fq_bundel_src_folder, self.prompt_upload_file )
  end
  
  
  # returns full qualified speex encoded file name used for 
  # downloadable bundles
  def fq_spx_filename
    fq_mp3_filename.sub(/\.mp3$/,'.spx')
  end
  
  
  # returns full qualified MP3 url name for interactive playback
  # within audio source controller  
  def mp3_url
    File.join( "upload/user_id_" + BundleSource.find_by_id( self.bundle_source_id).user_id.to_s, self.bundle_src_folder, self.prompt_upload_file )
  end
  
  
  def uploadfile=(file)
    unless( file.blank? )
      logger.info("original_filename: " + file.original_filename )
      self.content_type = file.content_type.chomp
      logger.info("content_type: " + self.content_type )
      filename = base_part_of( file.original_filename ) 
        
      if(file.length < 1000000 )
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
  def after_save
    
    logger.info( "userfolder: " + self.userfolder )
    logger.info( "bundle_src_folder: " + self.bundle_src_folder )
    logger.info( "prompt_upload_file: " + self.prompt_upload_file )
    
    
    # make sure that required directories exist
    if( ! File.directory?( self.userfolder ) )
      Dir.mkdir( self.userfolder )
    end

    if( ! File.directory?( File.join( self.userfolder, self.bundle_src_folder ) ) )
      Dir.mkdir( File.join( self.userfolder, self.bundle_src_folder ) )
    end

    # write the upload file
    out = File.open( fq_mp3_filename, "w" )
    out.write( @uploadfile.read )
    out.close
    
    
    # convert to speex format
    # required external tools: sox, ffmpeg, uconnect_speex
    #
    
    # decode MP3
    tmp_wav = File.join( fq_bundel_src_folder, "tmp.wav" )
    bash_cmd = "ffmpeg -y -i #{fq_mp3_filename} #{tmp_wav} && "
    
    # resample and mix to one channel
    target_raw = fq_mp3_filename.sub(/\.mp3$/,'.raw')
    bash_cmd << "sox #{tmp_wav} -c 1 #{target_raw} rate 16k &&"
    
    # convert to target codec speex 
    # which is unforunately here in headerless format
    bash_cmd << "uconnect_speex_enc #{target_raw} #{fq_spx_filename}"
    
    # do all conversions inside the bash
		logger.info(bash_cmd)
		# `#{bash}`
		pipe= IO.popen("/bin/bash", 'w+') 
    pipe << bash_cmd 
    pipe.close_write
    result=pipe.read

		logger.info(result)

    File.delete( tmp_wav ) 
    File.delete( target_raw )
    
  end


  # file system maintainance
  def after_destroy
    logger.info("-----> Delete: " + fq_mp3_filename )
    if File.exist?( fq_mp3_filename )
      File.delete( fq_mp3_filename )
    end
    
    logger.info("-----> Delete: " + fq_spx_filename )
    if File.exist?( fq_spx_filename )
      File.delete( fq_spx_filename )
    end

  end


  private

  def base_part_of(file_name) 
  	File.basename(file_name).gsub(/[^\w._-]/, '') 
  end 
  
end
