#!/bin/bash

OUTPUT=inserts.sql
echo "" > $OUTPUT
for f in *.rb
do
    ruby $f >> $OUTPUT
    echo ";" >> $OUTPUT
done
