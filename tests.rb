module Tests

    def self.test_post
        puts "Testing HTTP POST..."
        begin
            uri = URI.parse("http://localhost:2345")
            # Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
            Net::HTTP.start(uri.host, uri.port) do |http|
                request = Net::HTTP::Post.new(uri)
                request.basic_auth 'username', 'password'
                request.set_form_data({"q" => "My query", "per_page" => "50"})
                response = http.request(request)
                p response
            end
            sleep(0.5)    
        rescue Exception => e
            puts "rescued exception:"
            p e
        end
        puts "Test Complete."
    end

    def self.test_rhtml
        puts "Testing RHTML..."
        begin
            uri = URI.parse("http://localhost:2345/test.rhtml")
            response = Net::HTTP.get(uri)
            puts response
        rescue Exception => e
            puts "rescued exception:"
            p e
        end
        puts "Test Complete."
    end

end