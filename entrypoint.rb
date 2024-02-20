#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'slack-ruby-client'
require 'yaml'

require_relative 'lib/symbolize_helper'
using SymbolizeHelper

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end
client = Slack::Web::Client.new
client.auth_test

message_id = ENV['INPUT_MESSAGE-ID'].to_s
options = YAML.safe_load(ENV['INPUT_OPTIONS']).deep_symbolize_keys
slack_options = { channel: ENV['INPUT_CHANNEL'] }
template = ENV['INPUT_TEMPLATE'].to_s

if !message_id.empty?
  puts slack_options.merge(inclusive: true, limit: 1, oldest: message_id)
  response = client.conversations_history(slack_options.merge(inclusive: true, limit: 1, oldest: message_id))
  message = response.messages.first
  puts message.inspect
  client.chat_update(slack_options.merge(ts: message_id, blocks: [{ text: { emoji: true, text: "Complete - #{message.metadata.event_payload}", type: 'plain_text' }, type: 'header' }]))
elsif !template.empty?
  slack_options.merge!(JSON.parse(ERB.new(template).result(binding)).deep_symbolize_keys)
  slack_options[:include_all_metadata] = true
  slack_options[:metadata] = { event_type: 'event_type', event_payload: { event: 'payload' } }
  puts slack_options
  response = client.chat_postMessage(slack_options)
  raise response.error unless response.ok?
  puts "::set-output name=message-id::#{response.ts}"
else
  raise 'Must either provide a template or update an existing message'
end
