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
require 'openssl'
require 'json'
require 'date'

require_relative 'log'
require_relative 'rml'
require_relative 'glide_command_handler'

Thread.abort_on_exception=true

class WebServer

    WEB_ROOT   = "."
    EMPTY_LINE =  "\r\n"

    def self.file_contents(filepath)
        filename = File.join(WEB_ROOT, *clean_file_path(filepath))
        if File.exists?(filename)
            return File.read(filename)
        else
            return nil
        end
    end

    def self.clean_file_path(filepath)
        if filepath.is_a?(String)
            filepath = filepath.split("/")
        end
        clean = []
        filepath.each do |part|
            next if part.empty? || part == '.'
            case part
            when '..'
                clean.pop
            when '~'
                clean.push(WEB_ROOT)
            else
                clean.push(part)
            end
        end
        return clean
    end

    def initialize(port)
        @port = port
        @logger = Logger.new("WebServer")
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
        @logger.log("Listening on localhost:#{@port}")
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
        @logger.log("Connected to socket: #{socket}")
        request = socket.gets
        handle_request(socket, request)
        socket.close
    end

    def handle_request(socket, request)
        @logger.log("Received request: #{request}")
        request_method, *request_parts = request.split(" ")
        path = request_parts[0].split('/')
        datatype = path[1]
        data_id = path[2].nil? ? nil : path[2].to_i
        begin
            case request_method
            when "HEAD"
                handle_head(socket, datatype, data_id)
            when "POST"
                handle_post(socket, datatype, data_id)
            when "GET"
                handle_get(socket, datatype, data_id)
            when "PUT"
                handle_put(socket, datatype, data_id)
            when "DELETE"
                handle_delete(socket, datatype, data_id)
            end
        rescue Exception => e
            @logger.log(e.to_s, Logger::ERROR)
            server_error(socket, "An internal error occurred. You've done nothing wrong. Try again in a bit.")
        end
    end

    def handle_head(socket, datatype, data_id)
        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def handle_post(socket, datatype, data_id)
        headers = {}
        loop do
            line = socket.gets.split(' ', 2)
            break if line[0] == ""
            headers[line[0].chop] = line[1].strip
        end
        post_body = socket.read(headers["Content-Length"].to_i)

        specific_item = !data_id.nil?
        data = Hash[post_body.split(/\&/).map{ |pair| pair.split("=") }]

        if specific_item
            exists = GlideCommandHandler.exists?(datatype, data_id)
            if exists.nil?
                bad_request(socket, "'#{datatype}' not recognised. Cannot create.")
            elsif exists == false
                file_not_found(socket)
            else
                socket.print http_header(409, "Conflict")
                socket.print EMPTY_LINE
            end
        else
            new_id = GlideCommandHandler.create(datatype, data)
            if new_id.nil?
                bad_request(socket, "'#{datatype}' not recognised. Cannot create.")
            else
                socket.print http_header(201, "Created", {"Location"=>"/#{datatype}/#{new_id}"})
                socket.print EMPTY_LINE
            end
        end
    end

    def handle_get(socket, datatype, data_id)
        all_of_datatype = data_id.nil?

        data_obj = GlideCommandHandler.read(datatype, data_id)
        @logger.log("Data Object = #{data_obj.inspect}", Logger::DEBUG)

        if data_obj.nil?
            bad_request(socket, "'#{datatype}' not recognised. Cannot read.")
            return
        elsif data_obj == false
            file_not_found(socket, "No #{datatype} with id #{data_id}.")
            return
        end

        if all_of_datatype
            serve_file(socket, [datatype, 'all.rml'], {datatype.to_sym=>data_obj})
        else
            object_name = datatype.end_with?(?s) ? datatype[0..-2] : datatype
            serve_file(socket, ["#{datatype}.rml"], {:id=>data_id, object_name.to_sym=>data_obj})
        end
    end

    def handle_put(socket, datatype, data_id)
        headers = {}
        loop do
            line = socket.gets.split(' ', 2)
            break if line[0] == ""
            headers[line[0].chop] = line[1].strip
        end
        post_body = socket.read(headers["Content-Length"].to_i)

        data = Hash[post_body.split(/\&/).map{ |pair| pair.split("=") }]

        success = GlideCommandHandler.update(datatype, data_id, data)

        if success.nil?
            bad_request(socket, "'#{datatype}' not recognised. Cannot update.")
            return
        elsif success == false
            file_not_found(socket, "No #{datatype} with id #{data_id}.")
            return
        end

        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def handle_delete(socket, datatype, data_id)

        success = GlideCommandHandler.delete(datatype, data_id)

        if success.nil?
            bad_request(socket, "'#{datatype}' not recognised. Cannot delete.")
            return
        elsif success == false
            file_not_found(socket, "No #{datatype} with id #{data_id}.")
            return
        end

        socket.print http_header(204, "No Content")
        socket.print EMPTY_LINE
    end

    def serve_file(socket, filepath, variables)
        file_string = WebServer.file_contents(filepath)
        if file_string.nil?
            file_not_found(socket)
            return
        end

        content_type = 'text/xml'
        if filepath.last.end_with? ".rml"
            file_string = RMLParser.new(file_string, filepath.last).parse(variables)
            content_type = 'text/html'
        end

        file_string += EMPTY_LINE
        socket.print http_header(200, "OK", {"Content-Type"=>content_type, "Content-Length"=>file_string.bytesize})
        socket.print EMPTY_LINE
        socket.print file_string
    end

    def file_not_found(socket, message="File not found")
        message += EMPTY_LINE
        socket.print http_header(404, "Not Found", {"Content-Type"=>"text/plain", "Content-Length"=>message.size})
        socket.print EMPTY_LINE
        socket.print message
        @logger.log(message, Logger::DEBUG)
    end

    def bad_request(socket, message="Bad Request")
        message += EMPTY_LINE
        socket.print http_header(400, "Bad Request", {"Content-Type"=>"text/plain", "Content-Length"=>message.size})
        socket.print EMPTY_LINE
        socket.print message
        @logger.log(message, Logger::DEBUG)
    end

    def server_error(socket, message="Internal Server Error")
        message += EMPTY_LINE
        socket.print http_header(500, "Internal Server Error", {"Content-Type"=>"text/plain", "Content-Length"=>message.size})
        socket.print EMPTY_LINE
        socket.print message
        @logger.log(message, Logger::ERROR)
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