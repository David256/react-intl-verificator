#!/bin/bash

# react-intl-verificator:
# verifiy the status of the using of the react-intl module in the code.
#
# Copyright (C) 2022 David Waster

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Go the components directory
cd src
cd components

function count_files() {
    EXTENSION=$1
    if [ -z $EXTENSION ]
    then
    echo "USAGE: count_files <extension>"
    exit 1
    fi

    AMOUNT=$(find . -name "*.$EXTENSION" | wc -l)
    echo $AMOUNT
}

function count_files_with_intl() {
    EXTENSION=$1
    YES_OR_NOT=$2

    if [ -z $YES_OR_NOT ] || [ -z $EXTENSION ]
    then
    echo "USAGE: count_files_with_intl <extension> <yes|no>"
    exit 1
    fi

    case $YES_OR_NOT in
    yes | not)
    ;;
    *)
    echo "ERROR: second parameter should be 'yes' or 'not', not '$YES_OR_NOT'"
    exit 1
    ;;
    esac
    AMOUNT=$(find . -name "*.$EXTENSION" | xargs -I FILE bash -c 'cat FILE | grep "react-intl" > /dev/null && echo yes || echo not ' | grep "$YES_OR_NOT" | wc -l)
    echo $AMOUNT
}

function prepare_stat() {
    # Delete last buffer data
    [ -f /tmp/buffer ] && rm /tmp/buffer > /dev/null

    printf "+-----------+-------+-----+-----+\n" >> /tmp/buffer
    printf "| %s | %s | %s | %s |\n" "extension" "total" "yes" "not" >> /tmp/buffer
    printf "| --------- | ----- | --- | --- |\n" >> /tmp/buffer
    for EXTENSION in js jsx ts tsx
    do
    COUNT_TOTAL=$(count_files $EXTENSION)
    COUNT_YES=$(count_files_with_intl $EXTENSION yes)
    COUNT_NOT=$(count_files_with_intl $EXTENSION not)
    printf "| %9s | %5s | %3s | %3s |\n" $EXTENSION $COUNT_TOTAL $COUNT_YES $COUNT_NOT >> /tmp/buffer
    done
    printf "+-----------+-------+-----+-----+\n" >> /tmp/buffer

    # cat /tmp/buffer
}

function main_loop() {
    prepare_stat
    clear
    cat /tmp/buffer
    sleep 4
    main_loop
}

tput smcup
clear
echo "processing..."
trap "tput rmcup; echo bye; exit" 2
main_loop
