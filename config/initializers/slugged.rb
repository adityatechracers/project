require 'slugged'
ActiveRecord::Base.send(:include, WebAscender::Slugged)
