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
        fix_formatting
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

    def fix_formatting
        string_copy = @string
        opening_tags = []
        loop do
            tag_name = string_copy[/<([\w\-]+).*?>.*?<\/\1>/m, 1]
            break if tag_name.nil?
            i = string_copy.index(tag_name) + tag_name.size
            string_copy = string_copy[i..-1]
            opening_tags.push tag_name if !['html'].include? tag_name
        end
        closing_tags = []

        @string.gsub!(/\n\s*\n?/m, "\n")

        unfinished_tags = []
        lines = @string.split("\n")
        depth = 0
        lines = lines.map.with_index do |line, line_number|
            padding = " " * (depth * 4)
            if opening_tags.size > 0 && line.include?("<#{opening_tags.first}")
                tag_name = opening_tags.delete_at(0)
                depth += 1
                closing_tags.push(tag_name)
            end
            if closing_tags.size > 0 && line.include?("</#{closing_tags.last}")
                closing_tags.pop
                depth -= 1
                padding = " " * (depth * 4)
            end
            if line.count('<') > line.count('>')
                unfinished_tags.push({ :tag => tag_name, :line => line_number })
            end
            padding + line
        end
        unfinished_tags.each do |a|
            i = a[:tag].length + 1
            line_number = a[:line] + 1
            loop do
                lines[line_number] = (" " * i) + lines[line_number][3..-1]
                break if lines[line_number].include? ">"
                line_number += 1
            end
        end
        @string = lines.join("\n")
    end

    def print_to_html(arg)
        @current_output.push(arg)
    end

end