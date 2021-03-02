#!/bin/bash
# Created by Jared McGrath for CMPE 458 Group N
echo "Testing Single - PHASE 2"

# Set default env val
quiet="no"
out_dir="p2_out"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--file)
    src_path="$2"
    shift # past argument
    shift # past value
    ;;
    -L|--lib)
    pt_lib_path="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--save)
    save_output_in_dir="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--compare)
    compare_output="$2"
    shift # past argument
    shift # past value
    ;;
    -q|--quiet)
    quiet="yes"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Get the user's test file name, if not supplied in args
if [ -z ${src_path+x} ]; then
  read -p "Enter name of test program to run: " src_path
fi

# Determine path to lib/pt, if not supplied in args
if [ -z ${pt_lib_path+x} ]; then
	pt_lib_path="../../src/lib/pt"
fi

# Make sure the output directory exists
if [ ! -d "$out_dir" ]; then
  mkdir $out_dir
fi

# Output file path
out_file_path="$out_dir/$src_path.eOutput"
# First, run ptc alone and send output to outfile (overwrite any existing)
ptc -o2 -t2 -L $pt_lib_path $src_path > $out_file_path
# Next, append the marker to seperate ptc output from ssltrace output
echo '### END OF PTC OUTPUT ###' >> $out_file_path
# Finally, run ssltrace
ssltrace "ptc -o2 -t2 -L $pt_lib_path $src_path" $pt_lib_path/parser.def -e >> $out_file_path

if [ $quiet = "no" ]; then
  echo ""
  echo "Output:"
  cat $out_file_path
  echo ""
fi

# See if user wants to save the eOutput, if not supplied in args
if [ -z ${save_output_in_dir+x} ]; then
  save_output_in_dir="yes"
  read -p "Save output in $src_path.eOutput? ([Y]/n) " user_response
  case "$user_response" in
    n|N ) echo "  --> Won't save expected output"; echo ""; save_output_in_dir="no";;
    * ) echo "  --> Will save expected output"; echo "";;
  esac
fi
if [ $save_output_in_dir = "yes" ]; then
  cp $out_file_path "$src_path.eOutput"
fi

# See if user wants to compare generated output to eOutput, if not supplied in args
output_diff_path="$out_dir/$src_path.eOutputDiff"
if [ -z ${compare_output+x} ]; then
  compare_output="yes"
  read -p "Compare output to existing $src_path.eOutput? ([Y]/n) " user_response
  case "$user_response" in
    n|N ) echo "  --> Won't compare to expected output"; echo ""; compare_output="no";;
    * ) echo "  --> Comparing expected output:"; echo "";;
  esac
fi

if [ $compare_output = "yes" ]; then
  diff -b "$src_path.eOutput" $out_file_path > $output_diff_path
	echo $src_path
  # If output diff has non-zero size, must be a diff
  if [ -s "$out_dir/$src_path.eOutputDiff" ]; then
    echo "TEST FAILED - difference between expected and actual"
    echo "See $output_diff_path for diff"
    read -p "View diff now? ([Y]/n) " user_response
    case "$user_response" in
      n|N ) echo "  --> Won't show diff"; echo "";;
      * ) cat $output_diff_path;;
    esac
  else
    echo "TEST PASSED - no diff"
  fi
fi
