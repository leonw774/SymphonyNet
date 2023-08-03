test_pathlist=$1
sample_number=$(wc -l < $test_pathlist)
echo "sample_number ${sample_number}"
checkpoint_path=$2
log_path=$(date '+%Y%m%d-%H%M%S')-generate_uncond.log
start_time=$SECONDS
python3 generate_uncond.py -n $sample_number -m 0 -l 4096 -o "generated/uncond" -c $checkpoint_path --use-cuda | tee -a $log_path
duration=$(( $SECONDS - start_time ))
echo "Generation takes $duration seconds" | tee -a $log_path
