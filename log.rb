class Logger

    ERROR       = 1
    WARNING     = 2
    INFORMATION = 3
    DEBUG       = 4

    attr_reader :last_message

    def initialize(source, output=STDOUT)
        @source = source
        @out = output
        @depth = 0
        @padding = 4
        @last_message = ""
        @importance_level = DEBUG
    end

    def set_level(level)
        @importance_level = level
    end

    def push(message)
        @out.puts (" " * padding * depth) + message
        @depth += 1
        @last_message = @message
    end

    def pop(message)
        @depth = [@depth - 1, 0].max
        @outs.puts (" " * padding * depth) + message
        @last_message = @message
    end

    def log(message)
       @outs.puts (" " * padding * depth) + message 
       @last_message = @message
    end

end