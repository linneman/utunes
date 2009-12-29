module AudioSourcesHelper
  
  
  # generate html multimedia object for the playback of upload audio prompts
  def mp3url( audio_source )
    %Q|<embed src="#{url_for :controller=>audio_source.mp3_url }" width="140" height="60" loop=false autostart=false>|
  end
    
  
end
