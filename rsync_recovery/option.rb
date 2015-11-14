module RsyncRecovery
  class Option

    class << self
      def parse option_text, references
        new(text: option_text, references: references)
      end
    end

    attr_accessor :name, :type, :references, :text
    TYPES = [:flag, :setting]

    def initialize(text:, references:[])
      @text = text
      @references = references

      parse
    end

    def parse
      if @text.index('=')
        @type = :setting
        parse_setting
      else
        @type = :flag
        parse_flag
      end
    end

    def match text
      @name == symbolize(text)
    end

    def value
      @references.last
    end

    private
    def parse_setting
      key, value = @text.split('=', 2)
      key = key.gsub(/-/,' ').strip
      @name = symbolize key
      @references << value
    end

    def parse_flag
      @name = symbolize(@text)
    end

    def symbolize str
      return str if str.kind_of? Symbol
      str.gsub(/-/,' ').strip.gsub(/ /,'_').to_sym
    end
  end
end
