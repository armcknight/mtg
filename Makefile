.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: reprocess
reprocess:
	./ensure-all-inputs-in-reprocess-script.sh
	./reprocess-all-inputs.sh --reprocess 2>&1 | tee reprocessed.log

.PHONY: analyze-decks
analyze-decks:
	./ensure-all-inputs-in-reprocess-script.sh
	./reprocess-all-inputs.sh --analyze-decks 2>&1 | tee deck-analysis.log

.PHONY: reprocess-and-analyze
analyze-decks:
	./ensure-all-inputs-in-reprocess-script.sh
	./reprocess-all-inputs.sh --reprocess --analyze-decks 2>&1 | tee reprocess-and-analyze.log

.PHONY: report-reprocess-errors
report-reprocess-errors:
	./check-reprocess-for-errors.sh

.PHONY: accept-new-baseline
accept-new-baseline:
	mv reprocessed.log reprocessed_baseline.log

# handy things i've done in the past out of curiosity or specific needs

.PHONY: count-keywords
count-keywords:
	@cat $(SCRYFALL_DATA_DUMP_PATH) | jq '.[] | .keywords | .[]' | sort | uniq -c | sort

.PHONY: count-cards-per-set
count-cards-per-set:
	@cat $(SCRYFALL_DATA_DUMP_PATH) | jq '.[] | .set_name + " (" + .set + ")"' | sort | uniq -c

.PHONY: count-cards-per-rarity-per-set
count-cards-per-rarity-per-set:
	@jq '.[] | .set + " " + .rarity' $(SCRYFALL_DATA_DUMP_PATH) | sed 's/\"//g' | sort -t '\n' | uniq -c | awk -F ' ' '{print $$2 "/" $$3 ": " $$1}' | tree --fromfile

# example: make extract-card-names-from-csv COLLECTION_OR_DECK_CSV="collection/originals_from_tcgplayer/decks/upgraded\ fae\ dominion.txt"
.PHONY: extract-card-names-from-csv
extract-card-names-from-csv:
	@cat $(COLLECTION_OR_DECK_CSV) | yq -p csv '.[] | .Name' | sort

# example: make extract-card-names-from-mtgo MTGO_LIST="collection/originals_from_tcgplayer/decks/2024-08-28\ fae\ dominion\ \(fixed\).txt"
.PHONY: extract-card-names-from-mtgo
extract-card-names-from-mtgo:
	@cat $(MTGO_LIST) | sed -E 's/^[0-9]+ (.*) \(.*\) [0-9]+[a-z]? ?\*?F?\*?/\1/' | sort
