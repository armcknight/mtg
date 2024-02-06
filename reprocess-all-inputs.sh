#!/bin/sh

#  reprocess-all-inputs.sh
#  mtg
#
#  Created by Andrew McKnight on 1/13/24.
#
# A series of commands to build up my managed collection from scratch, more or less mirroring the history of how it actually happened

# !!!: danger! this will delete your current managed collection. make sure you have a backup somewhere.

#set -x

PWD=`pwd`
SCRYFALL_DATA_DUMP_PATH="${1}"

VELOCIRAMPTOR="veloci-ramp-tor"
SLIVER_SWARM="sliver swarm"
FAE_DOMINION="fae dominion"
GOBLINS="goblins"
AZORIUS_STAX="azorius stax"
ORZHOV_LIFE_MATTERS="orzhov life matters"
BLACK_POISON_PROLIFERATE="black poison proliferate"

# build the cli tools

xcodebuild -project mtg.xcodeproj -scheme mtg-cli -configuration Release -derivedDataPath ./build -quiet
xcodebuild -project mtg.xcodeproj -scheme scryfall-local -configuration Release -derivedDataPath ./build -quiet

rm collection/collection.csv collection/decks/* ||:

./build/Build/Products/Release/scryfall-local serve "${SCRYFALL_DATA_DUMP_PATH}" &
SCRYFALL_SERVER_PID=$!
sleep 20

common_args="./build/Build/Products/Release/mtg-cli --collection-path $PWD/collection"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 1"

$common_args --add-to-deck "wilds of eldraine draft 10-22-23" --retire "$PWD/collection/originals_from_tcgplayer/decks/10-22-23 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "wilds of eldraine draft 10-27-23" --retire "$PWD/collection/originals_from_tcgplayer/decks/10-27-23 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "dominaria remastered draft 10-31-23" --retire "$PWD/collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (fixed).txt"
$common_args --add-to-deck "dominaria remastered draft 10-31-23" --retire "$PWD/collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (remainder).txt"
$common_args --add-to-deck "brothers war draft 1-5-2024" --retire "$PWD/collection/originals_from_tcgplayer/decks/brothers war draft 1-5-2024.txt"
$common_args --add-to-deck "$GOBLINS" "$PWD/collection/originals_from_tcgplayer/decks/goblin deck.txt"
$common_args --add-to-deck "$FAE_DOMINION" "$PWD/collection/originals_from_tcgplayer/decks/upgraded fae dominion.txt"
$common_args --add-to-deck "$SLIVER_SWARM" "$PWD/collection/originals_from_tcgplayer/decks/upgraded sliver swarm.txt"
$common_args --add-to-deck "$VELOCIRAMPTOR" "$PWD/collection/originals_from_tcgplayer/decks/upgraded veloci-ramp-tor.txt"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 2"

$common_args --move-to-deck-from-collection "$VELOCIRAMPTOR" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 dinos in.txt"
$common_args --move-to-collection-from-deck "$VELOCIRAMPTOR" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 dinos out.txt"
$common_args --move-to-deck-from-collection "$FAE_DOMINION" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 faeries in.txt"
$common_args --move-to-collection-from-deck "$FAE_DOMINION" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 faeries out.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 slivers in 2.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 slivers in.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 slivers out 2.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 slivers out.txt"

$common_args --add-to-deck "02-02-24 mkm prerelease deck" "$PWD/collection/originals_from_tcgplayer/decks/02-02-24 mkm prerelease deck.txt"
$common_args --retire-deck "02-02-24 mkm prerelease deck"
$common_args --move-to-deck-from-collection "$AZORIUS_STAX" "$PWD/collection/originals_from_tcgplayer/decks/azorius stax.txt"
$common_args --move-to-deck-from-collection "$ORZHOV_LIFE_MATTERS" "$PWD/collection/originals_from_tcgplayer/decks/orzhov life gain loss.txt"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 2"

$common_args --move-to-deck-from-collection "$BLACK_POISON_PROLIFERATE" "$PWD/collection/originals_from_tcgplayer/decks/black poison proliferate.txt"

kill $SCRYFALL_SERVER_PID
