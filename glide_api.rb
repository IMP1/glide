module GlideAPI

    def self.handle_command(command, *args)
        puts "[GlideAPI] Recieved command '#{command}'."
        case command
        when "workflows"
            workflow_command(args[0], args[1..-1])
        else

        end
    end

    def self.workflow_command(command, args)
        puts "[GlideAPI] Recieved Workflow command '#{command}'."
        case command
        when "create"
            p args[0]
        else

        end
    end

end