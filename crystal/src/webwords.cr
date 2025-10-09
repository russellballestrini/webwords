require "kemal"
require "http/client"

get "/" do |env|
  keyword = env.params.query["keyword"]? || ""
  target = env.params.query["target"]? || ""
  found = "false"
  
  if !keyword.empty? && !target.empty?
    begin
      response = HTTP::Client.get(target)
      body = response.body
      
      if body.includes?(keyword)
        found = "true"
      end
      
      puts "found=#{found}, keyword=#{keyword}, uri=#{target}"
    rescue ex
      puts "Error: #{ex.message}"
    end
  end
  
  found
end

puts "listening on 0.0.0.0:31337"
Kemal.config.host_binding = "0.0.0.0"
Kemal.config.port = 31337
Kemal.run