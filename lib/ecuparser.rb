# Helper class for parsing U-Connect's ECU control file (ecu.ini)
# implements check and getters for version-, part- and serial numbers

class EcuParser

  def initialize(ecudata)
    @ecudata = ecudata || ""
    @len = @ecudata.length
  end 


  def version
    @ecudata[18..19]+'.'+@ecudata[20..21]+'.'+@ecudata[22..23]    
  end 

  def partnr
    @ecudata[@len-38..@len-29]
  end 

  def serialnr
    @ecudata[@len-28..@len-15]
  end 

  def check
    ( @ecudata =~ /^__0123456789__.*__ABCDEFGHIJ__$/m )  == 0  &&  \
    ( version >= '00.00.00'  &&  version <= '99.99.99' ) && \
		( serialnr >= '00000000000000' && serialnr <= '99999999999999' )
  end 

end

