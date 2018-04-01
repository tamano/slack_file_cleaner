# SlackFileCleaner

SlackFileCleaner can delete files uploaded to Slack.

**[ATTENTION]** This is my Elixir-study-project, so that it would be bug-ful or being nasty.


## Installation


```
mix escript.build
```

## Usage

Full option below
```
./slack_file_cleaner --token=YOUR_SLACK_TOKEN --before=`date -v-1y +%s` --dryrun
```

|Option|Required|Description|
|:-|:-|:-|
|token|True|Your Slack API Token.|
|before||Specify Timestamp. Tool will delete files uploaded before this time. Default is now.|
|dryrun||When this option specified, tool will just list up target files and never delete them.|

