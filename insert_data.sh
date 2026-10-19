#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

if [[ $1 != "test" ]]
then
  psql --username=postgres --dbname=postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'worldcup'" | grep -q 1 || psql --username=postgres --dbname=postgres -c "CREATE DATABASE worldcup"
fi

$PSQL "DROP TABLE IF EXISTS games, teams"
$PSQL "CREATE TABLE teams(team_id SERIAL PRIMARY KEY, name VARCHAR(50) UNIQUE NOT NULL)"
$PSQL "CREATE TABLE games(game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR(50) NOT NULL, winner_id INT NOT NULL REFERENCES teams(team_id), opponent_id INT NOT NULL REFERENCES teams(team_id), winner_goals INT NOT NULL, opponent_goals INT NOT NULL)"

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING"
    $PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING"
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)"
  fi
done < games.csv
