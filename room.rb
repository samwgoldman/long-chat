class Room
  def initialize(observers = [])
    @observers = observers
  end

  def join(observer)
    @observers << observer
  end

  def say(username, text)
    @observers.each do |observer|
      observer.call(username, text)
    end
  end
end
