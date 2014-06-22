# encoding: utf-8
require 'sinatra/base'

require 'aws-sdk-core'

module AwsPortal
  module ElasticBeanstalk

    # get '/elasticbeanstalk/summary' do
    def get_elasticbeanstalk_summary()
      @navbar_button_active = "#navbar_button_elasticbeanstlak_summary"
      @title = site_title("EB Summary")
      @elasticbeanstalk_applications = []
      @elasticbeanstalk_environments = []
      begin
        eb = Aws::ElasticBeanstalk.new
        environments = get_elasticbeanstalk_environments(eb)
        @elasticbeanstalk_environments = environments if environments.length > 0

        applications = get_elasticbeanstalk_applications(eb)
        @elasticbeanstalk_applications = applications if applications.length > 0
      rescue => exp
        if exp.kind_of?(Aws::Errors::MissingRegionError)
          @error = "Missing region error."
        elsif exp.kind_of?(Aws::EC2::Errors::UnauthorizedOperation)
          @error = "You have no permission for reading ELB information."
        else
          @error = "Internal Error"
          p "get_elasticbeanstalk_summary() : #{exp.class} : #{exp.to_s}"
        end
      end
      erb :"elastic_beanstalk/summary"
    end

    def get_elasticbeanstalk_applications(eb)
      applications = []
      begin
        responce = eb.describe_applications()
        unless responce[:applications].nil?
          responce[:applications].each do |application|
            applications.push(application)
          end
        end
      rescue => exp
        p "get_elasticbeanstalk_applications: " + exp.to_s
        raise exp
      end
      applications
    end

    def get_elasticbeanstalk_environments(eb)
      environments = []
      begin
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
