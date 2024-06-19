#!/bin/sh

#  reprocess-all-inputs.sh
#  mtg
#
#  Created by Andrew McKnight on 1/13/24.
#
# A series of commands to build up my managed collection from scratch, more or less mirroring the history of how it actually happened

# !!!: danger! this will delete your current managed collection. make sure you have a backup somewhere.

set -x

while test $# -gt 0; do
  case "$1" in
    -l)
      shift
      if test $# -gt 0; then
        export LOG_LEVEL=$1
      else
        echo "no log level specified"
        exit 1
      fi
      shift
      ;;
    --log-level*)
      export LOG_LEVEL=`echo $1 | sed -e 's/^[^=]*=//g'`
      if [[ -z "${LOG_LEVEL}" ]]; then
        echo "no log level specified"
        exit 1
      fi
      shift
      ;;
    -i)
      INTERACTIVE=1 # after each step, wait for terminal input to either proceed or quit
      shift
      ;;
    --interactive)
      INTERACTIVE=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [[ -z "${LOG_LEVEL}" ]]; then
    LOG_LEVEL="info"
fi

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
    
if [[ $INTERACTIVE -eq 1 ]]; then
    git branch -D reprocessing
    git checkout -b reprocessing
fi


STEP=1
function runStep() {
    eval "$common_args ${1}"
    if [[ $INTERACTIVE -eq 1 ]]; then
    git add collection
        git difftool --cached
        read -p "Proceed (p) or quit (q)?: " option
        if [[ $option == "q" ]]; then
            exit 0
        fi
        git commit --message "$STEP: ${1}"
    fi
    STEP=$((STEP+1))
}

runStep "--add-to-collection \"$PWD/collection/originals_from_tcgplayer/additions/batch 1\""

runStep "--add-to-deck \"2023-10-22 wilds of eldraine draft\" --retire \"$DECK_INPUTS/2023-10-22 wilds of eldraine draft deck.txt\""
runStep "--add-to-deck \"2023-10-27 wilds of eldraine draft\" --retire \"$DECK_INPUTS/2023-10-27 wilds of eldraine draft deck.txt\""
runStep "--add-to-deck \"2023-10-31 dominaria remastered draft\" \"$DECK_INPUTS/2023-10-31 dominaria remastered draft deck (fixed).txt\""
runStep "--add-to-deck \"2023-10-31 dominaria remastered draft\" --retire \"$DECK_INPUTS/2023-10-31 dominaria remastered draft deck (remainder).txt\""
runStep "--add-to-deck \"2023-12-08 lci draft\" --retire \"$DECK_INPUTS/2023-12-08 lci draft 1.txt\""
runStep "--add-to-deck \"2023-12-22 lci draft\" --retire \"$DECK_INPUTS/2023-12-22 lci draft 2.txt\""
runStep "--add-to-deck \"2024-01-05 brothers war draft\" --retire \"$DECK_INPUTS/2024-01-05 brothers war draft.txt\""
runStep "--move-to-deck-from-collection \"$GOBLINS\" \"$DECK_INPUTS/goblin deck.txt\""
runStep "--add-to-deck \"$FAE_DOMINION\" \"$DECK_INPUTS/upgraded fae dominion.txt\""
runStep "--add-to-deck \"$SLIVER_SWARM\" \"$DECK_INPUTS/upgraded sliver swarm.txt\""
runStep "--add-to-deck \"$VELOCIRAMPTOR\" \"$DECK_INPUTS/upgraded veloci-ramp-tor.txt\""

runStep "--add-to-collection \"$PWD/collection/originals_from_tcgplayer/additions/batch 2\""

runStep "--move-to-deck-from-collection \"$VELOCIRAMPTOR\" \"$DECK_INPUTS/2024-02-02 dinos in.txt\""
runStep "--move-to-collection-from-deck \"$VELOCIRAMPTOR\" \"$DECK_INPUTS/2024-02-02 dinos out.txt\""
runStep "--move-to-deck-from-collection \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-02-02 faeries in.txt\""
runStep "--move-to-collection-from-deck \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-02-02 faeries out.txt\""
runStep "--move-to-deck-from-collection \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-02-02 slivers in 2.txt\""
runStep "--move-to-deck-from-collection \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-02-02 slivers in.txt\""
runStep "--move-to-collection-from-deck \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-02-02 slivers out 2.txt\""
runStep "--move-to-collection-from-deck \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-02-02 slivers out.txt\""

