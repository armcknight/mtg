#!/bin/sh

#  reprocess-all-inputs.sh
#  mtg
#
#  Created by Andrew McKnight on 1/13/24.
#

# build the cli tool

xcodebuild -project mtg.xcodeproj -scheme mtg-cli -configuration Release -derivedDataPath ./build -quiet

# invocations to process all inputs from a clean slate collection

./build/Build/Products/Release/mtg-cli --add-to-collection --collection-path ./collection collection/originals_from_tcgplayer/additions

# decks
./build/Build/Products/Release/mtg-cli --add-to-deck "wilds of eldraine draft 10-22-23" --collection-path ./collection "collection/originals_from_tcgplayer/decks/10-22-23 wilds of eldraine draft deck.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "wilds of eldraine draft 10-27-23" --collection-path ./collection "collection/originals_from_tcgplayer/decks/10-27-23 wilds of eldraine draft deck.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "dominaria remastered draft 10-31-23" --collection-path ./collection "collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (fixed).txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "dominaria remastered draft 10-31-23" --collection-path ./collection "collection/originals_from_tcgplayer/decks/10-31-23 dominaria remastered draft deck (remainder).txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "brothers war draft 1-5-2024" --collection-path ./collection "collection/originals_from_tcgplayer/decks/brothers war draft 1-5-2024.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "goblins" --collection-path ./collection "collection/originals_from_tcgplayer/decks/goblin deck.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "fae dominion" --collection-path ./collection "collection/originals_from_tcgplayer/decks/upgraded fae dominion.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "sliver swarm" --collection-path ./collection "collection/originals_from_tcgplayer/decks/upgraded sliver swarm.txt"
./build/Build/Products/Release/mtg-cli --add-to-deck "veloci-ramp-tor" --collection-path ./collection "collection/originals_from_tcgplayer/decks/upgraded veloci-ramp-tor.txt"
