#!/usr/bin/env bash

# File for first steps on IVector Experiments


mfcc_conf=mfcc.original.conf # mfcc configuration file. The "original" one attempts to reproduce the settings in julia's experiments. 
stage=0
grad=true
nj=40
nj_train=10
data=data/librispeech

pitch=true

prepare_abx=true

exp_dir=exp_lfe
abx_dir=../abx/lfe

feats_suffix="" #mainly for vad and cmvn. What directly interacts with features
exp_suffix="" #redundant with exp_dir? TODO: to change


train_set="train_italian_10h_10spk" #can be multiple
test_set="test_italian_4h_10spk" #only one

sbatch_req="--account ank@gpu --partition=gpu_p2l --gres=gpu:1 --time=01:00:00 --cpus-per-task=3 --ntasks=1 --nodes=1 --hint=nomultithread"


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

if [ $stage -eq 1 ] || [ $stage -lt 1 ] && [ "${grad}" == "true" ]; then


    
    mfcc_conf=conf/mfcc.original.conf

    for x in $train_set $test_set; do

        if [ ! -f ${data}/${x}"${feats_suffix}"/feats.scp ]; then

           if [ $pitch == "true" ]; then

              echo "computing features with pitch"
              steps/make_mfcc_pitch.sh --mfcc-config ${mfcc_conf} --cmd "${train_cmd}" --nj ${nj} ${data}/${x}${feats_suffix}

          else
            echo "computing features without pitch"
            steps/make_mfcc.sh --mfcc-config ${mfcc_conf} --cmd "${train_cmd}" --nj ${nj} \
                               ${data}/${x}"${feats_suffix}"
          fi
        fi

        if [ "${cmvn}" == "true" ] && [ ! -f ${data}/${x}"${feats_suffix}"/cmvn.scp ]; then
            steps/compute_cmvn_stats.sh ${data}/${x}"${feats_suffix}"
        fi

        if [ "${vad}" == "true" ] && [ ! -f ${data}/${x}"${feats_suffix}"/vad.scp ]; then
            steps/compute_vad_decision.sh --cmd "$train_cmd" ${data}/${x}"${feats_suffix}"
        fi

        echo "pitch $pitch" >> ${data}/${x}"${feats_suffix}"/feat_opts
        echo "cmvn $cmvn" >> ${data}/${x}"${feats_suffix}"/feat_opts
        echo "vad $vad" >> ${data}/${x}"${feats_suffix}"/feat_opts


        utils/validate_data_dir.sh --no-text ${data}/${x}"${feats_suffix}"

    done

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
    done
fi



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
        fi
    done
fi



# ----------------------------------------------------------------------
#Stage 5: Extracting I-Vectors (train and test)
# ----------------------------------------------------------------------

if [ $stage -eq 5 ] || [ $stage -lt 5 ] && [ "${grad}" == "true" ]; then

        for train in $train_set; do

            #for iv_type in ${train} ${test_set}; do
            for iv_type in ${train} ${test_set}; do #only in test becausez no lda

                ivec_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${iv_type}${feats_suffix}

                    nj_ivec=$(wc -l ${data}/${iv_type}${feats_suffix}/spk2utt | cut -d' ' -f1)

                if [ ! -f ${ivec_dir}/ivector.scp ]; then
                    local/lid/extract_ivectors.sh --cmd "$train_cmd --mem 40G" --nj "${nj_ivec}" \
                                                  --cmvn ${cmvn} --vad ${vad} \
                                                  --deltas ${deltas} --deltas_sdc ${deltas_sdc} \
                                                  ${exp_dir}/ubm"${exp_suffix}"/extractor_full_ubm_${num_gauss}_${train}${feats_suffix} ${data}/${iv_type}${feats_suffix} ${ivec_dir};
                    printf "vad: $vad \n cmvn: $cmvn \n deltas: $deltas \n deltas_sdc: $deltas_sdc" > ${ivec_dir}/feat_opts;
                else
                    echo "Ivectors in ${ivec_dir} already exist - skipping Ivector Extraction"
                fi
            done
        done
fi




# ----------------------------------------------------------------------                                                                                                    
#Stage 5b: Computing LDA                                                                                                                              
# ----------------------------------------------------------------------                                                                                                     

