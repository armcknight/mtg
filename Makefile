.PHONY: reprocess
reprocess:
	./reprocess-all-inputs.sh /Users/andrewmcknight/Downloads/scryfall-bulk-data/default-cards-20240205220704.json | tee reprocessed.log
