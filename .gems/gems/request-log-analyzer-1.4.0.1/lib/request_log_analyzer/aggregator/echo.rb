module RequestLogAnalyzer::Aggregator

  # Echo Aggregator. Writes everything to the screen when it is passed to this aggregator
  class Echo < Base

    attr_accessor :warnings

    def prepare
      @warnings = []
    end

    # Display every parsed line immediately to the terminal
    def aggregate(request)
      puts "\nRequest: " + request.lines.inspect
    end

    # Capture all warnings during parsing
    def warning(type, message, lineno)
      @warnings << "WARNING #{type.inspect} on line #{lineno}: #{message}"
    end

    # Display every warning in the report when finished parsing
    def report(output)
      output.title("Warnings during parsing")
      @warnings.each { |w| output.puts(w) }
    end

  end
end