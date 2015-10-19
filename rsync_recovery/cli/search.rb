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
          count = duplicate = 0
          searcher.files.each do |file|
            reprint "Indexing: #{File.join(file.path, file.name)}"
            file.hash!
            count += 1

            if file.valid?
              file.save
            else
              duplicate += 1
            end

          end

          reprint "Indexed #{count} files. Already indexed #{duplicate} files."
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
