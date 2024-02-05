#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'slack-ruby-client'
require 'yaml'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

channel = ENV['INPUT_CHANNEL'].to_s.gsub(/\A\W*/, '#')
template = ENV['INPUT_TEMPLATE']

%i[channel template].each do { |var| raise "Missing '#{var}'! unless #{binding.local_variable_get(var).present?}" }

client = Slack::Web::Client.new
client.auth_test

options = { channel: }

if ENV.key?('INPUT_TEMPLATE')
  args = YAML.safe_load(ENV['INPUT_TEMPLATE'])
  options.merge!(ERB.new(args.delete('erb').to_s).result(binding))
end

response = client.chat_postMessage(options)
raise response.error unless response.ok?
puts "::set-output name=message-id::#{response.ts}"
