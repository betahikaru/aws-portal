# encoding: utf-8
require 'aws-sdk-core'

module AwsPortal
  module Ec2

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

    def start_ec2_instance(ec2, instance_id, dry_run)
      responce = nil
      @navbar_button_active = "#navbar_button_ec2_control"
      @title = site_title("EC2 Control")
      @details = []

      begin
        responce = ec2.start_instances(
          instance_ids: [instance_id],
          dry_run: dry_run
        )
      rescue => exp
        @error = "Failed to start instance #{instance_id}"
        if exp.kind_of?(Aws::EC2::Errors::UnauthorizedOperation)
          @details.push "You have no permission for this action."
        elsif exp.kind_of?(Aws::EC2::Errors::InvalidInstanceIDMalformed)
          @details.push "Invalid parameter (instance-id: #{instance_id})"
        elsif exp.kind_of?(Aws::EC2::Errors::DryRunOperation)
          @details.push "This is dry_run."
        else
          @details.push exp.to_s
        end
        erb :"ec2/control/start"
      else
        unless responce.nil? then
          @notice = "Succeeded to send the starting request"
          responce.starting_instances.each do |instance|
            id = instance[:instance_id]
            current_state = instance[:current_state][:name]
            previous_state = instance[:previous_state][:name]
            @details.push "EC2 instance (#{id}) : #{previous_state} => #{current_state}"
          end
        else
          @error = "Empty responce..."
        end
        erb :"ec2/control/start"
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

    def get_elastiloadbalancers(elb)
      begin
        responce = elb.describe_load_balancers()
      rescue => exp
        p exp
        raise exp
      else
        return responce
      end
    end

    def generate_instance_entity(instances)
      if instances.nil? or instances.size == 0 then
        return []
      end
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
      if eips.nil? or eips.size == 0 then
        return []
      end
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
end
