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

end
