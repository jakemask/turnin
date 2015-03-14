#!/usr/bin/env ruby
# Encoding: UTF-8

require 'sinatra'
require 'yaml'
require 'time'
require 'haml'
require 'set'

require_relative 'lib/helpers'

set :bind, '0.0.0.0'
set :port, 3000
enable :dump_errors, :raise_errors, :show_exceptionss

set :haml, :format => :html5

config = TurninConfig.load 
puts config.inspect

##
# Check time against due date
#
before do
  if Time.now > config[:due_date]
    halt haml(:late, :locals => { config: config })
  end
end

##
# Default to turnin page
#
get '/' do
  haml :turnin, :locals => { config: config }
end

##
# Handle an uploaded file
#
post '/turnin' do

  case params['type']
  when 'upload'
    if tmpfile = params['file'][:tempfile]
      begin
        Turnin.upload_file params['studentID'], tmpfile.path, config
      rescue TurninError => e
        halt e.message
      end
    else
      halt 'No File selected for upload'
    end
  else
    halt 'No turnin method selected'
  end

  "Qa'pla!"
end
