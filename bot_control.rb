#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'daemons'

Daemons.run(
  File.join(File.dirname(__FILE__), 'tatibot.rb'),
  {
    :backtrace  => true,
    :log_output => true,
    :dir_mode   => :script,
    :log_dir    => '/tmp',
    :monitor    => true
  }
)

