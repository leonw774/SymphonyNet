test_pathlist=$1
start_time=$SECONDS
while read eval_sample_midi_path; do
   primer_name=$(basename "$eval_sample_midi_path" .mid)
   python generate_uncond.py -p "../MyMidiModel/${eval_sample_midi_path}" -m 4 -l 4096 -o "generated/${primer_name}"
done < $eval_pathlist_path
duration=$(( $SECONDS - start_time ))
