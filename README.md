MissedReviewsBot - professional lore archive tattletale
=======================================================

Add MissedReviewsBot to a crontab to tell the IRC channel of your choice how
many patches were ignored in your lore.kernel.org (or other public-inbox)
archive.

Written by nasamuffin after the Git Inclusion Summit 2020 to remind Git
contributors which patches have been ignored.

# Setup

1. Clone this repo!
2. Change the salient configurables in post-to-irc.sh and missed-reviews.sh
   (they're near the top)
3. Clone your lore archive into `$ML_GIT_DIR`.
4. Set up a cronjob to run your reviewer bot as often as you like, probably to
   match `$SINCE_DATE`. The executable to target is post-to-irc.sh.
5. Ignore less reviews. Hopefully.