if [ $stage -eq 5 ] || [ $stage -lt 5 ] && [ "${grad}" == "true" ]; then

    for train in $train_set; do

        ivec_test_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${test_set}${feats_suffix}
        logdir_test=${ivec_test_dir}/log
        

        for x in ${train} ${test_set}; do
            lda_train_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${x}${feats_suffix}
            logdir_lda=${lda_train_dir}/log

            num_spk=$(wc -l ${data}/${x}${feats_suffix}/spk2utt | cut -d' ' -f1)
            lda_dim=$(($num_spk - 1))

            if [ ! -f ${lda_train_dir}/lda-${lda_dim}.mat ] && [ "$x" != "${test_set}" ]; then

                echo "Computing lda for ${x} in ${lda_train_dir} with $lda_dim dimensions"

                "$train_cmd"  ${logdir_lda}/compute-lda.log \
                              ivector-compute-lda --dim=$lda_dim scp:${lda_train_dir}/ivector.scp \
                              ark:${data}/${x}${feats_suffix}/utt2spk ${lda_train_dir}/lda-${lda_dim}.mat
            fi

            if [ "${x}" == "${test_set}" ]; then lda_filename="lda-${lda_dim}-test_ivector"; else lda_filename="lda-${lda_dim}-train_ivector"; fi

            if [ ! -f ${ivec_test_dir}/${lda_filename}.scp ] && [ -f ${lda_train_dir}/lda-${lda_dim}.mat ]; then

                "$train_cmd"  ${logdir_test}/${lda_filename}/transform-ivectors-train.log \
                              ivector-transform ${lda_train_dir}/lda-${lda_dim}.mat \
                              scp:${ivec_test_dir}/ivector.scp \
                              ark,scp:${ivec_test_dir}/${lda_filename}.ark,${ivec_test_dir}/${lda_filename}.scp;
            fi


            if [ ! -f ${lda_train_dir}/${lda_filename}.scp ] && [ -f ${lda_train_dir}/lda-${lda_dim}.mat ]; then

                "$train_cmd"  ${logdir_lda}/${lda_filename}/transform-ivectors-train-lda.log \
                              ivector-transform ${lda_train_dir}/lda-${lda_dim}.mat \
                              scp:${lda_train_dir}/ivector.scp \
                              ark,scp:${lda_train_dir}/${lda_filename}.ark,${lda_train_dir}/${lda_filename}.scp;
            fi
        done

    done

fi




# ----------------------------------------------------------------------
#Stage 6: Setting up ABX directory for non-LDA I-Vectors AND LDA
# ----------------------------------------------------------------------

if [ $stage -eq 6 ] || [ $stage -lt 6 ] && [ "${grad}" == "true" ] && [ "$prepare_abx" == "true" ]; then

    for train in $train_set; do

        ivec_dir=${exp_dir}/ivectors${exp_suffix}/ivectors_${num_gauss}_tr-${train}${feats_suffix}_ts-${test_set}${feats_suffix}
        
        #create ivectors.item #TODO ADD SLURM
        if [ ! -f ${ivec_dir}/ivectors.item ]; then
            echo "** Creating ${ivec_dir}/ivectors.item **"
            python local/utils/utt2lang_to_item.py --ivector_dim ${ivector_dim} ${data}/${test_set}${feats_suffix} ${ivec_dir}
        fi
 

        num_spk_train=$(wc -l ${data}/${train}${feats_suffix}/spk2utt | cut -d' ' -f1)
        lda_dim_train=$(($num_spk_train - 1))

        num_spk_test=$(wc -l ${data}/${test_set}${feats_suffix}/spk2utt | cut -d' ' -f1)
        lda_dim_test=$(($num_spk_test - 1)) 
        
        # for x in ivector lda-${lda_dim_test}-test_ivector lda-${lda_dim_train}-train_ivector; do #changed name from ivectors to ivector in h5f file
        for x in ivector lda-${lda_dim_train}-train_ivector; do #changed name from ivectors to ivector in h5f file

            if [ ! -f ${ivec_dir}/${x}.h5f ]; then
                echo "** Computing ivectors_to_h5f files for ${ivec_dir}/** for ${x}"
                echo " Should be in ${ivec_dir}/${x}.h5f"
                rm -rf ${ivec_dir}/tmp
                rm -f ${ivec_dir}/${x}.h5f
                sbatch $sbatch_req -o ${ivec_dir}/log/ivec2h5f_${x}.log local/utils/ivectors_to_h5f.py --output_name ${x}.h5f ${ivec_dir}/${x}.scp ${ivec_dir}
                while [ ! -f ${ivec_dir}/${x}.h5f ]; do sleep 0.5; done
            else
                echo "${ivec_dir}/${x}.h5f already exists. Not recreating it"
            fi

            if [ ! -f ${ivec_dir}/${x}.csv ]; then
                echo "** Creating ivectors.csv file for for ${ivec_dir}/** for ${x}"
                sbatch $sbatch_req -o ${ivec_dir}/log/ivec2csv_${x}.log local/utils/ivectors_to_csv.py --output_name ${x}.csv ${ivec_dir}/${x}.scp ${ivec_dir};
                while [ ! -f ${ivec_dir}/${x}.csv ]; do sleep 0.1; done
            fi
            

            #create abx directories
            path_to_h5f=$(readlink -f ${ivec_dir}/${x}.h5f)
            path_to_item=$(readlink -f ${ivec_dir}/ivectors.item)
            path_to_csv=$(readlink -f ${ivec_dir}/${x}.csv)
            tgt_abx_dir=${abx_dir}${exp_suffix}/${x}_${num_gauss}_tr-${train}${feats_suffix}_ts-${test_set}${feats_suffix}

            echo "** Creating abx directories in ${tgt_abx_dir} **"
            # rm -f ${tgt_abx_dir}/ivectors.*
             mkdir -p ${tgt_abx_dir}
            
            if [ ! -f ${tgt_abx_dir}/ivectors.h5f ]; then ln -s ${path_to_h5f} ${tgt_abx_dir}/ivectors.h5f; fi
            if [ ! -f ${tgt_abx_dir}/ivectors.item ]; then ln -s ${path_to_item} ${tgt_abx_dir}/. ; fi
            if [ ! -f ${tgt_abx_dir}/ivectors.csv ]; then ln -s  ${path_to_csv} ${tgt_abx_dir}/ivectors.csv ; fi
        done;
    done;
        
fi
