#!/bin/bash

OUTPUT=inserts.sql
echo "" > $OUTPUT
mkdir sql
for f in *.rb
do
    ruby $f > sql/$f.sql
    #echo ";" >> $OUTPUT
done
