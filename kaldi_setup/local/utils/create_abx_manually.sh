#!/usr/bin/env bash

sbatch_req="--account ank@gpu --partition=gpu_p2l --gres=gpu:1 --time=01:00:00 --cpus-per-task=3 --ntasks=1 --nodes=1 --hint=nomultithread"

# path to the ivector directory 
path_to_scp=$1 #exp_lfe_highdim/test_all_ivector.scp   #concatenation of all scps. 
output_dir=$2 
data_dir=$3
ivector_dim=$4

echo $path_to_scp

scp="${path_to_scp%.*}" #remove the extension

x=$(`basename $scp`)


mkdir -p $output_dir/log

#create ivectors.item #TODO ADD SLURM
if [ ! -f ${output_dir}/ivectors.item ]; then
    echo "** Creating ${output_dir}/ivectors.item **"
    python local/utils/utt2lang_to_item.py --ivector_dim ${ivector_dim} ${data_dir} ${output_dir}
fi



for x in ivector; do #changed name from ivectors to ivector in h5f file

    if [ ! -f ${output_dir}/${x}.h5f ]; then
        echo "** Computing ivectors_to_h5f files for ${output_dir}/** for ${x}"
        echo " Should be in ${output_dir}/${x}.h5f"
        rm -rf ${output_dir}/tmp
        
        sbatch $sbatch_req -o ${output_dir}/log/ivec2h5f_${x}.log local/utils/ivectors_to_h5f.py --output_name ${x}.h5f ${path_to_scp} ${output_dir}
        while [ ! -f ${output_dir}/${x}.h5f ]; do sleep 0.5; done
    else
        echo "${output_dir}/${x}.h5f already exists. Not recreating it"
    fi

    if [ ! -f ${output_dir}/${x}.csv ]; then
        echo "** Creating ivectors.csv file for for ${ivec_dir}/** for ${x}"
        sbatch $sbatch_req -o ${output_dir}/log/ivec2csv_${x}.log local/utils/ivectors_to_csv.py --output_name ${x}.csv ${path_to_scp} ${output_dir};
        while [ ! -f ${ivec_dir}/${x}.csv ]; do sleep 0.1; done
    fi
    


    #NEED TO ADD AN S AT THE END OF IVECTOR !!!!

    
    # #create abx directories
    # path_to_h5f=$(readlink -f ${ivec_dir}/${x}.h5f)
    # path_to_item=$(readlink -f ${ivec_dir}/ivectors.item)
    # path_to_csv=$(readlink -f ${ivec_dir}/${x}.csv)
    # tgt_abx_dir=${abx_dir}${exp_suffix}/${x}_${num_gauss}_tr-${train}${feats_suffix}_ts-${test_set}${feats_suffix}

    # echo "** Creating abx directories in ${tgt_abx_dir} **"
    # # rm -f ${tgt_abx_dir}/ivectors.*
    # mkdir -p ${tgt_abx_dir}
    
    # if [ ! -f ${tgt_abx_dir}/ivectors.h5f ]; then ln -s ${path_to_h5f} ${tgt_abx_dir}/ivectors.h5f; fi
    # if [ ! -f ${tgt_abx_dir}/ivectors.item ]; then ln -s ${path_to_item} ${tgt_abx_dir}/. ; fi
    # if [ ! -f ${tgt_abx_dir}/ivectors.csv ]; then ln -s  ${path_to_csv} ${tgt_abx_dir}/ivectors.csv ; fi
done;
