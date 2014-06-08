# encoding: utf-8
require 'sinatra/base'

require 'aws-sdk-core'

module AwsPortal
  module ElasticBeanstalk

    # get '/elasticbeanstalk/summary' do
    def get_elasticbeanstalk_summary()
      @elasticbeanstalk_applications = []
      @elasticbeanstalk_environments = []
      begin
        environments = get_elasticbeanstalk_environments()
        @elasticbeanstalk_environments = environments if environments.length > 0

        applications = get_elasticbeanstalk_applications()
        @elasticbeanstalk_applications = applications if applications.length > 0
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

      @navbar_button_active = "#navbar_button_elasticbeanstlak_summary"
      @title = site_title("EB Summary")
      erb :"elastic_beanstalk/summary"
    end

    def get_elasticbeanstalk_applications()
      applications = []
      begin
        eb = Aws::ElasticBeanstalk.new
        responce = eb.describe_environments()
        unless responce[:applications].nil?
          responce[:applications].each do |application|
            applications.push(application)
          end
        end
      rescue => exp
        p exp
        raise exp
      end
      applications
    end

    def get_elasticbeanstalk_environments()
      environments = []
      begin
        eb = Aws::ElasticBeanstalk.new
        responce = eb.describe_environments()
        unless responce[:environments].nil?
          responce[:environments].each do |environment|
            environments.push(environment)
          end
        end
      rescue => exp
        p exp
        raise exp
      end
      environments
    end

  end
end
