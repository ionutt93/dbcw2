#!/bin/sh
psql -d dbcw2 -f create_tables.sql 
psql -d dbcw2 -f triggers.sql 
psql -d dbcw2 -f functions.sql 
psql -d dbcw2 -f inserts/sql/insert_users.rb.sql 
psql -d dbcw2 -f inserts/sql/insert_games.rb.sql 
psql -d dbcw2 -f inserts/sql/insert_gameOwn.rb.sql 
psql -d dbcw2 -f inserts/sql/insert_ach.rb.sql 
psql -d dbcw2 -f inserts/sql/insert_gameAch.rb.sql 
