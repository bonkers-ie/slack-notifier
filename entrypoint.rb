#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'slack-ruby-client'
require 'yaml'

channel = ENV['INPUT_CHANNEL'].gsub(/\A\W*/, '#')
text = ENV['INPUT_TEXT']

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new
client.auth_test

options = { channel:, text: }

if ENV.key?('INPUT_TEMPLATE')
  args = YAML.safe_load(ENV['INPUT_TEMPLATE'])
  options.merge!(ERB.new(args.delete('erb')).result(binding))
end

response = client.chat_postMessage(options)
raise response.error unless response.ok?
puts "::set-output name=message-id::#{response.ts}"
