require 'dashing'

configure do
  set :auth_token, '1619100dcd9f90c192bed21e45778041'

  set :refresh_interval, '15'
  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end

    #Get next dashboard name cyclically
    def get_next_dashboard(current)
      files = Dir[File.join(settings.views, '*.erb')].collect { |f| f.match(/(\w*).erb/)[1] }
      files -= ['layout']
      files[(files.index(current)+1)%files.count]
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
