#!/usr/bin/env ruby

module RHTML

    def self.p(arg)
        Thread.current[:current_output].push arg
    end

    def self.evaluate(string)
        process = Thread.start do
            string.scan(/<ruby>.+?<\/ruby>/m).each do |m|
                Thread.current[:current_output] = [];
                code = m[6..-8]
                binding.eval(code)
                string = string.sub(m, Thread.current[:current_output].join(" "))
            end
        end
        process.join
        return string
    end

end