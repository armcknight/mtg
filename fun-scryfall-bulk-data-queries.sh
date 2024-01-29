#!/bin/sh

#  get-plist-collector-numbers.sh
#  mtg
#
#  Created by Andrew McKnight on 1/27/24.
#
# Whenever I run an interesting jq query on the scryfall data dump, I record it here

SCRYFALL_DATA_DUMP_PATH="${1}"

# count the occurrences of keywords amongst cards, like flying, enchant, trample etc
cat "${SCRYFALL_DATA_DUMP_PATH}" | jq '.[] | .keywords | .[]' | sort | uniq -c | sort

# count the cards in each set present
cat "${SCRYFALL_DATA_DUMP_PATH}" | jq '.[] | .set_name' | sort | uniq -c | sort
