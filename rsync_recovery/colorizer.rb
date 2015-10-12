module RsyncRecovery
  class Colorizer
    class << self
      def [] string
        @@colors ||= {}
        if @@colors[string]
          color = @@colors[string]
        else
          code = 31 + @@colors.keys.count % 9
          color = @@colors[string] = "\033[#{code}m"
        end

        "#{color}#{string}\033[0m"
      end
    end
  end
end