runStep "--add-to-deck \"2024-02-02 mkm prerelease deck\" \"$DECK_INPUTS/2024-02-02 mkm prerelease deck.txt\""
runStep "--retire-deck \"2024-02-02 mkm prerelease deck\""
runStep "--move-to-deck-from-collection \"$AZORIUS_STAX\" \"$DECK_INPUTS/azorius stax.txt\""
runStep "--move-to-deck-from-collection \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/orzhov life gain loss.txt\""

runStep "--add-to-collection \"$PWD/collection/originals_from_tcgplayer/additions/batch 3\""

runStep "--move-to-deck-from-collection \"$INFECTA_DECK\" \"$DECK_INPUTS/black poison proliferate.txt\""
runStep "--move-to-deck-from-collection \"$TRANSFORMERS\" \"$DECK_INPUTS/transformers.txt\""

runStep "--move-to-collection-from-deck \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-02-11 orzhov life matters out.txt\""
runStep "--move-to-deck-from-collection \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-02-11 orzhov life matters in.txt\""
runStep "--move-to-deck-from-collection \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-04 black poison proliferate in.txt\""
runStep "--move-to-collection-from-deck \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-04 black poison proliferate out.txt\""
runStep "--move-to-deck-from-collection \"$GOBLINS\" \"$DECK_INPUTS/2024-03-04 goblins in.txt\""
runStep "--move-to-collection-from-deck \"$GOBLINS\" \"$DECK_INPUTS/2024-03-04 goblins out.txt\""
runStep "--move-to-deck-from-collection \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-03-04 orzhov life matters in.txt\""
runStep "--move-to-collection-from-deck \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-03-04 orzhov life matters out.txt\""
runStep "--move-to-deck-from-collection \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-03-04 slivers in.txt\""
runStep "--move-to-collection-from-deck \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-03-04 slivers out.txt\""

runStep "--move-to-deck-from-collection \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-03-05 orzhov life matters in.txt\""
runStep "--move-to-collection-from-deck \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-03-05 orzhov life matters out.txt\""
runStep "--move-to-deck-from-collection \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-03-05 slivers in.txt\""
runStep "--move-to-collection-from-deck \"$SLIVER_SWARM\" \"$DECK_INPUTS/2024-03-05 slivers out.txt\""

runStep "--move-to-deck-from-collection \"$AZORIUS_STAX\" \"$DECK_INPUTS/2024-03-07 azorius stax in.txt\""
runStep "--move-to-collection-from-deck \"$AZORIUS_STAX\" \"$DECK_INPUTS/2024-03-07 azorius stax out.txt\""
runStep "--move-to-deck-from-collection \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-07 black poison proliferate in.txt\""
runStep "--move-to-collection-from-deck \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-07 black poison proliferate out.txt\""
runStep "--move-to-deck-from-collection \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-03-07 fae dominion in.txt\""
runStep "--move-to-collection-from-deck \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-03-07 fae dominion out.txt\""
runStep "--move-to-deck-from-collection \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-03-07 fae dominion in 2.txt\""
runStep "--move-to-collection-from-deck \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-03-07 fae dominion out 2.txt\""
runStep "--move-to-deck-from-collection \"$GOBLINS\" \"$DECK_INPUTS/2024-03-07 goblins in.txt\""
runStep "--move-to-collection-from-deck \"$GOBLINS\" \"$DECK_INPUTS/2024-03-07 goblins out.txt\""

