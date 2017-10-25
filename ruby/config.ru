# origin: https://gist.github.com/trevorturk/91cb43c79e71e3d23649f6d103217de7
#
# gem install rails
# rackup
# open http://localhost:9292/

require 'action_controller/railtie'

class HelloWorld < Rails::Application
  routes.append do
    root to: 'hello#world'
  end

  config.secret_key_base = SecureRandom.hex(30)
  config.eager_load = false
  config.logger = Logger.new(STDOUT)
end

class HelloController < ActionController::Base
  def world
    render plain: 'Hello, World!'
  end
end

HelloWorld.initialize!

run HelloWorld
