#!/bin/bash

PSQL='psql -X -U freecodecamp -d salon --no-align --tuples-only -c'

echo -e "\n~~~~~ My Salon ~~~~~"

SELECT_SERVICE() {
  echo -e "\n$1"
  $PSQL "select service_id, name from services" | while IFS=$IFS+"|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    SELECT_SERVICE "I could not find that service. What would you like today?"
  fi
}

SELECT_SERVICE "Welcome to My Salon, how can I help you?"

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_INFO=$($PSQL "select customer_id, name from customers where phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_INFO ]]
then
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  $PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
else
  echo "$CUSTOMER_INFO" | sed -r "s/([0-9]+) \| (.*)/\1 \2/" | read CUSTOMER_ID CUSTOMER_NAME
fi

echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
read SERVICE_TIME
$PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
