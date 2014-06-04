# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'lib', 'aws_portal.rb')

require 'rubygems'
require 'sinatra'
require 'rspec'
require 'rack/test'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
