#!/bin/sh

sleep 10

if [ -e /src/.db-boostrapped ]; then
  echo "Database Already Bootstrapped!"
  exit 0
fi

OLD_PGPASSWORD=$PGPASSWORD

# CREATE USER
echo "Creating user ... "
psql -h $POSTGRES_HOST -U $POSTGRES_USER -d postgres -c "CREATE USER ${POSTGRES_APP_USER} CREATEDB CREATEROLE LOGIN PASSWORD '${POSTGRES_APP_PASSWORD}'"

export PGPASSWORD=$POSTGRES_APP_PASSWORD

echo "Creating database ... "
psql -h $POSTGRES_HOST -U $POSTGRES_APP_USER -d postgres -c "CREATE DATABASE ${POSTGRES_APP_DATABASE}"

if [ -e /src/init.sql ]; then
  export PGPASSWORD=$OLD_PGPASSWORD
  echo "Init.sql found, executing ..."
  psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_APP_DATABASE -f /src/init.sql
fi

if [ -e /src/init-onprem.sql ]; then
  export PGPASSWORD=$OLD_PGPASSWORD
  echo "init-onprem.sql found, executing ..."
  psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_APP_DATABASE -f /src/init-onprem.sql
fi

export PGPASSWORD=$POSTGRES_APP_PASSWORD

echo "Executing Sqitch ... "
sqitch --engine pg deploy db:pg://$POSTGRES_APP_USER@$POSTGRES_HOST:5432/$POSTGRES_APP_DATABASE
