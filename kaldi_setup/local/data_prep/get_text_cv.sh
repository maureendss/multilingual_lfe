#!/usr/bin/env bash


echo "starting"
. ./cmd.sh
. ./path.sh
. utils/parse_options.sh



set -e # exit on error

if [ $# != 3 ]; then
   echo "usage: local/data_prep/prepare_librivox.sh <lb_processed_directory> <clip_dir> <target_data_dir> |LANG|"
   echo "e.g.:  local/data/prep/prepare_cv.sh ~/data/speech/commonvoice/cv-6.1 data/cv/ ca"
   exit 1;
fiOB

cv_directory=$1
tgt_dir=$2
lang=$3
# first put here info on how to get wav list.  

clip_dir=$cv_directory/raw/cv-corpus-6.1-2020-12-11/$lang/clips
cv_dir=$cv_directory/processed/$lang

# wav.scp format <utt> <path_wav>
# assumes you have a wav directory with all wavs in it, and with only the utterance name (symlinks to their proper location)


for set_tsv in $cv_dir/*; do

    
    set_name=$(echo `basename $set_tsv .tsv`)
    mkdir -p $tgt_dir/${lang}_${set_name}
    rm -f tgt_dir/${lang}_${set_name}/*.tmp #delete if exist
    
    tail -n+2 $set_tsv |  while read line; do #don't read first line
       
            spk=$(echo $line | cut -d' ' -f2)
            mp3_name=$(echo $mp3 | cut -d'.' -f1)
            utt=${spk}_${mp3_name}
            text=$(echo $line | cut -d$'\t' -f4 | tr '[:upper:]' '[:lower:]' |  tr  '[:punct:]' ' ' | sed 's/  */ /g')

            echo "$utt $text" >> $tgt_dir/${lang}_$set_name/text.tmp
            
            
        done  #don't read first line

        for item in text; do
            
            if [ ! -f $tgt_dir/${lang}_$set_name/$item ]; then
                echo "Sorting and finishing $item"
                sort $tgt_dir/${lang}_$set_name/$item.tmp > $tgt_dir/${lang}_$set_name/$item
                rm $tgt_dir/${lang}_$set_name/$item.tmp
            else
                echo "$tgt_dir/${lang}_$set_name/$item not already exist. Are you sure you want to rewrite it? "
                exit 1 
            fi
        done


done
