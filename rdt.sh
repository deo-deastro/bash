#!/bin/bash

init_dir=$1

min_depth=$2
max_depth=$3

min_file_size=$4
max_file_size=$5

min_iter_num=$6
max_iter_num=$7

only=$8


get_rand_str () {
    min_len=${1-10}
    max_len=${2-100}
    rule=${3-a-zA-Z0-9}

    def_len=$(( ( RANDOM % ( max_len - min_len) ) + min_len ))

    echo $( head /dev/urandom | tr -dc $rule | head -c $def_len ) 
}

make_rand_dirs () {
    init_dir=$( realpath $1 )
    dir_num=$2
    name_min_len=$3
    name_max_len=$4
    name_rule=$5

    for (( i=0; i < $dir_num; i++ )); do
        name=$( get_rand_str $name_min_len $name_max_len $name_rule )
        mkdir "$init_dir/$name"
    done
}

make_rand_files () {
    init_dir=$( realpath $1 )
    file_num=$2
    name_min_len=$3
    name_max_len=$4
    name_rule=$5
    min_size=$6
    max_size=$7
    content_rule=$8

    for (( i=0; i < $file_num; i++ )); do
        name=$( get_rand_str $name_min_len $name_max_len $name_rule )
        content=$( get_rand_str $min_size $max_size $content_rule )
        echo $content >> "$init_dir/$name"
    done
}

iter_inside_dir () {
    init_dir=$( realpath $1 )
    iter_num=$2

    dir_num=$(( RANDOM % iter_num ))
    file_num=$(( iter_num - dir_num ))

    make_rand_dirs $init_dir $dir_num
    make_rand_files $init_dir $file_num
}

iter_inner_dirs () {
    init_dir=$( realpath $1 )
    iter_num=$2

    for dir in $init_dir/*/; do
        iter_inside_dir $dir
    done
}

create_branch () {
    init_dir=$1
}

get_rand_str
# iter_inside_dir 7 5

# create_rand_dirs . 4 4 8 0-9