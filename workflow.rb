
## http://sequel.jeremyevans.net/

module Workflow

    @@logger = Logger.new("Workflow")

    def self.create(details)
        @@logger.log("Creating workflow.", Logger::DEBUG)
        begin
            id = 0 # TODO: remove this and have it obtained from the database.
            # TODO: add workflow to database.
            return id
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            raise e
        end
    end

    def self.all
        @@logger.log("Retrieving all workflows.", Logger::DEBUG)
        begin
            all_workflows = [] # TODO: remove this and have it obtained from the database.
            # TODO: add workflow to database.
            return all_workflows
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            raise e
        end
    end

    def self.read(id)
        return all if id.nil?
        @@logger.log("Retrieving workflow #{id}.", Logger::DEBUG)
        begin
            if exists?(id)
                workflow = :foobar
                # TODO: retrieve workflow
                return workflow
            else
                return false
            end
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            raise e
        end
    end

    def self.update(id, details)
        @@logger.log("Updating workflow #{id}.", Logger::DEBUG)
        begin
            if !exists?(id)
                return false
            end
            # TODO: update workflow
            return true
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            raise e
        end
    end

    def self.delete(id)
        @@logger.log("Deleting workflow #{id}.", Logger::DEBUG)
        begin
            if !exists?(id)
                return false
            end
            # TODO: delete workflow
            return true
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            raise e
        end
    end

    def self.exists?(id)
        return true # TODO: make this check the database.
    end

end