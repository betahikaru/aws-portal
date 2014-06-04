# encoding: utf-8
require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/contrib'
require 'aws-sdk-core'

require_relative 'aws_portal/ec2'

module AwsPortal
class Application < Sinatra::Base

	# for "sinatra/content-for"
	register Sinatra::Contrib

	# setting for directory path
	set :root, File.join(File.dirname(__FILE__), "..")
	set :views, Proc.new { File.join(root, "views") }

	# include module
	include AwsPortal::Ec2

	get '/' do
		@navbar_button_active = "#navbar_button_home"
		@title = "Aws Protal"
		erb :index
	end

	get '/ec2/summary' do
		@ec2_entities = []
		begin
			instances = get_ec2_instances()
			if instances.length > 0 then
				@ec2_entities = generate_instance_entity(instances)
			end
		rescue Aws::Errors::MissingRegionError => exp
			@error = "Missing region error."
			erb :"error"
		rescue Aws::EC2::Errors::UnauthorizedOperation => exp
			@error = "You have no permission for this action."
			erb :"error"
		rescue => exp
			p exp
			@error = "Unknown error."
			erb :"error"
		end

		@eip_entities = []
		begin
			eips = get_ec2_elasticips()
			if eips.length > 0 then
				@eip_entities = generate_eip_entities(eips)
			end
		rescue => exp
			p exp
			@error = "Unknown error."
			erb :"error"
		end

		@navbar_button_active = "#navbar_button_ec2_summary"
		@title = "EC2 Summary"
		erb :"ec2/summary"
	end

	get '/ec2/control' do
		begin
			instances = get_ec2_instances()
			if instances.length > 0 then
				@ec2_entities = generate_instance_entity(instances)
			end
		rescue => exp
			p exp
			@error = "Unknown error."
			erb :"error"
		end

		@navbar_button_active = "#navbar_button_ec2_control"
		@title = "EC2 Control"
		erb :"ec2/control"
	end

	get '/ec2/control/stop/:instance_id' do
		instance_id = params[:instance_id]
		begin
			instances = stop_ec2_instance(false, instance_id)
		rescue Aws::EC2::Errors::UnauthorizedOperation
			@error = "You have no permission for this action."
			erb :"error"
		rescue Aws::EC2::Errors::InvalidInstanceIDMalformed
			@error = "Invalid parameter (instance-id: #{instance_id})"
			erb :"error"
		rescue Aws::EC2::Errors::DryRunOperation
			@error = "This is dry_run. Request would have succeeded."
			erb :"error"
		else
			instances.each do |instance|
				print "Stopping instance(id=#{instance.instance_id})\n"
			end

			@navbar_button_active = "#navbar_button_ec2_control"
			@title = "EC2 Control"
			erb :"ec2/control/stop"
		end
	end
end
end
