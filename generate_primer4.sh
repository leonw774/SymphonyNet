test_pathlist=$1
midis_dir_path=$2
checkpoint_path=$3
start_time=$SECONDS
log_path=$(date '+%Y%m%d-%H%M%S')-generate_primer4.log
touch test_primer_paths.txt
while read primer_file_path; do
   echo "${midi_dir_path}/${primer_file_path}" >> test_primer_paths.txt
done < $test_pathlist
python generate_uncond.py -P test_primer_paths.txt -m 4 -l 4096 -o "generated/${primer_name}" -c $checkpoint_path --use-cuda | tee -a $log_path
duration=$(( $SECONDS - start_time ))
rm test_primer_paths.txt
echo "Generation takes $duration seconds" | tee -a $log_path
