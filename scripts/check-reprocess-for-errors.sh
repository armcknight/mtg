#!/bin/sh

grep -i -e trap -e error -e disagree -e fatal reprocessed.log

if [ $? -ne 0 ]; then
    echo "No errors found."
    exit 0
else
    exit 1
fi

