#!/bin/sh

#  reprocess-all-inputs.sh
#  mtg
#
#  Created by Andrew McKnight on 1/13/24.
#
# A series of commands to build up my managed collection from scratch, more or less mirroring the history of how it actually happened

# !!!: danger! this will delete your current managed collection. make sure you have a backup somewhere.

#set -x

LOG_LEVEL="${1:-info}"

PWD=`pwd`
DECK_INPUTS="$PWD/collection/originals_from_tcgplayer/decks"

VELOCIRAMPTOR="veloci-ramp-tor"
SLIVER_SWARM="sliver swarm"
FAE_DOMINION="fae dominion"
GOBLINS="goblins"
AZORIUS_STAX="azorius stax"
ORZHOV_LIFE_MATTERS="orzhov life matters"
INFECTA_DECK="infecta deck"
TRANSFORMERS="transformers"
BLAST_FROM_THE_PAST="blast from the past"
GRAND_LARCENY="grand larceny"
TYRANID_SWARM="tyranid swarm"

# build the cli tools

xcodebuild -project mtg.xcodeproj -scheme mtg-cli -configuration Release -derivedDataPath ./build -quiet

rm -rf collection/collection.csv collection/decks ||:

common_args="./build/Build/Products/Release/mtg-cli --collection-path $PWD/collection --log-level ${LOG_LEVEL}"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 1"

$common_args --add-to-deck "2023-10-22 wilds of eldraine draft" --retire "$DECK_INPUTS/2023-10-22 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "2023-10-27 wilds of eldraine draft" --retire "$DECK_INPUTS/2023-10-27 wilds of eldraine draft deck.txt"
$common_args --add-to-deck "2023-10-31 dominaria remastered draft" "$DECK_INPUTS/2023-10-31 dominaria remastered draft deck (fixed).txt"
$common_args --add-to-deck "2023-10-31 dominaria remastered draft" --retire "$DECK_INPUTS/2023-10-31 dominaria remastered draft deck (remainder).txt"
$common_args --add-to-deck "2023-12-08 lci draft" --retire "$DECK_INPUTS/2023-12-08 lci draft 1.txt"
$common_args --add-to-deck "2023-12-22 lci draft" --retire "$DECK_INPUTS/2023-12-22 lci draft 2.txt"
$common_args --add-to-deck "2024-01-05 brothers war draft" --retire "$DECK_INPUTS/2024-01-05 brothers war draft.txt"
$common_args --move-to-deck-from-collection "$GOBLINS" "$DECK_INPUTS/goblin deck.txt"
$common_args --add-to-deck "$FAE_DOMINION" "$DECK_INPUTS/upgraded fae dominion.txt"
$common_args --add-to-deck "$SLIVER_SWARM" "$DECK_INPUTS/upgraded sliver swarm.txt"
$common_args --add-to-deck "$VELOCIRAMPTOR" "$DECK_INPUTS/upgraded veloci-ramp-tor.txt"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 2"

$common_args --move-to-deck-from-collection "$VELOCIRAMPTOR" "$DECK_INPUTS/2024-02-02 dinos in.txt"
$common_args --move-to-collection-from-deck "$VELOCIRAMPTOR" "$DECK_INPUTS/2024-02-02 dinos out.txt"
$common_args --move-to-deck-from-collection "$FAE_DOMINION" "$DECK_INPUTS/2024-02-02 faeries in.txt"
$common_args --move-to-collection-from-deck "$FAE_DOMINION" "$DECK_INPUTS/2024-02-02 faeries out.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$DECK_INPUTS/2024-02-02 slivers in 2.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$DECK_INPUTS/2024-02-02 slivers in.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$DECK_INPUTS/2024-02-02 slivers out 2.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$DECK_INPUTS/2024-02-02 slivers out.txt"

$common_args --add-to-deck "2024-02-02 mkm prerelease deck" "$DECK_INPUTS/2024-02-02 mkm prerelease deck.txt"
$common_args --retire-deck "2024-02-02 mkm prerelease deck"
$common_args --move-to-deck-from-collection "$AZORIUS_STAX" "$DECK_INPUTS/azorius stax.txt"
$common_args --move-to-deck-from-collection "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/orzhov life gain loss.txt"

$common_args --add-to-collection "$PWD/collection/originals_from_tcgplayer/additions/batch 3"

$common_args --move-to-deck-from-collection "$INFECTA_DECK" "$DECK_INPUTS/black poison proliferate.txt"
$common_args --move-to-deck-from-collection "$TRANSFORMERS" "$DECK_INPUTS/transformers.txt"

