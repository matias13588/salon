#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON ~~~~~\n"

MAIN_MENU() {
    # get services
    AVAILABLE_SERVICES=$($PSQL "
        SELECT * FROM services
        ORDER BY service_id
    ")

    # display services and menu
    echo -e "\nWelcome, please select the service you would like to book:\n"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED

    # if selection is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        # repeat menu
        MAIN_MENU "That is not a valid service."
    else
        # ask customer phone
        echo -e "\nPlease enter your phone number:"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "
            SELECT name FROM customers
            WHERE phone = '$CUSTOMER_PHONE'
        ")

        # if not registered
        if [[ -z $CUSTOMER_NAME ]]
        then
            # ask name
            echo -e "\nPlease enter your name:"
            read CUSTOMER_NAME 

            # save new customer
            INSERT_NEW_CUSTOMER=$($PSQL "
                INSERT INTO customers(name, phone)
                VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')
            ")
        fi

        # ask for time
        echo -e "\nPlease enter a time for the appointment:"
        read SERVICE_TIME

        # get customer id
        CUSTOMER_ID=$($PSQL "
            SELECT customer_id FROM customers
            WHERE phone = '$CUSTOMER_PHONE'
        ")

        # save appointment
        INSERT_BOOKING_RESULT=$($PSQL "
            INSERT INTO appointments(customer_id, service_id, time)
            VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
        ")

        # get service name
        SERVICE_NAME=$($PSQL "
            SELECT name FROM services
            WHERE service_id = $SERVICE_ID_SELECTED
        ")

        # inform customer with message
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
}

MAIN_MENU