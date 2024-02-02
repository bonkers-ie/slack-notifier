# Slack notifier

This action sends and updates Slack messages.

A [Slack bot token](https://api.slack.com/docs/token-types) with appropriate permissions is required.

## Usage

At its simplest, just send a text message to a specified channel.

```yaml
  uses: bonkers-ie/slack-notifier
  with:
    channel: wildlife
    text: I just saw a badger! :badger:
```

### Templating

You can also provide a JSON ERB template for a [Slack blocks API payload](https://app.slack.com/block-kit-builder)
```yaml
  uses: bonkers-ie/slack-notifier
  with:
    build-args: |
      template-file: ./.github/templates/slack-template.json.erb
    channel: wildlife

```

### Outputs and updates

