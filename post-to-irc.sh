#!/bin/bash
#
# An ugly hack to let the NickServ setup 
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


# The salient configurables. Set this up to match your desired lore archive.
IRC_SERVER="irc.freenode.net"
IRC_PORT=6667
IRC_CHANNEL="#nasamuffin-testing"
SINCE_TIMESPEC="2 weeks ago" #probably match this to your crontab
ML_GIT_DIR=~/.missed-reviews-bot/archive #clone your lore archive here

./missed-reviews.sh "${IRC_CHANNEL}" "${SINCE_TIMESPEC}" "${ML_GIT_DIR}" | \
  nc ${IRC_SERVER} ${IRC_PORT}
