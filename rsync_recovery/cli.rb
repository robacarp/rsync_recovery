require 'pp'
require 'byebug'

module RsyncRecovery
  class CLI
    class << self
      def run
        Options.parse
        Database.instance filename: Options.settings[:database]

        require_relative 'hashed_file'

        case
        when Options.flagged?(:search)
          search
        when Options.flagged?(:analyze)
          analyze
        when Options.flagged?(:merge)
          merge
        else
          fail Options.usage
        end

      rescue RuntimeError => e
        puts e.message
      end

      def search
        puts "Rsync Recovery Analyzing..."
        print "\0337" # save cursor position
        searcher = Searcher.new
        searcher.search directory: Options.references[0]
        count = duplicate = 0
        searcher.files.each do |file|
          print "Indexing: #{File.join(file.path, file.name)}"
          file.hash!
          count += 1

          if file.valid?
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
        shas_and_counts = HashedFile.group_and_count(:sha).having('count(*) > 1').all

        grouped_by_sha = shas_and_counts.map do |row|
          [
            row.sha.to_s,
            HashedFile.where(sha: row.sha).all
          ]
        end
        grouped_by_sha = Hash[grouped_by_sha]

        known_files_db = YAML.load(File.read('rsync_recovery/known_files.yml'))
        known_files = grouped_by_sha & known_files_db

        known_files.each do |key, files|
          puts "found '#{known_files_db[key]}' #{files.count} times:"
          files.each do |file|
            puts "\t#{Colorizer[file.hostname]} #{File.join file.path, file.name}"
          end

          grouped_by_sha.delete key
        end

        grouped_by_sha.each do |group|
          puts "#{group[0]}:"

          group[1].each do |file|
            puts "\t#{Colorizer[file.hostname]} #{File.join file.path, file.name}"
          end
        end
      end

      def merge
      end
    end
  end
end
