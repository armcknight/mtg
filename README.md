# mtg
Magical programs 🪄✨ A project to help manage my collection of Magic: the Gathering cards.

There are many great scanner and collection management apps out there (so far I've scanned ~1500 cards with TCGPlayer's iOS app, so I started with that format). I created this so that I can fully own the data about my cards without having to create an account with a service that may disappear or change business models at any time (the closest to my ideal that I've seen so far is Lion's Eye that stores data in iCloud). Usually, there is some specific functionality that may exist in one but not another. Here, I can create any functionality I think of.

# Details

The collection is contained in multiple CSV files:

- base list of stored collection not currently in use
- a list for each constructed deck

These are stored at the selected managed location as follows:
```
.
├── collection.csv
└── decks
    ├── fae dominion.csv
    └── sliver swarm.cs
```

# Features/TODO

- [x] Ingest a CSV from the TCGPlayer iOS app containing scanned cards
- Given input CSV, perform any combination of operations:
    - [ ] base list
        - [x] appending
        - [ ] subtracting
    - [ ] constructed deck
        - [ ] Change to keeping decks tracked in the one collection.csv with a new column for "Deck name"?
        - [x] appending
        - [ ] subtracting
        - sideboards
            - [ ] appending
            - [ ] subtracting
    - [ ] moving cards from one list to another (which is really just subtracting from one and appending to another)
- Incorporate information from other card info sources:
    - [x] Scryfall API 
    - [x] Scryfall bulk data download
        - [ ] automate downloading bulk data dumps
        - [ ] migrations should update scryfall data that is out of date in the managed collection after a new bulk data download
        - [ ] put it behind a local HTTP server so it doesn't have to be decoded on every invocation of the CLI
- Accept inputs from other scanner apps:
    - [ ] collectr
    - [ ] dragon shield mtg scanner
    - [ ] tcgfish
    - [ ] card binder
    - [ ] card castle 
    - [ ] moxfield exports, e.g.
        ```
        1 Alela, Cunning Conqueror (WOC) 3 *F*
        1 Arcane Denial (WOC) 84
        ```
    - et al tbd
- ~[ ] Card search through base and constructed lists~ WONTDO: use [`ag`](https://github.com/ggreer/the_silver_searcher)/[`fzf`](https://github.com/junegunn/fzf)/[`yq`](https://github.com/mikefarah/yq)/[`sqlite`](https://stackoverflow.com/a/24582022) directly with the CSV files
- [x] Allow multiple input CSVs
    - [x] Actually, don't do this. only allow one csv or one directory. this allows making the path argument optional, for operations that don't need a path argument, like `--migrate`
- [x] Handle folders of CSVs to process
- [x] Custom location of managed CSVs
- [ ] Export to CSV formats for other services/apps:
    - [ ] lion's eye iOS app
    - [ ] moxfield
    - [ ] archidekt
    - [ ] mtggoldfish
    - [ ] mtgdecks
    - [ ] edhrec
    - [ ] deckbox
    - [ ] tappedout
    - et al tbd 
- [ ] Track history of deck edits
- [ ] Deck retirement: move the cards back into collection, but keep the deck list in a separate area that can be excluded from the rest of searches, like in `/decks/retired/<deck-name>.csv`
- [x] Consolidate counts of duplicate entries (happens if you get the same card again later and scan it again)
    - [x] fix this, it only consolidates the current input, but needs to include previously recorded cards
- [ ] Given a deck list, determine which cards are already owned in the collection and other decks
- [ ] Sort the rows in the CSV files by card name
