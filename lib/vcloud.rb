require 'rubygems'
require 'bundler/setup'
require 'fog'
require 'json'
require 'open3'
require 'pp'
require 'vcloud/version'
require 'vcloud/launch'
require 'vcloud/constants'
require 'vcloud/content_types'
require 'vcloud/fog_interface'
require 'vcloud/vapp'
require 'vcloud/vm'

module Vcloud

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.clone_object object
    Marshal.load(Marshal.dump(object))
  end

end
