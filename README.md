# mtg
Magical programs 🪄✨

A project to help manage my collection of Magic: the Gathering cards.

The collection is contained in multiple CSV files:

- base list of stored collection not currently in use
- a list for each constructed deck

# TODO

- [x] Ingest a CSV from the TCGPlayer iOS app containing scanned cards
- Given input CSV, perform any combination of operations:
    - [ ] base list
        - [x] appending
        - [ ] subtracting
    - [ ] constructed list
        - [ ] appending
        - [ ] subtracting
        - [ ] sideboards
- Incorporate information from other card info sources:
    - [ ] Scryfall (API and/or daily bulk data download)
- Accept inputs from other scanner apps:
    - [ ] tbd
- [ ] Card search through base and constructed lists
- [x] Allow multiple input CSVs
- [x] Handle folders of CSVs to process
- [x] Custom location of managed CSVs
