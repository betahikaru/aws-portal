# encoding: utf-8
require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/contrib'
require 'aws-sdk-core'

class AwsPortal < Sinatra::Base

	# for "sinatra/content-for"
	register Sinatra::Contrib

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

	def stop_ec2_instance(dry_run, instance_id)
		ec2 = Aws::EC2.new
		instances = []
		begin
			responce = ec2.stop_instances(
				dry_run: dry_run,
				instance_ids: [instance_id],
				force: false
			)
		rescue => exp
			p exp
			raise exp
		else
			unless responce.nil? then
				responce.stopping_instances.each do |instance|
					instances.push(instance)
				end
			end
			return instances
		end
	end

	def get_ec2_instances()
		ec2 = Aws::EC2.new
		instances = []
		begin
			responce = ec2.describe_instances()
		rescue => exp
			p exp
			raise exp
		else
			unless responce.nil? then
				responce.reservations.each do |reservation|
					reservation.instances.each do |instance|
						instances.push(instance)
					end
				end
			end
			return instances
		end
	end

	def get_ec2_elasticips()
		ec2 = Aws::EC2.new
		begin
			responce = ec2.describe_addresses()
		rescue => exp
			p exp
			raise exp
		else
			return responce
		end
	end

	def generate_instance_entity(instances)
		entities = []
		instances.each do |instance|
			instance_name = ""
			instance.tags.each do |tag|
				if tag.key == "Name" then
					instance_name = tag.value
				end
			end
			entity = {
				:name => instance_name,
				:status => instance.state.name,
				:dns_name => instance.public_dns_name,
				:public_ip_address => instance.public_ip_address,
				:private_ip_address => instance.private_ip_address,
				:id => instance.instance_id
			}
			entities.push entity
		end
		return entities
	end

	def generate_eip_entities(eips)
		eipEntities = []
		eips.addresses.each do |address|
			eipEntity = {
				:public_ip_address => address.public_ip,
				:instance_id => address.instance_id,
				:domain => address.domain,
				:allocation_id => address.allocation_id,
				:association_id => address.association_id
			}
			eipEntities.push(eipEntity)
		end
		return eipEntities
	end

end
