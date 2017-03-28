module Workflow

    @@logger = Logger.new("Workflow")

    def self.create(details)
        @@logger.push("Creating workflow...")
        begin
            id = 0 # TODO: remove this and have it obtained from the database.
            # TODO: add workflow to database.
            @@logger.pop("Workflow #{id} created.")
            return id
        rescue Exception => e
            @@logger.pop(e.to_s, Logger::ERROR)
            return nil
        end
    end

    def self.all
        @@logger.log("Retrieving all workflows...")
        begin
            all_workflows = [] # TODO: remove this and have it obtained from the database.
            # TODO: add workflow to database.
            return all_workflows
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            return nil
        end
    end

    def self.read(id)
        return all if id.nil?
        @@logger.log("Retrieving workflow #{id}...")
        begin
            if exists?(id)
                workflow = nil
                # TODO: retrieve workflow
                return workflow
            else
                return nil
            end
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            return nil
        end
    end

    def self.update(id, details)
        @@logger.log("Updating workflow #{id}...")
        begin
            if exists?(id)
                # TODO: update workflow
                return true
            else
                return false
            end
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            return nil
        end
    end

    def self.delete(id)
        @@logger.log("Deleting workflow #{id}...")
        begin
            if exists?(id)
                # TODO: delete workflow
                return true
            else
                return false
            end
        rescue Exception => e
            @@logger.log(e.to_s, Logger::ERROR)
            return nil
        end
    end

    def self.exists?(id)
        return false # TODO: make this check the database.
    end

end