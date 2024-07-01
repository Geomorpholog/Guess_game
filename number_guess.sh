#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
WELCOME(){
echo $1
read USERNAME_INPUT
USERNAME=$($PSQL"SELECT username FROM users WHERE username='$USERNAME_INPUT'")
if [[ -z $USERNAME ]]
then 
USERNAME_INPUT_RESULT=$($PSQL"INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
USERNAME=$($PSQL"SELECT username FROM users WHERE username='$USERNAME_INPUT'")
USER_ID=$($PSQL"SELECT user_id FROM users WHERE username='$USERNAME';")
echo "Welcome, $USERNAME! It looks like this is your first time here."

else 
USERNAME=$($PSQL"SELECT username FROM users WHERE username='$USERNAME_INPUT'")
USER_ID=$($PSQL"SELECT user_id FROM users WHERE username='$USERNAME';")
GAMES_PLAYED=$($PSQL"SELECT COUNT(*) FROM games WHERE user_id=$USER_ID GROUP BY user_id;")
BEST_GAME=$($PSQL"SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
NUMBER_OF_GUESSES=0
SECRET_NUMBER=$(($RANDOM%1000 + 1))
}
GAME(){
echo $1
read INPUT_NUMBER
if  [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
then
GAME "That is not an integer, guess again:"
elif [[ $INPUT_NUMBER > $SECRET_NUMBER ]]
then
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
GAME "It's higher than that, guess again:"
elif [[ $INPUT_NUMBER < $SECRET_NUMBER ]]
then
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
GAME "It's lower than that, guess again:"
elif [[ $INPUT_NUMBER = $SECRET_NUMBER ]]
then
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!
INSERT_GAME_RESULT=$($PSQL"INSERT INTO games(user_id,number_of_guesses) VALUES($USER_ID,$NUMBER_OF_GUESSES);")
fi
}
WELCOME "Enter your username:"
GAME "Guess the secret number between 1 and 1000:"