module RsyncRecovery
  module CLI
    class Search

      def initialize(options)
        @options = options
      end

      def search
        searcher = Searcher.new
        start

        reprint 'Building file list...'
        searcher.search directory: @options.setting(:search).value
        puts "#{searcher.files.length} entries found"

        reprint 'Indexing...'
        states = {}

        searcher.hash_files(force: @options.flagged?(:force_rehash)) do |file, state|
          reprint "Indexing: #{File.join(file.path, file.name)}"

          states[state] ||= 0
          states[state] += 1

          unless file.valid?
            puts "file is invalid, you should probably take a look around"
            debugger
          end
        end

        # reprint "Indexed #{saved} files. Could not index #{failed} files. Skipped #{skipped} files."
        reprint "Indexed a bunch of files:"
        pp states
        puts 'bye'
      end

      def start
        print "\0337" # save cursor position
      end

      def reprint *args
        if @options.flagged?(:debug)
          puts *args
        else
          print "\0338" # restore cursor position
          print "\0337" # save cursor position
          print "\033[2K" # clear line from cursor
          print *args
        end
      end
    end
  end
end
