class Logger

    NONE        = 0
    ERROR       = 1
    WARNING     = 2
    INFORMATION = 3
    DEBUG       = 4

    attr_reader :last_message
    
    @@depth = 0

    def initialize(source, output=$stdout)
        @source = source
        @out = output
        @padding = 4
        @last_message = ""
        @importance_level = DEBUG
    end

    def set_level(level)
        @importance_level = level
    end

    def push(message, importance=INFORMATION)
        log_message(message, importance)
        @@depth += 1
    end

    def pop(message, importance=INFORMATION)
        @@depth = [@@depth - 1, 0].max
        log_message(message, importance)
    end

    def log(message, importance=INFORMATION)
        log_message(message, importance)
    end

    def log_message(message, importance)
        return if importance > @importance_level
        @out.puts "[#{@source}]" + (" " * @padding * @@depth) + message 
        @last_message = message
    end

end