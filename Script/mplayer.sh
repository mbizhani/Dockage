#!/bin/bash

# declare -A =( ["pop"]="" ["next"]="" ["prev"]="" )
declare -A PLAYERCTL=( ["pop"]="playerctl play-pause" ["next"]="playerctl next" ["prev"]="playerctl previous" )
declare -A PAROLE=( ["pop"]="parole -p" ["next"]="parole -N" ["prev"]="parole -P" )
declare -A SMPLAYER=( ["pop"]="smplayer -send-action pause" ["next"]="smplayer -send-action play_next" ["prev"]="smplayer -send-action play_prev" )

FIRST='smplayer'
SECOND='parole'

if [ "$(command -v playerctl)" ]; then
  PLAYER='playerctl'
elif [ "$(pgrep $FIRST)" ]; then
  PLAYER=$FIRST
elif [ "$(pgrep $SECOND)" ]; then
  PLAYER=$SECOND
else
  PLAYER=$FIRST
fi

echo "$PLAYER - action = $1"

case $PLAYER in
  'parole')
    eval "${PAROLE[$1]}"
  ;;

  'smplayer')
    eval "${SMPLAYER[$1]}"
  ;;

  'playerctl')
    eval "${PLAYERCTL[$1]}"
  ;;
esac
