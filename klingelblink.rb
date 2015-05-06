#!/usr/bin/env ruby

GPIO_CMD     = "gpio"
GPIO_PORT    = 15
DURATION_ON  = 0.3
DURATION_OFF = 0.5
REPEAT       = 16

# Must be set BEFORE requiring sinatra!
at_exit do
  gpio "write", GPIO_PORT, "0"
end

require "thread"
require "bundler"
Bundler.require

Thread.abort_on_exception = true
$semaphore = Mutex.new

def gpio(*args)
  args.unshift GPIO_CMD
  args = args.map(&:to_s)
  system(*args) or raise "Running '#{args.join(' ')}' failed with exit status #{$?.exitstatus}."
end

def klingelblink
  Thread.new do
    $semaphore.synchronize do
      gpio "mode", GPIO_PORT, "out"
      REPEAT.times do
        gpio "write", GPIO_PORT, "1"
        sleep DURATION_ON
        gpio "write", GPIO_PORT, "0"
        sleep DURATION_OFF
      end
    end
  end
end

configure :production do
  set :port, 80
end

get "/" do
  erb :index
end

post "/klingelblink" do
  klingelblink
  erb :klingelblink
end


system "gpio mode #{GPIO_PORT} out"
