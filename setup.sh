#!/bin/sh
psql -d ioan -f create_tables.sql 
psql -d ioan -f triggers.sql 
psql -d ioan -f functions.sql 
psql -d ioan -f inserts/sql/insert_users.rb.sql 
psql -d ioan -f inserts/sql/insert_games.rb.sql 
psql -d ioan -f inserts/sql/insert_gameOwn.rb.sql 
psql -d ioan -f inserts/sql/insert_ach.rb.sl
psql -d ioan -f inserts/sql/insert_gameAch.rb.sql
psql -d ioan -f inserts/sql/insert_gameOwnAch.rb.sql
