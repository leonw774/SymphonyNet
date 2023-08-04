test_pathlist=$1
midis_dir_path=$2
checkpoint_path=$3
sample_number=$(wc -l < $test_pathlist)
log_path=$(date '+%Y%m%d-%H%M%S')-generate_primer4.log
touch test_primer_paths.txt
while read primer_file_path; do
   echo "${midi_dir_path}/${primer_file_path}" >> test_primer_paths.txt
done < $test_pathlist
start_time=$SECONDS
python generate_uncond.py -P test_primer_paths.txt -n $sample_number -m 4 -l 4096 -o "generated/${primer_name}" -c $checkpoint_path --use-cuda | tee -a $log_path
duration=$(( $SECONDS - start_time ))
rm test_primer_paths.txt
echo "Generation takes $duration seconds" | tee -a $log_path
