module RsyncRecovery
  module CLI
    class Analyze

      def initialize(options)
        @options = options
      end

      def analyze
        duplicated_files_by_size
      end

      def duplicated_files_by_size
        shas_and_counts = HashedFile
              .group_and_count(:sha,:size)
              .where(type: 'file')
              .order(:size)
              .having('count(*) > 1')
              .all

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

        grouped_by_sha.each do |hash,files|
          puts "#{hash} (#{rationalize_size(files.first.size)}):"

          files.each do |file|
            puts "\t#{Colorizer[file.hostname]} #{File.join file.path, file.name}"
          end
        end

        unique_files = grouped_by_sha.keys.count
        total_files  = HashedFile.where(type: 'file').count
        total_folders = HashedFile.where(type: 'directory').count

        puts "#{grouped_by_sha.keys.count} unique files out of #{total_files} in #{total_folders} folders"
      end

      def rationalize_size bytes
        count = 0
        stash = bytes
        while stash > 1024 do
          stash /= 1024
          count += 1
        end

        "#{stash}#{PREFIXES[count]}"
      end

    end
  end
end
