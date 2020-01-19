#!/bin/bash

get_random_string() {
    min_len=${1-10}
    max_len=${2-100}
    rule=${3-a-zA-Z0-9}

    def_len=$(( ( RANDOM % ( max_len - min_len) ) + min_len ))

    echo $( head /dev/urandom | tr -dc $rule | head -c $def_len )
}