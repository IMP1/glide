##
## Cheatsheet for Ruby HTTP stuff.
## http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
##
## HTTP methods/verbs for RESTful services.
## http://www.restapitutorial.com/lessons/httpmethods.html
##
## Simple web server over SSL
## http://stackoverflow.com/questions/5872843/trying-to-create-a-simple-ruby-server-over-ssl
##
## Setting up SSL certificates and stuff
## https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
##

require 'socket'
require 'uri'
require 'net/http'
require 'net/https'
require "openssl"
require 'json'
require 'date'

require_relative 'rhtml'
require_relative 'glide_api'

Thread.abort_on_exception=true

class WebServer

    WEB_ROOT   = "."
    EMPTY_LINE =  "\r\n"

    def initialize(port)
        @port = port
        # if File.exists?('keys/google_api')
        #     @api_key = File.read('keys/google_api')
        # else
        #     puts "Could not find 'keys/google_api' file."
        #     puts "Please create a file (without an extension) in this location."
        #     puts "This file should contain only your google api key."
        #     system("pause")
        #     exit(0)
        # end
    end

    def stop
        @thread.kill
        @server.close
    end

    def begin(block=false)
        @server = TCPServer.new('localhost', @port)

        # sslContext = OpenSSL::SSL::SSLContext.new
        # sslContext.cert = OpenSSL::X509::Certificate.new(File.open("cert.pem"))
        # sslContext.key = OpenSSL::PKey::RSA.new(File.open("priv.pem"))
        # @sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)

        puts "Listing on localhost:#{@port}..." 
        @thread = Thread.new { listen }
        @thread.join if block
    end

    def listen
        loop do
            # Thread.start(@sslServer.accept) do |connection|
            Thread.start(@server.accept) do |connection|
                handle_connection(connection)
            end
        end
    end

    def handle_connection(socket)
        puts
        puts "Connected to socket: #{socket}"
        request = socket.gets
        handle_request(socket, request)
        socket.close
    end

    def handle_request(socket, request)
        puts "Received request: #{request}"
        request_method, *request_parts = request.split(" ")
        path = request_parts[0].split('/')
        case request_method
        when "HEAD"
            handle_head(socket, path)
        when "POST"
            handle_post(socket, path)
        when "GET"
            handle_get(socket, path)
        when "PUT"
            handle_put(socket, path)
        when "DELETE"
            handle_delete(socket, path)
        end
    end

    def handle_head(socket, path)
        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def handle_post(socket, path)
        headers = {}
        loop do
            line = socket.gets.split(' ', 2)
            break if line[0] == ""
            headers[line[0].chop] = line[1].strip
        end
        post_body = socket.read(headers["Content-Length"].to_i)

        data = Hash[post_body.split(/\&/).map{ |pair| pair.split("=") }]
        GlideAPI.handle_command(path[1], "create", data)

        # TODO: handle data, create new X if valid, returning location to new X.
        socket.print http_header(201, "Created", {"Location"=>"/workflows/12"})
        socket.print EMPTY_LINE
    end

    def handle_get(socket, path)
        serve_file(socket, path)
    end

    def handle_put(socket, path)
        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def handle_delete(socket, path)
        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def serve_file(socket, filepath)
        filename = File.join(WEB_ROOT, *clean_file_path(filepath))
        unless File.exists?(filename)
            file_not_found(socket)
            return
        end

        file_string = File.read(filename)

        if filename.end_with? ".rhtml"
            file_string = RHTML.evaluate(file_string)
        end

        socket.print http_header(200, "OK", {"Content-Type"=>'text/xml', "Content-Length"=>file_string.bytesize})
        socket.print EMPTY_LINE
        socket.print file_string     
    end

    def clean_file_path(filepath)
        clean = []
        filepath.each do |part|
            next if part.empty? || part == '.'
            part == '..' ? clean.pop : clean.push(part)
        end
        return clean
    end

    def file_not_found(socket)
        message = "File not found\n"
        socket.print http_header(404, "Not Found", {"Content-Type"=>"text/plain", "Content-Length"=>message.size})
        socket.print EMPTY_LINE
        socket.print message
    end

    def http_header(status_code, status_message, headers={})
        response =  "HTTP/1.1 #{status_code} #{status_message}\r\n"
        headers.each do |key, value|
            response += "#{key}: #{value}\r\n"
        end
        response += "Connection: close\r\n"
        response
    end

end