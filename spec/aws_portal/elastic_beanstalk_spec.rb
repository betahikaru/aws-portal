# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

require 'aws_portal/elastic_beanstalk'

describe AwsPortal::ElasticBeanstalk do
  include AwsPortal::ElasticBeanstalk

  describe "get_elasticbeanstalk_applications" do
    it "return responce[:applications]" do
      responce = {
        applications: [
          {
            application_name: "name1",
            description: "des1",
            date_created: Time.now,
            date_updated: Time.now,
            versions: ["v1", "v2"],
            configuration_templates: ["t1", "t2"]
          }
        ]
      }
      eb = {}
      allow(eb).to receive_messages(:describe_applications => responce)
      entities = get_elasticbeanstalk_applications(eb)
      expect(entities).to match_array responce[:applications]
    end  end

  describe "get_elasticbeanstalk_environments" do
    it "return responce[:environments]" do
      responce = {
        environments: [
          {
            environment_name: "environment1",
            environment_id: "id1",
            application_name: "app1",
            description: "des1",
            endpoint_url: "http://end.point.com/url1",
            status: "Launching",
            health: "Green",
          }
        ]
      }
      eb = {}
      allow(eb).to receive_messages(:describe_environments => responce)
      entities = get_elasticbeanstalk_environments(eb)
      expect(entities).to match_array responce[:environments]
    end
  end

end
