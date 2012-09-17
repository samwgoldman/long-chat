require "rack/request"
require "rack/response"
require "json"

class Chat
  def initialize(room, timeout = 25)
    @room = room
    @timeout = timeout
    @mailbox = []
    @room.join(method(:receive))
  end

  def receive(username, text)
    @mailbox.unshift({
      :username => username,
      :text => text
    })
  end

  def call(env)
    request = Rack::Request.new(env)
    case request.request_method
    when "GET"
      messages
    when "POST"
      say(request.params)
    else
      [405, { "Content-Type" => "text/plain" }, ["Method Not Allowed"]]
    end
  end

  def messages
    time = Time.now

    while @mailbox.empty?
      sleep 0.1
      break if Time.now - time > @timeout
    end

    ok
  end

  def say(params)
    begin
      username = params.fetch("username")
      message = params.fetch("message")
      @room.say(username, message)
      [201, { "Content-Type" => "text/plain" }, ["Created"]]
    rescue KeyError
      [422, { "Content-Type" => "text/plain" }, ["Unprocessable Entity"]]
    end
  end

  def ok
    response = Rack::Response.new
    response["Content-Type"] = "application/json"
    response["Cache-Control"] = "no-cache"
    response.write @mailbox.to_json
    @mailbox.clear
    response.finish
  end
end