runStep "--move-to-deck-from-collection \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-17 black poison proliferate in.txt\""
runStep "--move-to-collection-from-deck \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-17 black poison proliferate out.txt\""
runStep "--move-to-deck-from-collection \"$TRANSFORMERS\" \"$DECK_INPUTS/2024-03-17 transformers in.txt\""
runStep "--move-to-collection-from-deck \"$TRANSFORMERS\" \"$DECK_INPUTS/2024-03-17 transformers out.txt\""
runStep "--move-to-deck-from-collection \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-21 infecta deck in.txt\""
runStep "--move-to-collection-from-deck \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-03-21 infecta deck out.txt\""
runStep "--move-to-deck-from-collection \"$AZORIUS_STAX\" \"$DECK_INPUTS/2024-03-24 azorius stax in.txt\""
runStep "--move-to-collection-from-deck \"$AZORIUS_STAX\" \"$DECK_INPUTS/2024-03-24 azorius stax out.txt\""
runStep "--add-to-deck \"2024-04-12 outlaws of thunder junction prerelease\" --retire \"$DECK_INPUTS/2024-04-12 outlaws of thunder junction prerelease.txt\""
runStep "--move-to-deck-from-collection \"$VELOCIRAMPTOR\" \"$DECK_INPUTS/2024-04-16-dinos-in.txt\""
runStep "--move-to-collection-from-deck \"$VELOCIRAMPTOR\" \"$DECK_INPUTS/2024-04-16-dinos-out.txt\""

runStep "--add-to-deck \"$BLAST_FROM_THE_PAST\" \"$DECK_INPUTS/doctor who blast from the past.txt\""
runStep "--move-to-deck-from-collection \"$BLAST_FROM_THE_PAST\" \"$DECK_INPUTS/2024-05-03 doctor who in.txt\""
runStep "--move-to-collection-from-deck \"$BLAST_FROM_THE_PAST\" \"$DECK_INPUTS/2024-05-03 doctor who out.txt\""

runStep "--add-to-deck \"$GRAND_LARCENY\" \"$DECK_INPUTS/outlaws of thunder junction grand larceny.txt\""

# currently has following errors:
#2024-06-16T01:35:45-0800 notice mtg : [mtg] Failed to get Scryfall info for TCGPlayer card Optional("Transmutation Font") (LARP 11): Request failed with HTTP status 404.
#2024-06-16T01:35:46-0800 notice mtg : [mtg] TCGPlayer and Scryfall disagree on rarity level for TCGPlayer card Breathe Your Last (MH3 82)!
#mtg/Card.swift:137: Fatal error: Failed to parse Printing from
runStep "--add-to-deck \"$TYRANID_SWARM\" \"$DECK_INPUTS/warhammer 40k tyranid swarm.txt\""

runStep "--add-to-collection \"$PWD/collection/originals_from_tcgplayer/additions/batch 4\""

# these three have missing cards that should've gone in... need to figure out what they are and scan them in
runStep "--move-to-collection-from-deck \"$FAE_DOMINION\" \"$DECK_INPUTS/2024-05-26 faeries out.txt\""
runStep "--move-to-collection-from-deck \"$INFECTA_DECK\" \"$DECK_INPUTS/2024-05-26 infecta deck out.txt\""
runStep "--move-to-collection-from-deck \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-05-26 orzhov life matters out.txt\""

runStep "--move-to-deck-from-collection \"$GOBLINS\" \"$DECK_INPUTS/2024-05-28 goblins in.txt\""
runStep "--move-to-collection-from-deck \"$GOBLINS\" \"$DECK_INPUTS/2024-05-28 goblins out.txt\""
runStep "--move-to-deck-from-collection \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-05-28 orzhov life matters in.txt\""
runStep "--move-to-collection-from-deck \"$ORZHOV_LIFE_MATTERS\" \"$DECK_INPUTS/2024-05-28 orzhov life matters out.txt\""
runStep "--move-to-deck-from-collection \"$TRANSFORMERS\" \"$DECK_INPUTS/2024-06-04 transformers in.txt\""
runStep "--move-to-collection-from-deck \"$TRANSFORMERS\" \"$DECK_INPUTS/2024-06-04 transformers out.txt\""

# currently has error: mtg/Card.swift:137: Fatal error: Failed to parse Printing from
runStep "--add-to-deck \"2024-06-07 MH3 prerelease deck\" --retire \"$DECK_INPUTS/2024-06-07-mh3-prerelease.csv\""
runStep "--add-to-deck \"2024-06-15 MH3 draft\" --retire \"$DECK_INPUTS/2024-06-15-mh3-draft.csv\""
