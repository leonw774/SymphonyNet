test_pathlist=$1
midis_dir_path=$2
start_time=$SECONDS
while read test_midi_path; do
   primer_name=$(basename "$test_midi_path" .mid)
   python generate_uncond.py -p "${midis_dir_path}/${test_midi_path}" -m 4 -l 4096 -o "generated/${primer_name}"
done < $eval_pathlist_path
duration=$(( $SECONDS - start_time ))
