class LibraryController < ApplicationController
  layout 'default', :except => :play_track
  before_filter :load_cfg
  @@unsafe = /[?#"'& ]/
 
  def self.unsafe
    @@unsafe
  end

  def load_cfg
    cfg = YAML::load_file "#{RAILS_ROOT}/config/popitus.yml"
    @@base = cfg["music_library_root"]
  end
  
  def browse
    # default: list directories from the base, ignoring the dotdirs and stuff
    @artists = get_artists
    # if there's an artist, do something
    if @params['artist'] != nil
      @current_artist = @params['artist']
      @albums_by_artist = get_albums_by @current_artist
    end
    # same for album...
    if @params['album'] != nil
      @current_album = @params['album']
      @tracks = get_tracks_from @current_artist, @current_album
    end
    # ...and artist
    # legacy stuff left here only for reference purposes
    #if @params['artist'] != nil
    #  @current_artist = @params['artist']
    #  @albums_by_artist = get_albums_by @current_artist
    #end
  end
  
  def play_track
    # sanitize filename
    fn = File.expand_path File.join(@params['artist'], @params['album'], @params['track']), @@base
    # check that we're within the library base
    if fn !~ /^#{@@base}/
      render :text => "Soo soo", :status => 401
    else
      # TODO: check for webrick, do this instead:
      #f = File.open(fn)
      #send_data f.read
      send_file fn, :stream => true
    end
  end
  
  def play_album
    # check params
    an = File.expand_path File.join(@params['artist'], @params['album']), @@base
    if an !~ /^#{@@base}/
      render :text => "Soo soo", :status => 401
    else
      # get tracknames
      @tracks = get_tracks_from @params['artist'], @params['album']
      # add full path
      @tracks.each_index { |i|
        @tracks[i] = "http://" + @request.env['HTTP_HOST'] + '/' + @params['artist'] + '/' + @params['album'] + '/' + @tracks[i]
	@tracks[i] = URI::escape @tracks[i], @@unsafe
      }
      @response.headers["Content-type"] = "audio/mpegurl"
      @response.headers["Content-Disposition"] = "inline; filename=playlist.m3u"
      render :action => 'playlist', :layout => false
    end
  end
  
  private
  
  def get_artists
    Dir.entries(@@base).delete_if { |dir|
      dir == '.' or dir == '..'
    }.sort
  end
  
  def get_albums_by(artist)
    # TODO: implement check for album dir/symlink (show no files)
    Dir.entries(File.join(@@base, artist)).delete_if { |dir|
      dir == '.' or dir == '..'
    }.sort
  end
  
  def get_tracks_from(artist, album)
    Dir.entries(File.join(@@base, artist, album)).delete_if { |file|
      fn = File.join(@@base, artist, album, file)
      File.ftype(fn) != 'file' or fn !~ /\.(?:mp3|ogg|aac|m4a)$/
    }.sort
  end
  
end

