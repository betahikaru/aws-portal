# encoding: utf-8
ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe "App" do
  include Rack::Test::Methods

  def app
    @app ||= AwsPortal
  end

  describe "request" do
    describe "top page" do
      it "return 200 OK" do
        get '/'
        expect(last_response).to be_ok
      end
    end
  end
end
