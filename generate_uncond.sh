test_pathlist=$1
sample_number=$(wc -l < $test_pathlist)
start_time=$SECONDS
python generate_uncond.py -n $sample_number -m 0 -l 4096 -o "generated/uncond"
duration=$(( $SECONDS - start_time ))
