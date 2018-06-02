#!/bin/bash

if [ -z "$2" ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/k3rn31p4nic/travis-ci-discord-webhook" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

CONTENT=""

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="Passed"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="Failed"
    CONTENT="Hey everyone look who broke the build!"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="Status Unknown"
    ;;
esac

AUTHOR_NAME="$CIRCLE_USERNAME"
COMMITTER_NAME="$CIRCLE_USERNAME"
COMMIT_SUBJECT="$CIRCLE_USERNAME"
COMMIT_MESSAGE="$CIRCLE_USERNAME"

if [ "$AUTHOR_NAME" == "$COMMITTER_NAME" ]; then
  CREDITS="$AUTHOR_NAME authored & committed"
else
  CREDITS="$AUTHOR_NAME authored & $COMMITTER_NAME committed"
fi

if [[ ! -z $CIRCLE_PULL_REQUEST ]]; then
  URL="https://github.com/$CIRCLE_PR_REPONAME/pull/$CIRCLE_PR_NUMBER"
else
  URL=""
fi

TIMESTAMP=$(date --utc +%FT%TZ)
WEBHOOK_DATA='{
  "username": "",
  "avatar_url": "",
  "content": "'$CONTENT'",
  "embeds": [ {
    "color": '$EMBED_COLOR',
    "author": {
      "name": "Job #'"$CIRCLE_JOB"' (Build #'"$CIRCLE_BUILD_NUM"') '"$STATUS_MESSAGE"' - '"$CIRCLE_PR_REPONAME"'",
      "url": "https://circleci.com/gh/'"$CIRCLE_PROJECT_USERNAME"'/'"$CIRCLE_PROJECT_REPONAME"'/'"$CIRCLE_BUILD_NUM"'",
      "icon_url": "'$AVATAR'"
    },
    "title": "'"$CIRCLE_BRANCH"'",
    "url": "'"$URL"'",
    "description": "'\\n\\n"$CREDITS"'",
    "fields": [
      {
        "name": "Commit",
        "value": "'"[\`${CIRCLE_SHA1:0:7}\`](https://github.com/$CIRCLE_PROJECT_REPONAME/commit/$CIRCLE_SHA1)"'",
        "inline": true
      },
      {
        "name": "Branch/Tag",
        "value": "'"[\`$CIRCLE_BRANCH\`](https://github.com/$CIRCLE_PROJECT_REPONAME/tree/$CIRCLE_BRANCH)"'",
        "inline": true
      }
    ],
    "timestamp": "'"$TIMESTAMP"'"
  } ]
}'

(curl --fail --progress-bar -A "TravisCI-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$2" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
