require 'singleton'

class GoogleDriveSession
  include Singleton
  
  def initialize
    @session = GoogleDrive.login(ENV['USER_NAME'],ENV['PASSWORD'])
  end

  def session
    @session
  end
end
