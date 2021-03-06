#!/bin/bash
#
# Point out some missed reviews on lore.kernel.org/git.
#
# Author: nasamuffin
#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://github.com/seejohnrun/haste-client#lightweight-alternative
# Lightly modified to give the raw URL
# TODO: I don't *think* hastebin does formatting but it'd be nice to use a
# format which allows URL linkification.
haste() { a=$(cat); curl -X POST -s -d "$a" https://hastebin.com/documents \
	| awk -F '"' '{print "https://hastebin.com/raw/"$4}'; }

IRC_CHANNEL="$1"
SINCE_DATE=$(date -d "$2" +%Y-%m-%d)
ML_GIT_DIR="$3"
NICK=MissedReviewsBot # Pick a different name for yours - this one's NickServ regged
NICKSERV_PW=hunter2 # Of course it's not this

# Log into IRC first so we have time to talk to NickServ.
echo USER ${NICK} ignored ignored :Missed Reviews Bot
echo NICK ${NICK}
echo PRIVMSG NickServ :identify ${NICKSERV_PW}

# The MOTD takes forever to show up. Ugh.
sleep 30

# Grab all the emails from the past week.
ALL_PATCHES=$(mktemp)
PASTE_CONTENTS=$(mktemp)
cd "${ML_GIT_DIR}" || exit
git pull --ff-only &>/dev/null

# Which ones are patches or RFCs?
git log --oneline --after="${SINCE_DATE}" --grep "^\[\(PATCH\|RFC\)" >"${ALL_PATCHES}"

# Of these, which ones have no non-PATCH replies?
while read -r line
do
  SUBJECT="$(echo "${line}" | cut -f 2- -d' ')"
  COMMIT="$(echo "${line}" | cut -f 1 -d' ')"
  if [[ $(git rev-list --count --all --after="${SINCE_DATE}" -F --grep "${SUBJECT}") -eq 1 ]]; then
    # Grab the lore link
    MESSAGE_ID=$(git show "${COMMIT}" | grep -iP --only-matching "(?<=\+message-id: <)[^>]+(?=>)")
    echo "${SUBJECT}" "(https://lore.kernel.org/git/${MESSAGE_ID})" >>"${PASTE_CONTENTS}"
  fi
done <"${ALL_PATCHES}"

# Write these results to a clipboard hoster.
PASTE_RAW_LINK=$(haste --raw <"${PASTE_CONTENTS}")

# Write the clipboard hoster, and a summary, to IRC.
IGNORED_PATCH_COUNT=$(wc -l <"${PASTE_CONTENTS}")
TOTAL_PATCH_COUNT=$(wc -l <"${ALL_PATCHES}")

echo JOIN ${IRC_CHANNEL}
echo PRIVMSG ${IRC_CHANNEL} :Hi! Since ${SINCE_DATE} there have been ${IGNORED_PATCH_COUNT} untouched reviews: ${PASTE_RAW_LINK}
echo PRIVMSG ${IRC_CHANNEL} :That\'s $(bc <<<"100*$IGNORED_PATCH_COUNT/$TOTAL_PATCH_COUNT" )% of new patches sent since then.
echo PRIVMSG ${IRC_CHANNEL} :If you have feedback on this bot, blame nasamuffin.
echo QUIT
