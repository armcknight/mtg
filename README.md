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

# TODO

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
    - [ ] Scryfall (fromAPI and/or daily bulk data download)
- Accept inputs from other scanner apps:
    - [ ] collectr
    - [ ] dragon shield mtg scanner
    - [ ] tcgfish
    - [ ] card binder
    - [ ] card castle 
    - et al tbd
- ~[ ] Card search through base and constructed lists~ WONTDO: use `ag`/`fzf`/`yq`/`sqlite` directly with the CSV files
- [x] Allow multiple input CSVs
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
