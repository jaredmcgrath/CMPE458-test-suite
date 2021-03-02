#!/bin/bash
# Created by Jared McGrath for CMPE 458 Group N
echo "Generating expected test output - PHASE 2"

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

for i in *.pt
do
  echo "Generating output for $i"
  ./test-single.sh -L $pt_lib_path -f $i -s yes -c no -q
done
