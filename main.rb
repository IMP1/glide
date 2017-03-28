#!/usr/bin/env ruby

require_relative 'web_server'
require_relative 'tests'

webserver = WebServer.new(2345)
webserver.begin

Tests.test_get
Tests.test_post

# puts
# loop do
#     print "> "
#     command = gets.chomp
#     if command == "q"
#         break
#     end
# end

webserver.stop
