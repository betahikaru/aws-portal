# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'aws_portal/ec2'

describe AwsPortal::Ec2 do
  include AwsPortal::Ec2

  describe "generate_instance_entity" do
    it "return empty array if argument is nil" do
      entities = generate_instance_entity(nil)
      expect(entities).to match_array []
    end
    it "return empty array if argument is empty array" do
      entities = generate_instance_entity([])
      expect(entities).to match_array []
    end
  end

  describe "generate_eip_entities" do
    it "return empty array if argument is nil" do
      entities = generate_eip_entities(nil)
      expect(entities).to match_array []
    end
    it "return empty array if argument is empty array" do
      entities = generate_eip_entities([])
      expect(entities).to match_array []
    end
  end

end
