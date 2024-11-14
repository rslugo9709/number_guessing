#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guessing --tuples-only -c"


MAIN(){

  echo "Enter your username:"
  read USER_TO_FIND

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_TO_FIND'")

  N_GUESS=$((1 + $RANDOM % 1000))
  N=0
  ##User retrieval
  if [[ -z $USER_ID ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER_TO_FIND')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_TO_FIND'")

    echo -e "Welcome, $USER_TO_FIND! It looks like this is your first time here."

  else

    USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID")
    N_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
    N_GAMES_INFO_FORMATTED=$(echo $N_GAMES | sed 's/ |/"/')
    G_GAMES=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
    G_GAMES_INFO_FORMATTED=$(echo $G_GAMES | sed 's/ |/"/')

    echo -e "Welcome back, $USERNAME! You have played $N_GAMES_INFO_FORMATTED games, and your best game took $G_GAMES_INFO_FORMATTED guesses."

  fi
  echo "Guess the secret number between 1 and 1000:"
  read NUMBER
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read NUMBER  
  else
  
    while [[ $CORRECT != TRUE ]]
    do
    ((N++))

    if [[ $NUMBER < $N_GUESS ]]
    then 
      echo "It's higher than that, guess again:"
      read NUMBER
      while [[ $INCORRECT != FALSE ]]
      do
        if [[ ! $NUMBER =~ ^[0-9]+$ ]]
        then
          echo "That is not an integer, guess again:"
          read NUMBER
        else
        INCORRECT=FALSE
        fi
      done
    elif [[ $NUMBER > $N_GUESS ]]
    then
      echo "It's lower than that, guess again:"
      read NUMBER
      while [[ $INCORRECT != FALSE ]]
      do
        if [[ ! $NUMBER =~ ^[0-9]+$ ]]
        then
          echo "That is not an integer, guess again:"
          read NUMBER
        else
        INCORRECT=FALSE
        fi
      done
    else
      echo -e "You guessed it in $N tries. The secret number was $NUMBER. Nice job!"
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(guesses,user_id) VALUES($N,$USER_ID)")
      CORRECT=TRUE
    fi
    done
  fi


}

MAIN
