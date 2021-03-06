module Tests

    def self.test_post
        puts "<Test> Testing HTTP POST..."
        begin
            uri = URI.parse("http://localhost:2345/workflows/")
            # Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
            Net::HTTP.start(uri.host, uri.port) do |http|
                request = Net::HTTP::Post.new(uri)
                request.basic_auth 'username', 'password'
                request.set_form_data({"q" => "My query", "per_page" => "50"})
                response = http.request(request)
                puts "---Begin Response Head---"
                response.header.each_header { |k, v| puts "#{k}: #{v.inspect}" }
                puts "---End Response---"
                return response.header["location"]
            end
        rescue Exception => e
            puts "<Test> Rescued exception:"
            p e
        end
        puts "<Test> Test Complete."
    end

    def self.test_get(location)
        puts "<Test> Testing GET (workflow 1)..."
        begin
            uri = URI.parse("http://localhost:2345/#{location}")
            response = Net::HTTP.get(uri)
            puts "---Begin Response Body---"
            puts response
            puts "---End Response---"
        rescue Exception => e
            puts "<Test> Rescued exception:"
            p e
        end
        puts "<Test> Test Complete."
    end

end