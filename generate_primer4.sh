test_pathlist=$1
midis_dir_path=$2
checkpoint_path=$3
log_path=$(date '+%Y%m%d-%H%M%S')-generate_primer4.log
while read primer_file_path; do
   primer_name=$(basename "$primer_file_path" .mid)
   python generate_uncond.py -p "${midis_dir_path}/${primer_file_path}" -m 4 -l 4096 -o "generated/${primer_name}" -c $checkpoint_path --use-cuda | tee -a $log_path
done < $test_pathlist
python3 get_gen_time_from_log.py $log_path
