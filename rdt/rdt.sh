#!/bin/bash

DEFAULT_RAND_STR_RULE="a-zA-Z0-9"

DEFAULT_DEPTH_MIN=5
DEFAULT_DEPTH_MAX=5

DEFAULT_STR_MIN_LEN=5
DEFAULT_STR_MAX_LEN=10

DEFAULT_ITER_MIN_NUM=5
DEFAULT_ITER_MAX_NUM=10

DEFAULT_DIRNAME_MIN_LEN=5
DEFAULT_DIRNAME_MAX_LEN=10

DEFAULT_FILENAME_MIN_LEN=5
DEFAULT_FILENAME_MAX_LEN=10

DEFAULT_CONTENT_MIN_LEN=50
DEFAULT_CONTENT_MAX_LEN=500


get_rand_num () {
	local min=$1
	local max=$2

	if [[ $min -ne $max ]]; then
		local num=$(( ( RANDOM % ( max - min) ) + min ))
	else
		local num=$max
	fi

	echo $num
}

get_rand_str () {
	local min_len=${1-$DEFAULT_STR_MIN_LEN}
	local max_len=${2-$DEFAULT_STR_MAX_LEN}
	local rule=${3-$DEFAULT_RAND_STR_RULE}

	local def_len=$( get_rand_num $min_len $max_len )

	local str=$( < /dev/urandom tr -dc $rule | head -c $def_len )

	echo $str
}

make_rand_dirs () {
	local init_dir=$( realpath $1 )
	local dir_num=$2

	local name_min_len=${dirname_min_len-$DEFAULT_DIRNAME_MIN_LEN}
	local name_max_len=${dirname_max_len-$DEFAULT_DIRNAME_MAX_LEN}
	local name_rule=${dirname_rule-$DEFAULT_RULE}

	for (( i=0; i < $dir_num; i++ )); do
		name=$( get_rand_str $name_min_len $name_max_len $name_rule )
		mkdir "$init_dir/$name"
	done
}

make_rand_files () {
	local init_dir=$( realpath $1 )
	local file_num=$2

	local name_min_len=${filename_min_len-$DEFAULT_FILENAME_MIN_LEN}
	local name_max_len=${filename_max_len-$DEFAULT_FILENAME_MAX_LEN}
	local name_rule=${filename_rule-$DEFAULT_RULE}

	local min_size=${content_min_len-$DEFAULT_CONTENT_MIN_LEN}
	local max_size=${content_max_len-$DEFAULT_CONTENT_MAX_LEN}
	local content_rule=${content_rule-$DEFAULT_RULE}

	for (( i=0; i < $file_num; i++ )); do
		name=$( get_rand_str $name_min_len $name_max_len $name_rule )
		content=$( get_rand_str $min_size $max_size $content_rule )
		echo $content >> "$init_dir/$name.txt"
	done
}

iter_inside_dir () {
	local init_dir=$( realpath $1 )

	local min_num=${iter_min_num-$DEFAULT_ITER_MIN_NUM} 
	local max_num=${iter_max_num-$DEFAULT_ITER_MAX_NUM}

	local def_iter_num=$( get_rand_num $min_num $max_num )
	local def_dir_num=$(( RANDOM % def_iter_num ))
	local def_file_num=$(( def_iter_num - def_dir_num ))

	make_rand_dirs $init_dir $def_dir_num
	make_rand_files $init_dir $def_file_num
}

generate_tree () {
	local depth_min=${depth_min-$DEFAULT_DEPTH_MIN}
	local depth_max=${depth_max-$DEFAULT_DEPTH_MAX}
	local def_depth=$( get_rand_num $depth_min $depth_max )

	echo $def_depth

	mkdir $init_dir

	iter_inside_dir $init_dir

	current_depth=0
	current_layer=$init_dir
	while [[ $current_depth -lt $def_depth ]]; do
		for dir in $current_layer/*/; do
			iter_inside_dir $dir
		done

		current_depth=$(( current_depth + 1 ))
		current_layer="$current_layer/*"
	done
}

parse_args () {
	while (( $# > 0 )); do
    case $1 in
      -dpf ) depth_min=$2;                                     shift 2;; 
			-dps ) depth_max=$2;                                     shift 2;;
			-if )  iter_min_num=$2;                                  shift 2;;
			-is )  iter_min_num=$2;                                  shift 2;;
			-df )  dirname_min_len=$2;                               shift 2;;
			-ds )  dirname_max_len=$2;                               shift 2;;
			-ff )  filename_min_len=$2;                              shift 2;;
			-fs )  filename_max_len=$2;                              shift 2;;
			-cf )  content_min_len=$2;                               shift 2;;
			-cs )  content_max_len=$2;                               shift 2;;
			-dr )  dirname_rule=$2;                                  shift 2;;
			-fr )  filename_rule=$2;                                 shift 2;;
			-cr )  content_rule=$2;                                  shift 2;;

			-h | --help ) show_help;                                 shift;;

			-d ) depth_min=$2; depth_max=$2;                         shift 2;;
			-i ) iter_min_num=$2; iter_max_num=$2;                   shift 2;;
			-c ) content_min_len=1; content_max_len=$2;              shift 2;;
			-r ) dirname_rule=$2; filename_rule=$2; content_rule=$2; shift 2;;

			* ) init_dir=$( realpath $1 );                           shift;;
    esac
  done
}

show_help () {
	printf "
Usage: $(basename $0) [OPTIONS] DIRECTORY

Options:											    
  -h, --help  Show help text							

  -dpf        Set minimal nesting depth				    
  -dps        Set maximal nesting depth				    
  -if         Set minimum iterations for each directory 
  -is         Set maximum iterations for each directory 
  -df         Set directory minimal name length		    
  -ds         Set directory maximal name length		    
  -ff         Set file minimal name length			    
  -fs         Set file maximal name length			    
  -cf         Set content minumal length				
  -cs         Set content maximal length				
  -dr         Set directory naming rule				    
  -fr         Set file naming rule					    
  -cr         Set content naming rule					

  -d          Set depth as constant					    
  -i          Set number of iterations as constant	    
  -c          Set content length as constant			
  -r          Set the same naming rule for everything
	"
	echo ""
}

######################################_EX_#####################################

parse_args $@

if [[ $init_dir ]]; then
	generate_tree $init_dir
fi