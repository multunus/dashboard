require 'singleton'

class GoogleDriveSession
  include Singleton
  
  def initialize
    puts "Inside INITIALIZE"
    @session = GoogleDrive.login('sandeep.v@multunus.com', 'separtir')
  end

  def session
    @session
  end
end
