require_relative 'workflow'

module GlideCommandHandler

    @logger = Logger.new("GlideAPI")

    def self.create(datatype, options)
        case datatype
        when "workflow"
            workflow = Workflow.create(options)
            return workflow.id
        else

        end
    end

    def self.read(datatype, id)
        case datatype
        when "workflow"
            workflow = Workflow.read(id)
            return workflow, nil
        else
            return nil, "'#{datatype}' not recognised."
        end
    end

    def self.update(datatype, id, options)
        case datatype
        when "workflow"
            success = Workflow.update(id, options)
            return success
        else

        end
    end

    def self.delete(datatype, id)
        case datatype
        when "workflow"
            success = Workflow.delete(id)
            return success
        else

        end
    end

end