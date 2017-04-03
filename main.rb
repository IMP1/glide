#!/usr/bin/env ruby

require_relative 'web_server'
require_relative 'tests'

webserver = WebServer.new(2345)
webserver.begin

location = Tests.test_post
Tests.test_get(location)

# puts
# loop do
#     print "> "
#     command = gets.chomp
#     if command == "q"
#         break
#     end
# end

webserver.stop