$common_args --move-to-collection-from-deck "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-02-11 orzhov life matters out.txt"
$common_args --move-to-deck-from-collection "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-02-11 orzhov life matters in.txt"
$common_args --move-to-deck-from-collection "$INFECTA_DECK" "$DECK_INPUTS/2024-03-04 black poison proliferate in.txt"
$common_args --move-to-collection-from-deck "$INFECTA_DECK" "$DECK_INPUTS/2024-03-04 black poison proliferate out.txt"
$common_args --move-to-deck-from-collection "$GOBLINS" "$DECK_INPUTS/2024-03-04 goblins in.txt"
$common_args --move-to-collection-from-deck "$GOBLINS" "$DECK_INPUTS/2024-03-04 goblins out.txt"
$common_args --move-to-deck-from-collection "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-03-04 orzhov life matters in.txt"
$common_args --move-to-collection-from-deck "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-03-04 orzhov life matters out.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$DECK_INPUTS/2024-03-04 slivers in.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$DECK_INPUTS/2024-03-04 slivers out.txt"

$common_args --move-to-deck-from-collection "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-03-05 orzhov life matters in.txt"
$common_args --move-to-collection-from-deck "$ORZHOV_LIFE_MATTERS" "$DECK_INPUTS/2024-03-05 orzhov life matters out.txt"
$common_args --move-to-deck-from-collection "$SLIVER_SWARM" "$DECK_INPUTS/2024-03-05 slivers in.txt"
$common_args --move-to-collection-from-deck "$SLIVER_SWARM" "$DECK_INPUTS/2024-03-05 slivers out.txt"

$common_args --move-to-deck-from-collection "$AZORIUS_STAX" "$DECK_INPUTS/2024-03-07 azorius stax in.txt"
$common_args --move-to-collection-from-deck "$AZORIUS_STAX" "$DECK_INPUTS/2024-03-07 azorius stax out.txt"
$common_args --move-to-deck-from-collection "$INFECTA_DECK" "$DECK_INPUTS/2024-03-07 black poison proliferate in.txt"
$common_args --move-to-collection-from-deck "$INFECTA_DECK" "$DECK_INPUTS/2024-03-07 black poison proliferate out.txt"
$common_args --move-to-deck-from-collection "$FAE_DOMINION" "$DECK_INPUTS/2024-03-07 fae dominion in.txt"
$common_args --move-to-collection-from-deck "$FAE_DOMINION" "$DECK_INPUTS/2024-03-07 fae dominion out.txt"
$common_args --move-to-deck-from-collection "$FAE_DOMINION" "$DECK_INPUTS/2024-03-07 fae dominion in 2.txt"
$common_args --move-to-collection-from-deck "$FAE_DOMINION" "$DECK_INPUTS/2024-03-07 fae dominion out 2.txt"
$common_args --move-to-deck-from-collection "$GOBLINS" "$DECK_INPUTS/2024-03-07 goblins in.txt"
$common_args --move-to-collection-from-deck "$GOBLINS" "$DECK_INPUTS/2024-03-07 goblins out.txt"

$common_args --move-to-deck-from-collection "$INFECTA_DECK" "$DECK_INPUTS/2024-03-17 black poison proliferate in.txt"
$common_args --move-to-collection-from-deck "$INFECTA_DECK" "$DECK_INPUTS/2024-03-17 black poison proliferate out.txt"
$common_args --move-to-deck-from-collection "$TRANSFORMERS" "$DECK_INPUTS/2024-03-17 transformers in.txt"
$common_args --move-to-collection-from-deck "$TRANSFORMERS" "$DECK_INPUTS/2024-03-17 transformers out.txt"
$common_args --move-to-deck-from-collection "$INFECTA_DECK" "$DECK_INPUTS/2024-03-21 infecta deck in.txt"
$common_args --move-to-collection-from-deck "$INFECTA_DECK" "$DECK_INPUTS/2024-03-21 infecta deck out.txt"
$common_args --move-to-deck-from-collection "$AZORIUS_STAX" "$DECK_INPUTS/2024-03-24 azorius stax in.txt"
$common_args --move-to-collection-from-deck "$AZORIUS_STAX" "$DECK_INPUTS/2024-03-24 azorius stax out.txt"
$common_args --add-to-deck "2024-04-12 outlaws of thunder junction prerelease" --retire "$DECK_INPUTS/2024-04-12 outlaws of thunder junction prerelease.txt"
$common_args --move-to-deck-from-collection "$VELOCIRAMPTOR" "$DECK_INPUTS/2024-04-16-dinos-in.txt"
$common_args --move-to-collection-from-deck "$VELOCIRAMPTOR" "$DECK_INPUTS/2024-04-16-dinos-out.txt"

$common_args --add-to-deck "$BLAST_FROM_THE_PAST" "$DECK_INPUTS/doctor who blast from the past.txt"
$common_args --move-to-deck-from-collection "$BLAST_FROM_THE_PAST" "$DECK_INPUTS/2024-05-03 doctor who in.txt"
$common_args --move-to-collection-from-deck "$BLAST_FROM_THE_PAST" "$DECK_INPUTS/2024-05-03 doctor who out.txt"

$common_args --add-to-deck "$GRAND_LARCENY" "$DECK_INPUTS/outlaws of thunder junction grand larceny.txt"
$common_args --add-to-deck "$TYRANID_SWARM" "$DECK_INPUTS/warhammer 40k tyranid swarm.txt"
