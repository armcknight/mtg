#!/bin/bash

# Directory to check files from
PWD=`pwd`
COLLECTION_DIR="$PWD/collection"
directory="$COLLECTION_DIR/originals_from_tcgplayer/decks"

# File to grep filenames in
file_to_check="scripts/reprocess-all-inputs.sh"

exit_status=0

# Loop over each file in the directory
for file in "$directory"/*; do
  filename=$(basename "$file")

  # Check if the filename is present in the file_to_check
  if ! grep -q "$filename" "$file_to_check"; then
    echo "Input file not added to reprocess script: $filename"
    exit_status=1
  fi
done

exit $exit_status
