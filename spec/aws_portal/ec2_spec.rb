# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe AwsPortal::Ec2 do
  include AwsPortal::Ec2

  describe "generate_instance_entity" do
    it "return empty array if argument is empty array" do
      entities = generate_instance_entity([])
      expect(entities).to match_array []
    end
  end

end
