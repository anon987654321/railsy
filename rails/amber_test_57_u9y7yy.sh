#!/usr/bin/env zsh

# Run this script to test the Amber app

echo "Starting test script for Amber app"

# -- SET UP TEST DATABASE --

bin/rails db:environment:set RAILS_ENV=test
bin/rails db:create RAILS_ENV=test
bin/rails db:schema:load RAILS_ENV=test

# -- RUN TESTS --

bundle exec rspec

# -- ADDITIONAL CHECKS --

# Check if PostgreSQL is running
if doas -u _postgresql pg_ctl status -D /var/postgresql/data &>/dev/null; then
  echo "PostgreSQL is running"
else
  echo "PostgreSQL is not running"
  exit 1
fi

# Check if Redis is running
if pgrep redis-server &>/dev/null; then
  echo "Redis is running"
else
  echo "Redis is not running"
  exit 1
fi

# Check if Falcon is running
if pgrep falcon &>/dev/null; then
  echo "Falcon is running"
else
  echo "Falcon is not running"
  exit 1
fi

# -- CLEAN UP --

# Remove test database
bin/rails db:drop RAILS_ENV=test

echo "Test script completed successfully"
