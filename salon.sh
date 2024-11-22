#! /bin/bash
# database connection
PSQL="psql -X --username=freecodecamp --dbname=salon --pset=format=unaligned --tuples-only -c"
AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  echo "$AVAILABLE_SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo -e "\nPlease took a service"
  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "\nThis is not a number. Please input a service"
  else
    # check id
    CHOOSEN_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $CHOOSEN_SERVICE ]]
    then
      # id not exists
      MAIN_MENU "This service doesn't exists"

    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      SELECTED_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      if [[ -z $SELECTED_CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      echo -e "\nWhat's your appointment?"
      read SERVICE_TIME

      if [[ -z $SERVICE_TIME ]]
      then
        MAIN_MENU "Appointment not provided."
      fi

      # new appointment
      SELECTED_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, '$SERVICE_ID_SELECTED')")

      SERVICE_CHOOSEN=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

      echo -e "\nI have put you down for a $SERVICE_CHOOSEN at $SERVICE_TIME, $CUSTOMER_NAME."
      exit 0
    fi
  fi
}
MAIN_MENU
