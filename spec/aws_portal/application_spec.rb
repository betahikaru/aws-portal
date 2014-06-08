# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'aws_portal/application'

describe AwsPortal::Application do
  include Rack::Test::Methods

  def app
    @app ||= AwsPortal::Application
  end

  %w{
    /
    /ec2/summary
    /ec2/control
    /elasticbeanstalk/summary
    }.each do |uri|
    describe "'#{uri}' page" do
      it "return 200 OK" do
        get uri
        expect(last_response).to be_ok
      end
    end
  end
end
