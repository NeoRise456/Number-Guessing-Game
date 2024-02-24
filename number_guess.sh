#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

random_number=$((1 + RANDOM % 1000))
total_game_guesses=0


echo -e "Enter your username:"
read game_user

VERIFY_USER=$($PSQL "SELECT user_id FROM users WHERE username='$game_user' ")
if [[ -z $VERIFY_USER ]]
then
  #new user
  echo -e "Welcome, $game_user! It looks like this is your first time here.\n"
  CREATE_NEW_USER=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$game_user',0,0);")

else
  #old user
  GAMES_USER_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$VERIFY_USER")
  USER_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$VERIFY_USER")
  echo "Welcome back, $game_user! You have played $GAMES_USER_PLAYED games, and your best game took $USER_BEST_GAME guesses."
fi

#game
echo -e "Guess the secret number between 1 and 1000:"
while true; do
  total_game_guesses=$((total_game_guesses+1))
  echo "es $random_number xdd"
  read number_guess

  if [[ $number_guess =~ ^[0-9]+$ ]]
  then
    if [ "$number_guess" -eq "$random_number" ]; then
      echo 
      break
    else
      if [ "$number_guess" -lt "$random_number" ]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    fi

  else
    echo "That is not an integer, guess again:"
  fi
done

#stats
GET_USERID=$($PSQL "SELECT user_id FROM users WHERE username='$game_user' ")
#add one game played

GAMES_USER_PLAYED=$((GAMES_USER_PLAYED+1))
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played=$GAMES_USER_PLAYED WHERE user_id=$GET_USERID;")

#verify if this is best game
USER_BEST_GAME_UPDATE=$($PSQL "SELECT best_game FROM users WHERE user_id=$GET_USERID")
if [ "$total_game_guesses" -eq "$USER_BEST_GAME_UPDATE" ]; 
then
  echo "SAME BEST: $USER_BEST_GAME_UPDATE"
else
  if [ "$total_game_guesses" -lt "$USER_BEST_GAME_UPDATE" ] || [ "$USER_BEST_GAME_UPDATE" -eq 0 ]
  then
    echo "NEW BEST: $total_game_guesses"
    UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$total_game_guesses WHERE user_id=$GET_USERID;")
  else
    echo "PLAYER BEST: $USER_BEST_GAME_UPDATE"
  fi
fi



#goodbye line
echo You guessed it in $total_game_guesses tries.The secret number was $random_number. Nice job!