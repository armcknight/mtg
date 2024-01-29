#!/bin/sh

#  reprocess-all-inputs.sh
#  mtg
#
#  Created by Andrew McKnight on 1/13/24.
#
# A series of commands to build up my managed collection from scratch, more or less mirroring the history of how it actually happened

# !!!: danger! this will delete your current managed collection. make sure you have a backup somewhere.

PWD=`pwd`
SCRYFALL_DATA_DUMP_PATH="${1}"

# build the cli tools

xcodebuild -project mtg.xcodeproj -scheme mtg-cli -configuration Release -derivedDataPath ./build -quiet
xcodebuild -project mtg.xcodeproj -scheme scryfall-local -configuration Release -derivedDataPath ./build -quiet

rm collection/collection.csv collection/decks/* ||:

./build/Build/Products/Release/scryfall-local serve "${SCRYFALL_DATA_DUMP_PATH}"

common_args="./build/Build/Products/Release/mtg-cli --collection-path $PWD/collection --scryfall-data-dump-path /Users/andrewmcknight/Downloads/default-cards-20240127100424.json"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 1"

$common_args --add-to-deck "wilds of eldraine draft 10-22-23" "$PWD/collection/originals_from_tcgplayer/decks/10-22-23 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "wilds of eldraine draft 10-27-23" "$PWD/collection/originals_from_tcgplayer/decks/10-27-23 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "dominaria remastered draft 10-31-23" "$PWD/collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (fixed).txt"
$common_args --add-to-deck "dominaria remastered draft 10-31-23" "$PWD/collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (remainder).txt"
$common_args --add-to-deck "brothers war draft 1-5-2024" "$PWD/collection/originals_from_tcgplayer/decks/brothers war draft 1-5-2024.txt"
$common_args --add-to-deck "goblins" "$PWD/collection/originals_from_tcgplayer/decks/goblin deck.txt"
$common_args --add-to-deck "fae dominion" "$PWD/collection/originals_from_tcgplayer/decks/upgraded fae dominion.txt"
$common_args --add-to-deck "sliver swarm" "$PWD/collection/originals_from_tcgplayer/decks/upgraded sliver swarm.txt"
$common_args --add-to-deck "veloci-ramp-tor" "$PWD/collection/originals_from_tcgplayer/decks/upgraded veloci-ramp-tor.txt"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 2"

killall scryfall-local
