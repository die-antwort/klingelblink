#!/usr/bin/env ruby

GPIO_PORT    = 15
DURATION_ON  = 0.3
DURATION_OFF = 0.5
REPEAT       = 16

# Must be set BEFORE requiring sinatra!
at_exit do
  system "gpio write #{GPIO_PORT} 0"
end

require "thread"
require "bundler"
Bundler.require

Thread.abort_on_exception = true
$semaphore = Mutex.new

def klingelblink
  Thread.new do
    $semaphore.synchronize do
      system "gpio mode #{GPIO_PORT} out"
      REPEAT.times do
        system "gpio write #{GPIO_PORT} 1"
        sleep DURATION_ON
        system "gpio write #{GPIO_PORT} 0"
        sleep DURATION_OFF
      end
    end
  end
end

configure do
  set :port, 80
end

get "/" do
  "Klingelblinkserver is running.\n\nUse 'GET /klingelblink' to activate.\n"
end

get "/klingelblink" do
  klingelblink
  "Klingelblinking!\n"
end


system "gpio mode #{GPIO_PORT} out"
