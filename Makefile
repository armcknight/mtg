.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: reprocess
reprocess:
	./ensure-all-inputs-in-reprocess-script.sh
	./reprocess-all-inputs.sh 2>&1 | tee reprocessed.log

.PHONY: report-reprocess-errors
report-reprocess-errors:
	./check-reprocess-for-errors.sh

.PHONY: accept-new-baseline
accept-new-baseline:
	mv reprocessed.log reprocessed_baseline.log

