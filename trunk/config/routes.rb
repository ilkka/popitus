ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # whole album stream
  map.connect 'play/:artist/:album', :controller => 'library', :action => 'play_album'
  # track urls
  map.connect ':artist/:album/:track', :controller => 'library', :action => 'play_track'
  # urls like /Fooartist/Barrecord
  map.connect ':artist/:album', :controller => 'library', :action => 'browse'
  # urls like /Fooartist
  map.connect ':artist', :controller => 'library', :action => 'browse'
  
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "library", :action => "browse"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
