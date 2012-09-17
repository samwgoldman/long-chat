require_relative "chat"
require_relative "log"

$log = Log.new
$log.say("Sam", "Welcome to the chat!")

use Rack::Static, :urls => ["/css", "/js"], :index => "index.html"

use Rack::Lint
run Chat.new($log)
