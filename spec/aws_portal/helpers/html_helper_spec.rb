# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

require 'aws_portal/helpers/html_helper'

describe AwsPortal::Helpers::HtmlHelper do
  include AwsPortal::Helpers::HtmlHelper

  describe "site_title" do
    describe "return top page name" do
      it "with top page name" do
       title = site_title("Aws Portal")
       expect(title).to eq("Aws Portal")
      end
      it "with empty string" do
        title = site_title("")
        expect(title).to eq("Aws Portal")
      end
    end
    describe "return empty array if argument is empty array" do
      it "with any string" do
        title = site_title("EC2 Summary")
        expect(title).to eq("EC2 Summary" + "-" + "Aws Portal")
      end
    end
  end

end
