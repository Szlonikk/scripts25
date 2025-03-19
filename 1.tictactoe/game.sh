#!/bin/bash

SAVE_FILE="save.txt"

init_board() {
    for i in {0..8}; do
        board[$i]="-"
    done
}

display_board() {
    echo ""
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "-----------"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "-----------"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo ""
}

save_game() {
    rm -f "$SAVE_FILE"  
    echo "${board[@]}" > "$SAVE_FILE"
    echo "$turn" >> "$SAVE_FILE"
    echo "saved into: $SAVE_FILE."
}

load_game() {
    if [ -f "$SAVE_FILE" ]; then
        read -a board < "$SAVE_FILE"
        turn=$(sed -n '2p' "$SAVE_FILE")
        echo "Game loaded succesfully $SAVE_FILE."
    else
        echo "Save file is missing."
        exit 1
    fi
}

player_move() {
    while true; do
        echo "provide number (1-9) or provide 's' to save the game:"
        read input
        if [ "$input" == "s" ]; then
            save_game
            continue
        fi
        if ! [[ "$input" =~ ^[1-9]$ ]]; then
            echo "Wrong number! Try again."
            continue
        fi
        pos=$((input - 1))
        if [ "${board[$pos]}" != "-" ]; then
            echo "This spot is ocupied. Try again."
            continue
        fi
        board[$pos]="$turn"
        break
    done
}

computer_move() {
    echo "PC move:"
    available=()
    for i in {0..8}; do
        if [ "${board[$i]}" == "-" ]; then
            available+=($i)
        fi
    done
    if [ ${#available[@]} -gt 0 ]; then
        idx=$((RANDOM % ${#available[@]}))
        pos=${available[$idx]}
        board[$pos]="$turn"
        echo "Computer Choosed $((pos+1))."
    fi
}

check_win() {
    wins=( "0 1 2" "3 4 5" "6 7 8" "0 3 6" "1 4 7" "2 5 8" "0 4 8" "2 4 6" )
    for comb in "${wins[@]}"; do
        read a b c <<< "$comb"
        if [ "${board[$a]}" != "-" ] && [ "${board[$a]}" == "${board[$b]}" ] && [ "${board[$b]}" == "${board[$c]}" ]; then
            echo "${board[$a]}"
            return
        fi
    done
    echo ""
}
check_tie() {
    for i in {0..8}; do
        if [ "${board[$i]}" == "-" ]; then
            echo "false"
            return
        fi
    done
    echo "true"
}


echo "Tic Tac Toe!"
echo "Select option:"
echo "1. New game"
echo "2. Load saved game"
read option

if [ "$option" == "2" ]; then
    load_game
else
    init_board
    turn="X"  
fi

while true; do
    display_board
    winner=$(check_win)
    if [ "$winner" != "" ]; then
        display_board
        echo "Winner: $winner"
        break
    fi
  
    tie=$(check_tie)
    if [ "$tie" == "true" ]; then
        display_board
        echo "Draw!"
        break
    fi

  
    if [ "$turn" == "X" ]; then
        echo "Your turn (X):"
        player_move
        turn="O"
    else
        computer_move
        turn="X"
    fi
done
