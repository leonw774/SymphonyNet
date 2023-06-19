test_pathlist=$1
sample_number=$(wc -l < $test_pathlist)
checkpoint_path=$2
start_time=$SECONDS
log_path=$(date '+%Y%m%d-%H%M%S')-generate_uncond.log
python generate_uncond.py -n $sample_number -m 0 -l 4096 -o "generated/uncond" -c $checkpoint_path | tee -a $log_path
duration=$(( $SECONDS - start_time ))
echo "Generation takes $duration seconds" | tee -a $log_path
