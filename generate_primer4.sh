test_pathlist=$1
midis_dir_path=$2
checkpoint_path=$3
start_time=$SECONDS
log_path=$(date '+%Y%m%d-%H%M%S')-generate_primer4.log
while read test_midi_path; do
   primer_name=$(basename "$test_midi_path" .mid)
   python generate_uncond.py -p "${midis_dir_path}/${test_midi_path}" -m 4 -l 4096 -o "generated/${primer_name}" -c $checkpoint_path --use-cuda | tee -a $log_path
done < $test_pathlist
duration=$(( $SECONDS - start_time ))
echo "Generation takes $duration seconds" | tee -a $log_path
