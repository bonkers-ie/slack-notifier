#!/usr/bin/env ruby

require 'json'
require 'slack-ruby-client'
require 'yaml'

build_args = YAML.safe_load(ENV['INPUT_BUILD_ARGS']) if ENV.key?('INPUT_BUILD_ARGS')
channel = ENV['INPUT_CHANNEL'].gsub(/\A\W*/, '#')
text = ENV['INPUT_TEXT'] || '_this space intentionally left blank_'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new
client.auth_test

response = JSON.parse(client.chat_postMessage(channel: channel, text: text, as_user: true))
raise response['error'] unless response['ok']

puts "::set-output name=message-id::#{response['ts']}"
