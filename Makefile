.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: reprocess
reprocess:
	./reprocess-all-inputs.sh /Users/andrewmcknight/Downloads/scryfall-bulk-data/default-cards-20240205220704.json | tee reprocessed.log

.PHONY: accept-new-baseline
accept-new-baseline:
	mv reprocessed.log reprocessed_baseline.log

