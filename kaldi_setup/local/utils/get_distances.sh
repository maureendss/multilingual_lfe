#!/usr/bin/env bash

# File for first steps on IVector Experiments

stage=0
grad=true
nj=50
nj_train=50
data=data/librispeech

pitch=true

exp_dir=exp_lfe

feats_suffix="" #mainly for vad and cmvn. What directly interacts with features
exp_suffix="" #redundant with exp_dir? TODO: to change

#languages="German English French Italian Chinese Dutch Finnish Portuguese Spanish"
train_set="train_all" #can be multiple




#feats-spec values . Should not change if want to keep experiments comparable.
vad=false
cmvn=false
deltas=false
deltas_sdc=true # not compatible with deltas
diag_only=false #if true, only train a diag ubm and not a full one. 

num_gauss=128
ivector_dim=150


. ./cmd.sh
. ./path.sh
. utils/parse_options.sh

set -e # exit on error




# ----------------------------------------------------------------------
#Stage 1 : Features Extraction of train sets. 
# ----------------------------------------------------------------------




#1. Combine data

if [ ! -d ${data}/${train_set} ]; then
   echo "Please use utils/combine_data.sh to combine all data"
   exit 1
fi

if [ ! -f ${data}/${train_set}/lang2utt ]; then
    utils/utt2spk_to_spk2utt.pl ${data}/${train_set}/utt2lang > ${data}/${train_set}/lang2utt ;
fi
# ----------------------------------------------------------------------
#Stage 2 : Diagonal UBM Training
# ----------------------------------------------------------------------

if [ $stage -eq 2 ] || [ $stage -lt 2 ] && [ "${grad}" == "true" ]; then

    for train in $train_set; do

        diag_ubm=${exp_dir}/ubm${exp_suffix}/diag_ubm_${num_gauss}_${train}${feats_suffix}
        if [ ! -f ${diag_ubm}/final.dubm ]; then
            echo "*** Training diag UBM with $train dataset ***"
            local/lid/train_diag_ubm.sh --cmd "$train_cmd --mem 20G" \
                                        --nj ${nj_train} --num-threads 8 \
                                        --parallel_opts "" \
                                        --cmvn ${cmvn} --vad ${vad} \
                                        --deltas ${deltas} --deltas_sdc ${deltas_sdc} \
                                        ${data}/${train}${feats_suffix} ${num_gauss} \
                                        ${diag_ubm}

            #TODO : use feat_opts to retrieve feat opts for future scripts. 
            printf "vad: $vad \n cmvn: $cmvn \n deltas: $deltas \n deltas_sdc: $deltas_sdc" > ${diag_ubm}/feat_opts
        else
            echo "*** diag UBM with $train dataset already exists - skipping ***"
        fi
    done;
fi;



# ----------------------------------------------------------------------
#Stage 3 : Full UBM Training
# ----------------------------------------------------------------------

if [ $stage -eq 3 ] || [ $stage -lt 3 ] && [ "${grad}" == "true" ]; then
    
    for train in $train_set; do

        diag_ubm=${exp_dir}/ubm${exp_suffix}/diag_ubm_${num_gauss}_${train}${feats_suffix}
        full_ubm=${exp_dir}/ubm${exp_suffix}/full_ubm_${num_gauss}_${train}${feats_suffix}

        if [ ! -f ${full_ubm}/final.ubm ]; then 
            
            if [ "$diag_only" == "true" ]; then

                echo "Training on diagonal ubm only - no full ubm"
                
                mkdir -p ${full_ubm}
                
                "$train_cmd"  ${full_ubm}/log/gmm-to-fgmm.log \
                              gmm-global-to-fgmm ${diag_ubm}/final.dubm ${full_ubm}/final.ubm

            else
                
                #Same for full ubm - need to remove the cmn 
                echo "*** Training full UBM with $train dataset ***"
                local/lid/train_full_ubm.sh --nj ${nj_train} --cmd "$train_cmd" \
                                            --cmvn ${cmvn} --vad ${vad} \
                                            --deltas ${deltas} --deltas_sdc ${deltas_sdc} \
                                            ${data}/${train}${feats_suffix} \
                                            ${diag_ubm} ${full_ubm};

                
            fi


            printf "vad: $vad \n cmvn: $cmvn \n deltas: $deltas \n deltas_sdc: $deltas_sdc" > ${full_ubm}/feat_opts

        else
            echo "${full_ubm}/final.ubm already exists - skipping full UBM training"
        fi
    done
fi


# ----------------------------------------------------------------------
#Stage 4: Training I-Vector Extractor
# ----------------------------------------------------------------------

