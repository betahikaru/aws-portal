# encoding: utf-8
require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe AwsPortal::Application do
  include Rack::Test::Methods

  def app
    @app ||= AwsPortal::Application
  end

  %w{
    /
    /ec2/summary
    /ec2/control
    }.each do |uri|
    describe "'#{uri}' page" do
      it "return 200 OK" do
        get uri
        expect(last_response).to be_ok
      end
    end
  end
end
