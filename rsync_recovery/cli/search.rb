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

          reprint 'Indexing...'
          saved = failed = skipped = 0
          searcher.files.each do |file|
            reprint "Indexing: #{File.join(file.path, file.name)}"
            file.smart_hash

            if file.valid?
              if file.changed_columns.any? || file.new?
                file.save
                saved += 1
              else
                skipped += 1
              end
            else
              puts "file is invalid, you should probably take a look around"
              debugger
              failed += 1
            end

          end

          reprint "Indexed #{saved} files. Could not index #{failed} files. Skipped #{skipped} files."
        end

        def start
          print "\0337" # save cursor position
        end

        def reprint *args
          print "\0338" # restore cursor position
          print "\0337" # save cursor position
          print "\033[2K" # clear line from cursor
          print *args
        end
      end
    end
  end
end
