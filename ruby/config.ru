# origin: https://gist.github.com/trevorturk/91cb43c79e71e3d23649f6d103217de7
#
# gem install rails
# rackup
# open http://localhost:9292/

require 'action_controller/railtie'

require "http"

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
    keyword = params[:keyword]
    target = params[:target]
    if HTTP.get(target).to_s.include? keyword
      render plain: 'true'
    else
      render plain: 'false'
    end
  end
end

HelloWorld.initialize!

run HelloWorld
