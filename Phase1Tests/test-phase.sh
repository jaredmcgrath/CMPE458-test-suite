#!/bin/bash
# Created by Jared McGrath for CMPE 458 Group N
echo "Testing Start - PHASE 1"

# Colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set default env val
out_dir="p1_out"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -L|--lib)
    pt_lib_path="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Determine path to lib/pt, if not supplied in args
if [ -z ${pt_lib_path+x} ]; then
	pt_lib_path="../../src/lib/pt"
fi

# Make sure the output directory exists
if [ ! -d "$out_dir" ]; then
  mkdir $out_dir
fi

for i in *.pt
do
  # Output file path
  out_file_path="$out_dir/$i.eOutput"
  # First, run ptc alone and send output to outfile (overwrite any existing)
  ptc -o1 -t1 -L $pt_lib_path $i > $out_file_path
  # Next, append the marker to seperate ptc output from ssltrace output
  echo '### END OF PTC OUTPUT ###' >> $out_file_path
  # Finally, run ssltrace
	ssltrace "ptc -o1 -t1 -L $pt_lib_path $i" $pt_lib_path/scan.def -e >> $out_file_path
	diff -b "$i.eOutput" $out_file_path > $out_dir/$i.eOutputDiff
done
cd $out_dir
all_passed="true"
for i in *.eOutputDiff
do
  # List output diff file name
	printf "$BLUE$i$NC\n"
  # If output diff has non-zero size, must be a diff
  if [ -s $i ]; then
    all_passed="false"
    printf "$RED TEST FAILED$NC - difference between expected and actual\n"
    cat $i
  else
    printf "$GREEN TEST PASSED$NC - no diff\n"
  fi
  echo ""
done

if [ $all_passed = "true" ]; then
  printf "$GREEN ALL TESTS PASSED$NC\n"
else
  printf "$RED SOME TESTS FAILED$NC\n"
fi
