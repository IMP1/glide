require_relative 'workflow'

module GlideCommandHandler

    @logger = Logger.new("GlideAPI")

    def self.create(datatype, options)
        case datatype
        when "workflows"
            return Workflow.create(options)
        else
            return nil
        end
    end

    def self.read(datatype, id)
        case datatype
        when "workflows"
            return Workflow.read(id)
        else
            return nil
        end
    end

    def self.update(datatype, id, options)
        case datatype
        when "workflows"
            return Workflow.update(id, options)
        else
            return nil
        end
    end

    def self.delete(datatype, id)
        case datatype
        when "workflows"
            return Workflow.delete(id)
        else
            return nil
        end
    end

    def self.exists?(datatype, id)
        case datatype
        when "workflows"
            return Workflow.exists?(id)
        else
            return nil
        end
    end

end