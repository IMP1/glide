require_relative 'workflow'

module GlideCommandHandler

    @logger = Logger.new("GlideAPI")

    def self.create(datatype, options)
        case datatype
        when "workflows"
            workflow_id = Workflow.create(options)
            return workflow_id
        else
            error_message = "'#{datatype}' not recognised. Cannot create."
            @logger.log(error_message, Logger::ERROR)
            return nil, error_message
        end
    end

    def self.read(datatype, id)
        case datatype
        when "workflows"
            workflow = Workflow.read(id)
            return workflow, nil
        else
            error_message = "'#{datatype}' not recognised. Cannot read."
            @logger.log(error_message, Logger::ERROR)
            return nil, error_message
        end
    end

    def self.update(datatype, id, options)
        case datatype
        when "workflows"
            success = Workflow.update(id, options)
            return success
        else
            error_message = "'#{datatype}' not recognised. Cannot update."
            @logger.log(error_message, Logger::ERROR)
            return nil, error_message
        end
    end

    def self.delete(datatype, id)
        case datatype
        when "workflows"
            success = Workflow.delete(id)
            return success
        else
            error_message = "'#{datatype}' not recognised. Cannot delete."
            @logger.log(error_message, Logger::ERROR)
            return nil, error_message
        end
    end

end