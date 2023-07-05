#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
cat games.csv |  while IFS="," read YEAR ROUND WINN OPP WG OG #WG= winner_goals
do
  if [[ $WINN != "winner" || $OPP != "opponent" ]]
  then
    if [[ ! -z $WINN && $WINN != $OPP ]]
    then
      # Check if the winner exists in the teams table
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINN'")
      if [[ -z $WINNER_ID ]]
      then
        # Insert the winner into the teams table
        INSERT_WINN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINN')")
        if [[ $INSERT_WINN_RESULT == "INSERT 0 1" ]]
        then 
          echo Inserted into teams, $WINN
        fi
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINN'")
      fi
    fi

    if [[ ! -z $OPP && $OPP != $WINN ]]
    then
      # Check if the opponent exists in the teams table
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
      if [[ -z $OPPONENT_ID ]]
      then
        # Insert the opponent into the teams table
        INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
        if [[ $INSERT_OPP_RESULT == "INSERT 0 1" ]]
        then 
          echo Inserted into teams, $OPP
        fi
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
      fi
    fi

    # Insert the game into the games table if both winner and opponent have valid IDs
    if [[ ! -z $WINNER_ID && ! -z $OPPONENT_ID ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, '$WG', '$OG')")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $WINN vs $OPP match in $ROUND
      fi
    fi
  fi
done
