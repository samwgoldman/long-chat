require "rack/request"
require "rack/response"

class Chat
  def initialize(log, timeout = 25)
    @log = log
    @timeout = timeout
  end

  def call(env)
    request = Rack::Request.new(env)
    case request.request_method
    when "GET"
      etag = env["HTTP_IF_NONE_MATCH"] rescue nil
      messages(etag)
    when "POST"
      say(request.params)
    else
      [405, { "Content-Type" => "text/plain" }, ["Method Not Allowed"]]
    end
  end

  def messages(etag)
    log = []
    time = Time.now

    while log.empty?
      log = @log.since(etag)
      break if Time.now - time > @timeout
    end

    if etag && log.empty?
      [304, { "Cache-Control" => "no-cache" }, []]
    else
      ok(log)
    end
  end

  def say(params)
    begin
      username = params.fetch("username")
      message = params.fetch("message")
      @log.say(username, message)
      [201, { "Content-Type" => "text/plain" }, ["Created"]]
    rescue KeyError
      [422, { "Content-Type" => "text/plain" }, ["Unprocessable Entity"]]
    end
  end

  def ok(log)
    response = Rack::Response.new
    response["Content-Type"] = "application/json"
    response["Cache-Control"] = "no-cache"
    response["ETag"] = log.etag
    response.write log.to_json
    response.finish
  end
end