if [ $stage -eq 4 ] || [ $stage -lt 4 ] && [ "${grad}" == "true" ]; then
    
    for train in $train_set; do

        full_ubm=${exp_dir}/ubm${exp_suffix}/full_ubm_${num_gauss}_${train}${feats_suffix}
        extractor=${exp_dir}/ubm${exp_suffix}/extractor_full_ubm_${num_gauss}_${train}${feats_suffix}
        
        if [ ! -f ${extractor}/final.ie ]; then
            echo "Training IVector Extractor for train set ${train}"
            
            local/lid/train_ivector_extractor.sh --cmd "$train_cmd --mem 60G" \
                                                 --nj ${nj_train} \
                                                 --num-iters 5 --num_processes 1 \
                                                 --ivector_dim ${ivector_dim} \
                                                 --cmvn ${cmvn} --vad ${vad} \
                                                 --deltas ${deltas} --deltas_sdc ${deltas_sdc} \
                                                 ${full_ubm}/final.ubm ${data}/${train}${feats_suffix}  ${extractor}
            printf "vad: $vad \n cmvn: $cmvn \n deltas: $deltas \n deltas_sdc: $deltas_sdc" > ${extractor}/feat_opts
        else
            echo "${extractor}/final.ie already exists - skipping training ivector extractor for ${train}"
        fi;
    done;
fi



# ----------------------------------------------------------------------
#Stage 5: Extracting I-Vectors (train and test)
# ----------------------------------------------------------------------

if [ $stage -eq 5 ] || [ $stage -lt 5 ] && [ "${grad}" == "true" ]; then

        for train in $train_set; do

            for iv_type in ${train}; do #only in test becausez no lda

                ivec_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}

                    nj_ivec=$(wc -l ${data}/${iv_type}${feats_suffix}/spk2utt | cut -d' ' -f1)

                if [ ! -f ${ivec_dir}/ivector.scp ]; then
                    local/lid/extract_ivectors.sh --cmd "$train_cmd --mem 40G" --nj "${nj_ivec}" \
                                                  --cmvn ${cmvn} --vad ${vad} \
                                                  --deltas ${deltas} --deltas_sdc ${deltas_sdc} \
                                                  ${exp_dir}/ubm"${exp_suffix}"/extractor_full_ubm_${num_gauss}_${train}${feats_suffix} ${data}/${iv_type}${feats_suffix} ${ivec_dir};
                    printf "vad: $vad \n cmvn: $cmvn \n deltas: $deltas \n deltas_sdc: $deltas_sdc" > ${ivec_dir}/feat_opts;

                    #Also creating a mean.vec file, averaging all ivectors.
                    ivector-mean ark:${data}/${iv_type}${feats_suffix}/lang2utt scp:${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}\
_ts-${iv_type}${feats_suffix}/ivector.scp ark,scp:${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang\
_ivectors.ark,${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang_ivectors.scp ark,scp:${exp_dir}/ive\
ctors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang_utt_num.ark,${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gau\
ss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang_utt_num.scp
                    local/utils/compute_cosine.py ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang\
_ivectors.ark ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/langdist.txt

                    local/utils/compute_cosine.py --distance euclidean ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type\
}${feats_suffix}/lang_ivectors.ark ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/langdist_euclidean.\
txt
                else
                    echo "Ivectors in ${ivec_dir} already exist - skipping Ivector Extraction"

                fi
            done
        done
fi





if [ $stage -eq 6 ] || [ $stage -lt 6 ] && [ "${grad}" == "true" ]; then

    for train in $train_set; do

        x=$train

        lda_train_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${x}${feats_suffix}
        logdir_lda=${lda_train_dir}/log

        #CAlculate number of languages
        num_lang=$(wc -l ${data}/${x}${feats_suffix}/lang2utt | cut -d' ' -f1)
        lda_dim=$(($num_lang - 1))

        if [ ! -f ${lda_train_dir}/lda_lang-${lda_dim}.mat ]; then

            echo "Computing lda for ${x} in ${lda_train_dir} with $lda_dim dimensions"

            "$train_cmd"  ${logdir_lda}/compute-lda.log \
                          ivector-compute-lda --dim=$lda_dim scp:${lda_train_dir}/ivector.scp \
                          ark:${data}/${x}${feats_suffix}/utt2lang ${lda_train_dir}/lda_lang-${lda_dim}.mat
        fi

       lda_filename="lda_lang-${lda_dim}-train_ivector"


        if [ ! -f ${lda_train_dir}/${lda_filename}.scp ] && [ -f ${lda_train_dir}/lda_lang-${lda_dim}.mat ]; then

            "$train_cmd"  ${logdir_lda}/${lda_filename}/transform-ivectors-train-lda.log \
                          ivector-transform ${lda_train_dir}/lda_lang-${lda_dim}.mat \
                          scp:${lda_train_dir}/ivector.scp \
                          ark,scp:${lda_train_dir}/${lda_filename}.ark,${lda_train_dir}/${lda_filename}.scp;
        fi

                           ivector-mean ark:${data}/${iv_type}${feats_suffix}/lang2utt scp:${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/${lda_filename}.scp ark,scp:${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang_${lda_filename}.ark,${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/${lda_filename}.scp
                    local/utils/compute_cosine.py ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang\
_${lda_filename}.ark ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lda_langdist.txt

                    local/utils/compute_cosine.py --distance euclidean ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lang_${lda_filename}.ark ${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}/lda_langdist_euclidean.txt

    done

fi




