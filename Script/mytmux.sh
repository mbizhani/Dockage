#!/bin/bash

tmux_command="tmux new-session -d"

if [ "$1" ]; then
  tmux_command+=" $1"

  for cmd in "${@:2}"; do
    tmux_command+=" \; split-window $cmd"
  done
else
  tmux_command+=" bash"
fi

tmux_command+="\; attach \; select-layout even-vertical"

eval "$tmux_command"
