module RsyncRecovery
  class Option

    class << self
      def parse option_text
        new(text: option_text)
      end
    end

    attr_accessor :name, :type, :references, :text
    TYPES = [:flag, :setting]

    def initialize(text:)
      @text = text
      @references = []

      parse
    end

    def parse
      if option_text.index('=')
        @type = :setting
        parse_setting
      else
        @type = :flag
        parse_flag
      end
    end

    private
    def parse_setting
      key, value = arg.split('=', 2)
      key = key.gsub(/-/,' ').strip
    end

    def parse_flag
      @name = symbolize(arg)
    end

    def symbolize str
      str.gsub(/-/,' ').strip.gsub(/ /,'_').to_sym
    end
  end
end
