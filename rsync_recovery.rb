#!/usr/bin/env ruby

require_relative 'rsync_recovery/database'
require_relative 'rsync_recovery/hashed_file'
require_relative 'rsync_recovery/searcher'
require_relative 'rsync_recovery/options'
require_relative 'rsync_recovery/cli'
require_relative 'rsync_recovery/colorizer'

module RsyncRecovery
  BINARY = 'rs_recovery'
  VERSION = '0.0.1'
end

RsyncRecovery::CLI.run
