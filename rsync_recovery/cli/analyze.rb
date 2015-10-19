module RsyncRecovery
  module CLI
    class Analyze
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

    end
  end
end
