#!/bin/bash

tmux new-session -d watch -td kubectl get all
tmux splitw -v bash
tmux resizep -y 20%
tmux selectp -t 0
tmux splitw -h watch -td "echo '--- PV ---';kubectl get pv"
tmux splitw -v watch -td "echo '--- PVC ---';kubectl get pvc -A"
tmux resizep -y 50%
tmux selectp -t 3
tmux attach