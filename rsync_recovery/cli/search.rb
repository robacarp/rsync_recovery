module RsyncRecovery
  module CLI
    class Search

      class << self
        def search
          search_cli = new
          searcher = Searcher.new
          start

          reprint 'Building file list...'
          searcher.search directory: Options.references[0]
          puts "#{searcher.files.length} entries found"

          reprint 'Indexing...'
          states = {}

          searcher.hash_files(force: Options.flagged?(:force_rehash)) do |file, state|
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
          pp states.inspect
        end

        def start
          print "\0337" # save cursor position
        end

        def reprint *args
          if Options.flagged?(:debug)
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
end
