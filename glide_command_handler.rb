require_relative 'workflow'

module GlideCommandHandler

    @logger = Logger.new("GlideAPI")

    def self.create(datatype, options)
        case datatype
        when "workflow"
            workflow_details = args[0]
            workflow = Workflow.create(workflow_details)
            return workflow.id
        else

        end
    end

    def self.read(datatype, id)
        case datatype
        when "workflow"
            workflow_id = args[0]
            workflow = Workflow.read(workflow_id)
            return workflow
        else

        end
    end

    def self.update(datatype, id, options)
        case datatype
        when "workflow"
            workflow_id = args[0]
            workflow_details = args[1]
            success = Workflow.update(workflow_id, workflow_details)
            return success
        else

        end
    end

    def self.delete(datatype, id)
        case datatype
        when "workflow"
            workflow_id = args[0]
            success = Workflow.delete(workflow_id)
            return success
        else

        end
    end

end