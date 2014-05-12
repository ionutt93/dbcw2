#!/bin/sh
sudo su postgres -c 'psql -d dbcw2 -f create_tables.sql' 
sudo su postgres -c 'psql -d dbcw2 -f triggers.sql' 
sudo su postgres -c 'psql -d dbcw2 -f functions.sql' 
sudo su postgres -c 'psql -d dbcw2 -f inserts/sql/insert_users.rb.sql' 
sudo su postgres -c 'psql -d dbcw2 -f inserts/sql/insert_games.rb.sql' 
sudo su postgres -c 'psql -d dbcw2 -f inserts/sql/insert_gameOwn.rb.sql' 
