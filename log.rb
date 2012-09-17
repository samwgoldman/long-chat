require "json"
require "thread"

Message = Struct.new(:etag, :username, :text)

class Log
  def initialize(messages = [])
    @messages = messages
    @mutex = Mutex.new
  end

  def say(username, text)
    etag = Time.now.hash.to_s
    message = Message.new(etag, username, text)
    @mutex.synchronize do
      @messages.unshift message
    end
  end

  def since(etag)
    if etag
      @mutex.synchronize do
        Log.new @messages.take_while { |m| m.etag != etag }
      end
    else
      self
    end
  end

  def etag
    if latest = @messages[0]
      latest.etag
    end
  end

  def empty?
    @messages.empty?
  end

  def to_json
    JSON.dump @messages.map { |m| { :username => m.username, :text => m.text } }
  end
end
