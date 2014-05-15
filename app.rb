# encoding: utf-8
require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'aws-sdk-core'

class AwsPortal < Sinatra::Base

	get '/' do
		@navbar_buttun_active = "#navbar_button_home"
		erb :index
	end

	get '/ec2/summary' do
		ec2 = Aws::EC2.new
		@entities = []
		resp = ec2.describe_instances(max_results: 10)
		resp.reservations.each do |reservation|
			reservation.instances.each do |instance|
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
				@entities.push entity
			end
		end

		@navbar_buttun_active = "#navbar_button_ec2_summary"
		erb :"ec2/summary"
	end

	get '/ec2/control' do
		begin
			instances = get_ec2_instances()
			ec2_entities = generate_entity(instances)
			@entities = ec2_entities
		rescue => exp
			p exp
		else
			@navbar_button_active = "navbar_button_ec2_control"
			erb :"ec2/control"
		end
	end

	get '/ec2/control/stop/:instance_id' do
		instance_id = params[:instance_id]
		begin
			instances = stop_ec2_instance(false, instance_id)
		rescue Aws::EC2::Errors::UnauthorizedOperation
			@error = "You have no permission for this action."
		rescue Aws::EC2::Errors::InvalidInstanceIDMalformed
			@error = "Invalid parameter (instance-id: #{instance_id})"
		rescue Aws::EC2::Errors::DryRunOperation
			@error = "This is dry_run. Request would have succeeded."
		else
			instances.each do |instance|
				print "Stopping instance(id=#{instance.instance_id})\n"
			end
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

	def generate_entity(instances)
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

end
