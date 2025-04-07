#!/bin/bash

# Function to get card collector numbers
get_card_collector_numbers() {
    local file_path="$1"
    local scryfall_bulk_data_path="$2"

    # Read card names from the file
    while IFS= read -r card_name || [ -n "$card_name" ]; do
        # Use jq to find the collector number for each card name
        query_string=".[] | select((.name | ascii_downcase) == (\"$card_name\" | ascii_downcase)) | {collector_number, set}"
        card_info=$(jq -r "$query_string" "$scryfall_bulk_data_path")
        collector_number=$(echo "$card_info" | jq -r 'select(.set == "plst") | .collector_number')
        set_code=$(echo "$card_info" | jq -r '.set')
        
        if echo "$set_code" | grep -q "plst"; then
            if [ -n "$collector_number" ]; then
                echo "1 $card_name (plst) $collector_number"
            else
                echo "Card: $card_name, Collector Number: Not found" >&2
            fi
        else
            echo "Card: $card_name, Set Code 'plst' Not found" >&2
        fi
    done < "$file_path"
}

# Example usage
file_path="$1"
scryfall_bulk_data_path="$2"
get_card_collector_numbers "$file_path" "$scryfall_bulk_data_path"

