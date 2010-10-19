# encoding: utf-8

# Load Cri
begin
  require 'cri'
rescue LoadError
  require 'rubygems'
  require 'cri'
end

module Nanoc3::CLI
end

# Load CLI
require 'nanoc3/cli/logger'
require 'nanoc3/cli/commands'
require 'nanoc3/cli/base'
