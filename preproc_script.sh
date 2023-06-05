#!/bin/bash

test -d data/midis && rm data/midis
test -d data/bpe_res_snd && rm data/bpe_res_snd -r
test -d data/bpe_res_lmd_full && rm data/bpe_res_lmd_full -r

log_path="$(date '+%Y%m%d-%H%M%S')-preproc_snd.log"
ln -s ~/MyMidiModel/data/midis/SymphonyNet_Dataset data/midis
cp data/snd_test_pathlist.txt data/test_pathlist.txt
python3 src/preprocess/preprocess_midi.py 2>&1 | tee -a $log_path
python3 src/preprocess/get_bpe_data.py 2>&1 | tee -a $log_path
mv data/bpe_res data/bpe_res_snd
mv data/preprocessed/raw_corpus.txt data/preprocessed/raw_corpus_snd.txt
mv data/preprocessed/raw_corpus_bpe.txt data/preprocessed/raw_corpus_snd_bpe.txt
rm data/midis
rm data/test_pathlist.txt

log_path="$(date '+%Y%m%d-%H%M%S')-preproc_lmd.log"
ln -s ~/MyMidiModel/data/midis/lmd_full data/midis
cp data/lmd_full_test_pathlist.txt data/test_pathlist.txt
python3 src/preprocess/preprocess_midi.py 2>&1 | tee -a $log_path
python3 src/preprocess/get_bpe_data.py 2>&1 | tee -a $log_path
mv data/preprocessed/raw_corpus.txt data/preprocessed/raw_corpus_lmd.txt
mv data/preprocessed/raw_corpus_bpe.txt data/preprocessed/raw_corpus_lmd_bpe.txt
mv data/bpe_res data/bpe_res_lmd
rm data/midis
rm data/test_pathlist.txt
