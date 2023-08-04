test_pathlist=$1
sample_number=$(wc -l < $test_pathlist)
echo "sample_number ${sample_number}"
checkpoint_path=$2
log_path=$(date '+%Y%m%d-%H%M%S')-generate_uncond.log
for i in $(seq $sample_number); do
    python3 generate_uncond.py -n 1 -m 0 -l 4096 -o "generated/uncond" -c $checkpoint_path --use-cuda | tee -a $log_path
done
python3 get_gen_time_from_log.py $log_path
