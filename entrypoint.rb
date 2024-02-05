#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'slack-ruby-client'
require 'yaml'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end
client = Slack::Web::Client.new
client.auth_test

channel = ENV['INPUT_CHANNEL'].gsub(/\A\W*/, '#')
options = YAML.safe_load(ENV['INPUT_OPTIONS'])

if ENV.key('INPUT_MESSAGE-ID')
  # retrieve
elsif options.key('erb')
  slack_options = ERB.new(options.delete('erb').to_s).result(binding).merge(channel:)
  slack_options[:metadata] = options
  response = client.chat_postMessage(slack_options)
  raise response.error unless response.ok?
  puts "::set-output name=message-id::#{response.ts}"
else
  raise 'Must either provide a template or update an existing message'
end
