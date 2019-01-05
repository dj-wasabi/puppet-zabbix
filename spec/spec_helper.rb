# frozen_string_literal: true

# This file is managed via modulesync
# https://github.com/voxpupuli/modulesync
# https://github.com/voxpupuli/modulesync_config
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

if File.exist?(File.join(__dir__, 'default_module_facts.yml'))
  facts = YAML.load(File.read(File.join(__dir__, 'default_module_facts.yml')))
  facts&.each do |name, value|
    add_custom_fact name.to_sym, value
  end
end

if Dir.exist?(File.expand_path('../../lib', __FILE__))
  require 'coveralls'
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/spec'
    add_filter '/vendor'
    add_filter '/.vendor'
  end
end

RSpec.configure do |c|
  # Coverage generation
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
