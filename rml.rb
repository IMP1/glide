require_relative 'log'

class RMLParser

    SEPARATOR = " "

    def initialize(string, filename="Raw text")
        @filename = filename
        @string = string
        @logger = Logger.new("RML Parser")
    end

    def parse(variables)
        @logger.push("Beginning Parse...")
        add_included_files
        handle_blocks
        eval_ruby(variables)
        fix_indentation
        @logger.pop("Successful Parse.")
        return @string
    end

    def add_included_files
        @string.scan(/<ruby include=".+?">/).each do |m|
            filename = m[15..-3]
            include_string = WebServer.file_contents(filename)
            if include_string.nil?
                @logger.log("Could not find #{filename}.", Logger::ERROR)
            else
                import = RMLParser.new(include_string, filename)
                # TODO: do any imported files need more processing?
                @string.sub!(m, import.add_included_files)
            end
        end
        return @string
    end

    def handle_blocks
        blocks = {}

        @string.scan(/<ruby block\-begin=".+?">/m).each do |m|
            block_name = m[19..-3]
            blocks[block_name] ||= []
            i = (0..blocks[block_name].size).inject(-1) { |memo, i| @string.index(m, memo + 1) }
            j = @string.index(/<ruby block\-end="#{block_name}">/m, i)
            k = @string.index(">", j + 1)
            blocks[block_name].push( @string[i+m.size...j] )
        end

        blocks.each do |block_name, block_levels|
            block_levels.each_with_index do |block, i|
                block_levels[i].gsub!(/<ruby block\-super>/, block_levels[i-1])
            end
        end

        blocks.keys.each do |block_name|
            @string.sub!(/<ruby block\-begin="#{block_name}">.+?<ruby block\-end="#{block_name}">/m, blocks[block_name].last)
        end
        @string.gsub!(/<ruby block\-begin="(.+?)">.+?<ruby block\-end="\1">/m, "")
        return @string
    end

    def eval_ruby(variables)
        @view_bag = variables
        alias puts_inspect p  # Save p in a local method
        alias p print_to_html # Overwrite p to print to the html
        @string.scan(/<ruby>.+?<\/ruby>/m).each do |m|
            @current_output = []
            code = m[6..-8]
            binding.eval(code)    
            @string = @string.sub(m, @current_output.join(SEPARATOR))
        end
        alias p puts_inspect  # Restore p
        return @string
    end

    def fix_indentation
        lines = @string.split("\n")
        lines = lines.select { |line| !line.strip.empty? }
        

        @string = lines.join("\n")
    end

    def print_to_html(arg)
        @current_output.push(arg)
    end

end