# encoding: utf-8

module AwsPortal
  module Helpers
    module HtmlHelper

      def site_title(page_name)
        site_name = "Aws Portal"
        if page_name == site_name or page_name == ""
          site_name
        else
          page_name + "-" + site_name
        end
      end

    end
  end
end
