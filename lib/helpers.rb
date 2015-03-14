##
# Helpers for dealing with the config file
#
module TurninConfig
  CONFIG_FILE = 'config.yml'
  DEFAULT_FILE = 'default.yml'

  def self.load(file = CONFIG_FILE, default = DEFAULT_FILE)
    config = YAML.load_file(default).merge YAML.load_file(file)
    config[:due_date] = Time.parse config[:due_date]
    config
  end
end

class TurninError < RuntimeError; end

##
# Helper functions for dealing with student IDs
#
module StudentID
  def self.sanitize(id)
    id.strip.upcase.gsub(/[^A-Z0-9]/, '')
  end

  def self.valid?(id)
    id =~ /^[A-Z][0-9]+$/ # TODO: generalize
  end

  def self.to_group(ids)
    # build up the group as a set of the studentIDs
    ids.inject(Set.new) do |group, id|
      newid = StudentID.sanitize(id)
      fail TurninError, 'Bad Student ID' unless StudentID.valid?(newid)
      group.add(newid)
    end
  end
end

require 'filemagic'
##
# Helpers for dealing with turnin file types
#
module Filetype
  EXTENSION = {
    targz: '.tar.gz',
    zip: '.zip'
  }

  def self.check(file)
    type = FileMagic.new.file file
    case type
    when /PDF document/
      return :pdf
    when /gzip compressed data/
      return :targz
    when /Zip archive data/
      return :zip
    end
  end
end

require 'sinatra/extension'
require_relative 'upload'
##
# Handling for the various turnin types
#
module Turnin
  extend Sinatra::Extension

  def self.upload_file(ids, file, config)
    # check filetype
    unless Filetype.check(file) == config[:filetype]
      fail TurninError, 'Bad file type'
    end

    upload = Upload.new(ids, config[:filetype], config[:upload_dir])

    upload.copy file
    upload.symlink
  end
end
