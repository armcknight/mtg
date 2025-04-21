.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: reprocess
reprocess:
	./scripts/ensure-all-inputs-in-reprocess-script.sh
	./scripts/reprocess-all-inputs.sh --reprocess 2>&1 | tee reprocessed.log

.PHONY: analyze-decks
analyze-decks:
	./scripts/reprocess-all-inputs.sh --analyze-decks 2>&1 | tee deck-analysis.log

.PHONY: reprocess-and-analyze
reprocess-and-analyze:
	./scripts/ensure-all-inputs-in-reprocess-script.sh
	./scripts/reprocess-all-inputs.sh --reprocess --analyze-decks 2>&1 | tee reprocess-and-analyze.log

.PHONY: report-reprocess-errors
report-reprocess-errors:
	./scripts/check-reprocess-for-errors.sh

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

# example: make extract-card-names-from-csv COLLECTION_OR_DECK_CSV="collection/originals_from_tcgplayer/decks/transformers.txt"
.PHONY: extract-card-names-from-csv
extract-card-names-from-csv:
	@cat $(COLLECTION_OR_DECK_CSV) | yq -p csv '.[] | .Name' | sort

# example: make extract-card-names-from-mtgo MTGO_LIST="collection/originals_from_tcgplayer/decks/transformers.txt"
.PHONY: extract-card-names-from-mtgo
extract-card-names-from-mtgo:
	@cat $(MTGO_LIST) | sed -E 's/^[0-9]+ (.*) \(.*\) [0-9]+[a-z]? ?\*?F?\*?/\1/' | sort

# examples: I had a plst grn-120 entry, but there is no such card, so look for different plst cards that have one or the other parts to see if i merely misread/misentered part of it
#   - find-plist-cards-containing-collector-number-component COLLECTOR_NUMBER_COMPONENT=GRN
#   - find-plist-cards-containing-collector-number-component COLLECTOR_NUMBER_COMPONENT=120
.PHONY: find-plist-cards-containing-collector-number-component
find-plist-cards-containing-collector-number-component:
@cat $(SCRYFALL_DATA_DUMP_PATH) | jq '.[] | select(.set == "plst"))' | jq 'select(.collector_number | contains("$(COLLECTOR_NUMBER_COMPONENT)")) | ((.colors // .card_faces[0].colors) | join("")) + ", " + .rarity + ", " + .type_line + ", " + .name + ", " + .collector_number' | sed 's/Legendary //g' | sed 's/ — [^,]*,/,/g' | sort | grep uncommon
