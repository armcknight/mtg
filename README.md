# mtg

Magical programs 🪄✨ A project to help manage my collection of Magic: the Gathering cards.

There are many great scanner and collection management apps out there (so far I've scanned ~2700 cards with TCGPlayer's iOS app, so I started with that format). I created this so that I can fully own the data about my cards without having to create an account with a service that may disappear or change business models at any time (the closest to my ideal that I've seen so far is Lion's Eye that stores data in iCloud). Usually, there is some specific functionality that may exist in one but not another. Here, I can create any functionality I think of.

# Details

`make init` to start. So far just clones the submodules, which are Swift packages integrated from their local paths. I had to fork [Progress.swift](https://github.com/jkandzi/Progress.swift) to fix an [off-by-one error](https://github.com/jkandzi/Progress.swift/pull/12).

There are currently two tools:
- `mtg-cli` manages the card collection
- `scryfall-local` downloads and serves Scryfall bulk data files to avoid making lots of individual requests to their web server

I keep the original TCGPlayer CSVs checked in here, along with the managed CSVs. `./reprocess-all-inputs.sh` will run the tools for all the different card scans I've done so far, roughly in the same discrete sets of scans I've done, which demonstrates how the programs work.

## `mtg-cli`

The collection is contained in multiple CSV files:
- base list of stored collection not currently in use
- a list for each constructed deck

These are stored at the selected managed location as follows:
```
.
├── collection.csv
└── decks/
    ├── fae dominion.csv
    ├── sliver swarm.cs
    └── retired/
        ├── wilds of eldraine draft 1.csv
        ├── wilds of eldraine draft 2.csv
        └── murder at karlov manor prerelease.csv
```

```
$> mtg-cli -h

OVERVIEW: Take a CSV file from a card scanner app like TCGPlayer and
incorporate the cards it describes into a database of cards describing a base
collection and any number of constructed decks. Cards in constructed decks are
not duplicated in the base collection.

USAGE: mtg [--migrate] [--add-to-collection] [--remove-from-collection <remove-from-collection>] [--add-to-deck <add-to-deck>] [--move-to-deck-from-collection <move-to-deck-from-collection>] [--move-to-collection-from-deck <move-to-collection-from-deck>] [--collection-path <collection-path>] [--backup-files-before-modifying] [--scryfall-data-dump-path <scryfall-data-dump-path>] [--retire-deck <retire-deck>] [--retire] [<input-path>]

ARGUMENTS:
  <input-path>            A path to a CSV file or directories containing CSV
                          files that contain cards to process according to the
                          specified options.

OPTIONS:
  --migrate               Migrate the existing managed CSVs to include any new
                          features developed after they were generated.
  --add-to-collection     Add the cards in the input CSV to the base collection.
  --remove-from-collection <remove-from-collection>
                          Remove the cards in the input CSV from the base
                          collection. You may want to do this if you've sold
                          the cards. (default: false)
  --add-to-deck <add-to-deck>
                          Add new cards not already in the base collection
                          directly to a deck.
  --move-to-deck-from-collection <move-to-deck-from-collection>
                          Move the cards from the base collection to a deck. If
                          the card doesn't already exist in the collection, its
                          record will be "created" in the deck.
  --move-to-collection-from-deck <move-to-collection-from-deck>
                          Remove the cards from the specified deck and place
                          them in the base collection.
  --collection-path <collection-path>
                          Custom location of the managed CSV files. (default: .)
  --backup-files-before-modifying
                          Create backup files before modifying any managed CSV
                          file.
  --scryfall-data-dump-path <scryfall-data-dump-path>
                          Location of Scryfall data dump file.
  --retire-deck <retire-deck>
                          Retired a deck: keep its list, but move its cards
                          back into the collection.
  --retire                When adding cards to a deck, also retire that deck
  -h, --help              Show help information.
```

## `scryfall-local`

Card data is imported from Scryfall using their [bulk data downloads](https://scryfall.com/docs/api/bulk-data). The `scryfall-local` tool can download these and then serve them locally via a HTTP server for `mtg-cli` to request the card info from.

```
$> scryfall-local -h

OVERVIEW: Manage and use local Scryfall bulk data files to query for card
information.

USAGE: scryfall-local <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  serve                   Run a local HTTP server that serves requests into a
                          Scryfall bulk data JSON file.
  download                Manage local downloads of Scryfall bulk data.

  See 'scryfall-local help <subcommand>' for detailed help.
```

# Features/TODO

- [x] Ingest a CSV from the TCGPlayer iOS app containing scanned cards
- [x] Handle folders of CSVs to process
- [x] Custom location of managed CSVs
- Given input CSV, perform any combination of operations:
    - base list
        - [x] appending
        - [x] subtracting
    - [x] moving cards from one list to another (which is really just subtracting from one and appending to another)
- [ ] Change order of collection CSV fields to put most relevant deckbuilding info first: Quantity, EDHREC Rank, Color Identity, Simple Name, Rarity, Mana Cost, Type Line, Oracle Text, Colors, Power, Toughness, CMC, Keywords, Produced Mana
- [ ] consolidate identical card entries in input lists
- Collector features
    - [ ] show list of sets with completion % of each (bucketed by rarity)
- Deck building features
    - [ ] Combo searches using Scryfall `related_card`:`combo_piece`
    - [x] Given a deck list, determine which cards are already owned in the collection and other decks vs ones that would need to be acquired
        - [ ] do this for lists of decks, ranking from most % owned to least % owned
    - [ ] Track history of deck edits
    - [x] Ratio analysis: types: mana, creatures, enchantments, artifacts, equipment, vehicles; interaction: removal, countermagic, boardwipe, landhate, grouphug, control; abilities: evasion, ramp, gowide
    - [ ] card type search: for each card type query, be able to search collection for cards of that type (e.g. find all "card draw" cards)
    - [ ] Mana curve analysis
    - [ ] Format legality
    - [ ] Commander bracketing
        - [ ] Canlander pointing and other related formats
    - [ ] Pauper EDH Commander legality (legendaries printed at uncommon at any point in their history: must check all printings of a given card)
    - [ ] win/loss records
    - [ ] personal deck notes
    - [ ] tempo analysis
        - [ ] aggro/midrange/control classification
    - ~~[ ] Change to keeping decks tracked in the one collection.csv with a new column for "Deck name"?~~
    - [x] appending
    - [x] subtracting
    - [x] sideboards
        - current workaround: just track it as a separate "deck"; so for like a deck named "rakdos burn", there'd be the rakdos-burn.csv and rakdos-burn-sideboard.csv
            - [x] actually, encode this behavior, with a new flag option `--sideboard` that will fail out if the name of the deck is either not supplied or doesn't match any currently tracked decks
    - Wishlists (per deck? similar to sideboards)
        - [ ] generate report of current price outlays, per set/printing, constrained by condition, sorted by price, with links
        - [ ] Search for upcoming reprints–helpful with very expensive/old cards
            - Actually, this would be an interesting query to run for each new set coming out to see what could shift or what the chase cards could be
        - [ ] generate bulk data entry for TCGPlayer shopping
    - [x] proxies; these don't move to the collection when retiring or swapping out
    - [x] Deck retirement: move the cards back into collection, but keep the deck list in a separate area that can be excluded from the rest of searches, like in `/decks/retired/<deck-name>.csv` (both a `--retire-deck` option is provided for direct action on a deck, and a `--retire` flag is provided that will work with `--add-to-deck` for immediate retirement of the deck from the input list)
- Incorporate information from other card info sources:
    - [x] Scryfall API
    - [x] Scryfall bulk data download
        - [ ] download card images
        - [x] actually, _only_ support bulk data download, don't even use the network API
        - [ ] migrations should update scryfall data that is out of date in the managed collection after a new bulk data download
        - [x] put it behind a local HTTP server so it doesn't have to be decoded on every invocation of the CLI
            - [ ] automatically start the HTTP server from `mtg-cli` if it's not already running?
            - [x] automate downloading bulk data dumps
            - [ ] automatically determine if local data is out of date and automatically download a newer version of it before spinning up the HTTP server (or even while it's running if it's daemonized?)
    - [x] personal notes/tags/keywords
    - [ ] cycle membership ("enemy fetchlands", "sun's twilight", etc)
- Translating between different services' card list formats
    - Export to formats for other services/apps:
        - [ ] lion's eye iOS app
        - [ ] moxfield
        - [ ] archidekt
        - [ ] mtggoldfish
        - [ ] mtgdecks
        - [ ] manabox
        - [ ] edhrec
        - [ ] deckbox
        - [ ] tappedout
        - [ ] UrzaGatherer
        - [ ] TCGPlayer mass buy list (e.g. `1 Bria, Riptide Rogue [BLB] 379`)
    - Import from other card scanner apps (in addition to export formats from those other services mentioned above)
        - [x] TCGPlayer
            - [ ] Get frame effects like showcase, extended art, borderless, retro frame and etched foil from name and attach the correct scryfall frame effect enum case; keep the full name with the original description, as simple names already have it stripped
        - [ ] collectr
        - [ ] dragon shield mtg scanner
        - [ ] tcgfish
        - [ ] card binder
        - [ ] card castle
        - [x] quantity / set code / card number
            - [x] rewrite in moxfield format so that card names are searchable in the file
        - [x] moxfield exports, e.g.
            ```
            1 Alela, Cunning Conqueror (WOC) 3 *F*
            1 Arcane Denial (WOC) 84
            ```
        - [ ] for formats other than TCGPlayer imports, get the TCGPlayer info present in the Scryfall data
            - [ ] can get the TCGPlayer URL for a specific card–scrape the webpage data
- [x] Consolidate counts of duplicate entries (happens if you get the same card again later and scan it again)
    - [x] fix this, it only consolidates the current input, but needs to include previously recorded cards
    - [x] make progress display for long-running operations optional
- card timeseries data like EDHREC rank, prices, fetch dates etc
    - [ ] add option when adding cards for whether to update timeseries (or even all scryfall/tcgplayer/etc) data for cards already in the managed CSV, like when consolidating preexisting with new incoming cards. makes looking at diffs after reprocessing easier to see added/removed cards
    - [ ] another to just update all timeseries data
    - [ ] print a pretty report to summarize changes
- [ ] track printing dates and format rotations: card values tend to change after being rotated out of standard/modern!
    - [ ] also bans and restrictions
- [x] Sort the rows in the CSV files by card name for better git diffing
- [ ] List diffs, to e.g. compare deck lists
- Logging improvements
    - [ ] Output progress indicators to stderr so they can be excluded from baseline log output from reprocessing script
    - [x] and/or introduce log levels

## Bugs

- [ ] some scryfall data isn't being written to CSV. possibly always try the joined values from card_faces before root when decoding

## WONTDO

- Card search through base and constructed lists
    - use [`ag`](https://github.com/ggreer/the_silver_searcher)/[`fzf`](https://github.com/junegunn/fzf)/[`yq`](https://github.com/mikefarah/yq)/[`sqlite`](https://stackoverflow.com/a/24582022) directly with the CSV files
- [x] Allow multiple input CSVs
    - [x] Actually, don't do this. only allow one csv or one directory. this allows making the path argument optional, for operations that don't need a path argument, like `--migrate`
