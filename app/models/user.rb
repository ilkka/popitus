class User < ActiveRecord::Base
  require 'digest/sha1'
  
  # set password
  def password=(str)
    write_attribute 'password', Digest::SHA1.hexdigest(str)
  end
  
  # get password
  def password
    # not for reals ey
    return '********'
  end
  
  # authenticate, return user or nil if unsuccessful
  def User.authenticate(username, password)
    begin
      RAILS_DEFAULT_LOGGER.debug "User: #{username}"
      RAILS_DEFAULT_LOGGER.debug "Pass: #{password}, hash: #{Digest::SHA1.hexdigest(password)}"
      user = find :first, :conditions => [ "name = ? and password = ?",
        username, Digest::SHA1.hexdigest(password) ]
      RAILS_DEFAULT_LOGGER.debug "User obj: #{user}"
    rescue => ex
      exbt = ex.backtrace.join("\n")
      RAILS_DEFAULT_LOGGER.debug "Error:\n#{ex.message}\nBacktrace: #{exbt}"
      return nil
    end
  end
  
end
