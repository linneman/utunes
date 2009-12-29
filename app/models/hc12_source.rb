class Hc12Source < ActiveRecord::Base
  
  validates_uniqueness_of     :version
  
  attr_accessor               :hc12_ls_valid, :hc12_hs_valid
  
  def validate
    unless @hc12_ls_valid
      errors.add_to_base("hc12 ls file size incorrect") 
    end
    
    unless @hc12_hs_valid
      errors.add_to_base("hc12 ls file size incorrect") 
    end
    
    unless version
      errors.add_to_base("version number is not defined!")
    else
      unless version >= 0 && version <= 99
        errors.add_to_base("version must be between 0 and 99") 
      end
    end

  end
  
  
  #
  #  copies hc12 generation script template 
  #  from   lib/build_bundle/tempaltes/build_hc12_vnn to
  #  to     lib/build_bundle/build_hc12_v$(2 digit version number)
  #
  def before_save
    # cwd: utunes_app
    logger.info("=======> before_save invoked!")
    
    version_str = sprintf("%.2d", version )
    bundle_title = "hc12_v#{version_str}"
    
    #
    # copy template folder
    #
    bundle_folder = "lib/build_bundle"
    bundle_name="build_" + bundle_title
    bundle_fq_name = bundle_folder + "/" + bundle_name
    
    template_folder = bundle_folder + "/" + "templates"
    template_name = "build_hc12_vnn"
    template_fq_name = template_folder + "/" + template_name
    
    logger.info("cp -R #{template_fq_name} #{bundle_fq_name}")
    logger.info( %x[cp -R #{template_fq_name} #{bundle_fq_name}] )
    
    #
    # move image files to new bundle script folder
    #
    images_folder = "public/upload"
    
    image_ls_name = "hc12_ls.bin"
    image_fq_ls_name = images_folder + "/" + image_ls_name
        
    image_hs_name = "hc12_hs.bin"
    image_fq_hs_name = images_folder + "/" + image_hs_name
    
    image_fq_ls_target = "#{bundle_fq_name}/hc12_images/hc12ft.txt"
    image_fq_hs_target = "#{bundle_fq_name}/hc12_images/hc12hs.txt"
     
    logger.info("mv #{image_fq_ls_name} #{image_fq_ls_target}")
    logger.info( %x[mv #{image_fq_ls_name} #{image_fq_ls_target}] )
    
    logger.info("mv #{image_fq_hs_name} #{image_fq_hs_target}")
    logger.info( %x[mv #{image_fq_hs_name} #{image_fq_hs_target}] )
    
    #
    # creation version file
    #
    File.open(bundle_fq_name+"/hc12_images/version", "w") do |verfile|
      verfile.printf(version_str)
    end
    
  end
  
  
  #
  #  removes hc12 generation script  
  #     lib/build_bundle/build_hc12_v$(2 digit version number)
  #
  def before_destroy
    # cwd: utunes_app
    logger.info("=======> before_destroy invoked!")

    version_str = sprintf("%.2d", version )
    bundle_title = "hc12_v#{version_str}"
       
    #
    # copy template folder
    #    
    bundle_folder = "lib/build_bundle"
    bundle_name="build_" + bundle_title
    bundle_fq_name = bundle_folder + "/" + bundle_name
        
    logger.info("rm -R #{bundle_fq_name}")
    logger.info( %x[rm -R #{bundle_fq_name}] )
        
  end
  
  
  
  
  
  
  def upload_hc12_ls=(file)
    logger.info("---> upload_hc12_ls: " + file.to_s );
    logger.info("---> file size: " + file.length.to_s )
    
    if file.length > 500000 || file.length < 10000
      @hc12_ls_valid = false
		else		
		  @hc12_ls_valid = true
			out = File.open("public/upload/hc12_ls.bin", "w")
			out.write( file.read )
			out.close
		end
  end
  
  
  def upload_hc12_hs=(file)
    logger.info("---> upload_hc12_hs: " + file.to_s );
    logger.info("---> file size: " + file.length.to_s )
    
    if file.length > 500000 || file.length < 10000
      @hc12_hs_valid = false
		else		
		  @hc12_hs_valid = true
			out = File.open("public/upload/hc12_hs.bin", "w")
			out.write( file.read )
			out.close
		end
  end
  
  
end
