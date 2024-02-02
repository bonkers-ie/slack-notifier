#!/usr/bin/env ruby

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

options = (as_user: true, channel: channel)

if ENV.key?('INPUT_TEMPLATE-FILE')
  args = YAML.safe_load(ENV['INPUT_TEMPLATE-ARGS']) if ENV.key?('INPUT_TEMPLATE-ARGS')
  options.merge!(ERB.new(File.read(ENV['INPUT_TEMPLATE-FILE'])))
end

options[:text] = text if text.present?

response = client.chat_postMessage(options)
raise response.error unless response.ok?
puts "::set-output name=message-id::#{response.ts}"
