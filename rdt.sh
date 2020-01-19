#!/bin/bash


DEFAULT_RULE="a-zA-Z0-9"


init_dir=$( realpath $1 )

min_depth=$2
max_depth=${3-5}

min_file_size=$4
max_file_size=$5

min_iter_num=$6
max_iter_num=$7

only=$8


get_rand_str () {
    min_len=${1-10}
    max_len=${2-100}
    rule=${3-$DEFAULT_RULE}

    def_len=$(( ( RANDOM % ( max_len - min_len) ) + min_len ))

    echo $( head /dev/urandom | tr -dc $rule | head -c $def_len ) 
}

make_rand_dirs () {
    init_dir=$( realpath $1 )
    dir_num=${2-5}
    name_min_len=${3-5}
    name_max_len=${4-10}
    name_rule=${5-$DEFAULT_RULE$}

    for (( i=0; i < $dir_num; i++ )); do
        name=$( get_rand_str $name_min_len $name_max_len $name_rule )
        mkdir "$init_dir/$name"
    done
}

make_rand_files () {
    init_dir=$( realpath $1 )
    file_num=${2-5}
    name_min_len=${3-5}
    name_max_len=${4-10}
    name_rule=${5-$DEFAULT_RULE}
    min_size=${6-50}
    max_size=${7-100}
    content_rule=${8-$DEFAULT_RULE}

    for (( i=0; i < $file_num; i++ )); do
        name=$( get_rand_str $name_min_len $name_max_len $name_rule )
        content=$( get_rand_str $min_size $max_size $content_rule )
        echo $content >> "$init_dir/$name.txt"
    done
}

iter_inside_dir () {
    init_dir=$( realpath $1 )
    iter_num=${2-5}

    dir_num=$(( RANDOM % iter_num ))
    file_num=$(( iter_num - dir_num ))

    make_rand_dirs $init_dir $dir_num
    make_rand_files $init_dir $file_num
}


rm -rf $init_dir

mkdir $init_dir

iter_inside_dir $init_dir

current_depth=0
current_layer=$init_dir
while [[ $current_depth -lt $max_depth ]]; do
    for dir in $current_layer/*/; do
        iter_inside_dir $dir
    done

    current_depth=$(( current_depth + 1 ))
    current_layer="$current_layer/*"
done
