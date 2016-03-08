require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'asdfsdfasdf' 

get '/tryit' do
  'this is a test'
end

get '/tryerb' do
  erb :template
end

get '/nesterb' do 
  erb :"/player/nesterb"
end