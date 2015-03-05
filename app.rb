#!/usr/bin/env ruby
# Encoding: UTF-8

require 'sinatra'
require 'yaml'
require 'time'
require 'haml'

set :bind, '0.0.0.0'
set :port, 3000

set :haml, :format => :html5

config = YAML.load_file('default.yaml').merge YAML.load_file('config.yaml')

config['due_date'] = Time.parse(config['due_date'])

puts config.inspect

before do
  if Time.now > config['due_date']
    halt haml(:late, :locals => { config: config })
  end
end

get '/' do
  haml :turnin, :locals => { config: config }
end

post '/turnin' do
  "<pre><code>#{Rack::Utils.escape_html params.inspect}</code></pre>"
end
