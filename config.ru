require_relative "chat"
require_relative "room"

room = Room.new

use Rack::Static, :urls => ["/css", "/js"], :index => "index.html"

run Chat.new(room)
