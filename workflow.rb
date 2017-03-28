class Workflow

    @@logger = Logger.new("Workflow")

    def initialize(id=nil)
        if id.is_a? Hash
            @@logger.push("Creating workflow...")
            @@logger.pop("Workflow #{} created.")
        elsif id.is_a? Integer
            @@logger.log("Retrieving workflow #{id}...")
        else
            @@logger.log("Invalid ID or setup hash '#{id.inspect}'.", Logger::ERROR)
        end
    end

end