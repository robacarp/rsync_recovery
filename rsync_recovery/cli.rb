require 'pp'
require 'byebug'

module RsyncRecovery
  class CLI
    class << self
      def run
        Options.parse

        search   if Options.flagged? :search
        analyze if Options.flagged? :analyze
        merge    if Options.flagged? :merge

      rescue RuntimeError => e
        puts e.message
      end

      def search
        puts "Rsync Recovery Analyzing..."
        print "\0337" # save cursor position
        Database.instance filename: Options.settings[:database]
        searcher = Searcher.new
        searcher.search directory: Options.references[0]
        count = duplicate = 0
        searcher.files.each do |file|
          print "Indexing: #{File.join(file.path, file.name)}"
          file.hash!
          count += 1
          if file.uniq?
            file.save
          else
            duplicate += 1
          end

          print "\0338" # restore cursor position
          print "\0337" # save cursor position
          print "\033[2K" # clear line from cursor
        end

        puts "Indexed #{count} files. Already indexed #{duplicate} files."
      end

      def analyze
        base = Database.instance filename: Options.settings[:database]
        grouped_by_sha = base.hashy_query [:sha, :count], <<-SQL
          SELECT sha, count(*) FROM files
          GROUP BY sha
          HAVING count(*) > 1
        SQL

        grouped_by_sha.map! do |row|
          row.delete :count
          row[:files] = HashedFile.from_sha row[:sha]
          row
        end

        grouped_by_sha.each do |group|
          puts "#{group[:sha][0..8]}:"
          group[:files].each do |file|
            puts "\t#{Colorizer[file.hostname]} #{File.join file.path, file.name}"
          end
        end
      end

      def merge
      end
    end
  end
end
