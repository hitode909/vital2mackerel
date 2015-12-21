require 'rubygems'
require 'bundler'

Bundler.require
use Rack::Session::Cookie,
  :key => 'rack.session',
  :expire_after => 2592000,
  :secret => 'wa;glkjmazetjioytw4'
use Rack::Protection::FormToken

require './vital2mackerel'
run Vital2MackerelApp
