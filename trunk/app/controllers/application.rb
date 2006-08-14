# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :play_track
  
  # just your standard runofthemill http auth
  def authorize(realm="popitus", errormsg="mee pois")
    username, password = get_auth_data
    if user = User.authenticate(username, password)
      # everything ok
      @session["user"] = user
    else
      @response.headers["Status"] = "Unauthorized"
      @response.headers["WWW-Authenticate"] = "Basic realm=\"#{realm}\""
      render :text => errormsg, :status => 401
    end
  end
  
private
  
  def get_auth_data
    user, pass = '', ''
    if request.env.has_key? 'X-HTTP_AUTHORIZATION'
      RAILS_DEFAULT_LOGGER.debug("x-auth: #{request.env['X-HTTP_AUTHORIZATION']}")
      authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split
    elsif request.env.has_key? 'HTTP_AUTHORIZATION'
      RAILS_DEFAULT_LOGGER.debug("auth: #{request.env['HTTP_AUTHORIZATION']}")
      authdata = request.env['HTTP_AUTHORIZATION'].to_s.split
    elsif request.env.has_key? 'Authorization'
      RAILS_DEFAULT_LOGGER.debug("auth: #{request.env['Authorization']}")
      authdata = request.env['Authorization'].to_s.split
    else
      RAILS_DEFAULT_LOGGER.debug("no auth headers!!")
    end
    
    if authdata and authdata[0] == 'Basic'
      RAILS_DEFAULT_LOGGER.debug("'Basic' auth")
      user,pass = Base64.decode64(authdata[1]).split(':')[0..1]
      RAILS_DEFAULT_LOGGER.debug("user: #{user}, pass: #{pass}")
    end
    
    return user,pass
  end
end
