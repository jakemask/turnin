#!/usr/bin/env ruby
# Encoding: UTF-8

require 'sinatra'
require 'yaml'
require 'time'
require 'haml'
require 'set'

require './lib/helpers'

set :bind, '0.0.0.0'
set :port, 3000
enable :dump_errors, :raise_errors, :show_exceptionss

set :haml, :format => :html5

config = YAML.load_file('default.yaml').merge YAML.load_file('config.yaml')

config[:due_date] = Time.parse(config[:due_date])

puts config.inspect

before do
  if Time.now > config[:due_date]
    halt haml(:late, :locals => { config: config })
  end
end

get '/' do
  haml :turnin, :locals => { config: config }
end

post '/turnin' do

  # check filetype
  filetype = Filetype.check(params['file'][:tempfile].path)
  halt 'Bad file type' unless filetype == config[:filetype]

  # build up the group as a set of the studentIDs
  group = params['studentID'].inject(Set.new) do |group,id|
    newid = StudentID.sanitize(id)
    halt 'Bad Student ID' unless StudentID.valid?(newid)
    group.add(newid)
  end

  # determine file paths
  folder = group.to_a.sort.join '_'
  filename = folder + Filetype::EXTENSION[config[:filetype]]

  group_dir = File.join config[:upload_dir], folder

  # Keep getting new timestamps until you get one that doesn't exist
  begin
    timestamp = Time.now.to_i.to_s
  end while Dir.exists? File.join(group_dir, timestamp)

  out_dir = File.join group_dir, timestamp
  out_file = File.join out_dir, filename
  latest = File.join group_dir, 'latest'

  # copy in the file
  FileUtils.mkdir_p out_dir
  FileUtils.cp params['file'][:tempfile].path, out_file

  # symlink 'latest' to point to the new submission
  FileUtils.rm_f latest
  FileUtils.ln_sf timestamp, latest

  Filetype.check(params['file'][:tempfile].path)

  "Qa'pla!"
end
