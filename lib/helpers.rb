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
