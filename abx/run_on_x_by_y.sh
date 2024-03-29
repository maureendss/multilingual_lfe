#!/usr/bin/env bash

set -e # exit on error


#sbatch_options="--mem=20G -n 5"
sbatch_options="--account ank@gpu --gres=gpu:1 --cpus-per-task=5 --ntasks-per-node=1 --mem-per-cpu=5G --time=01:00:00" #jeanzay

if [ $# != 3 ]; then
   echo "usage: ./run_on_x_by_y.sh <abx_dir> <on_value> <by_value>"
   echo "e.g.:  ./run.sh lfe spk lang"
   exit 1;
fi



dir=$1
on_value=$2
by_value=$3


for x in $dir/* ; do
    mkdir -p ${x}/log
    
    if [ ! -f ${x}/abx_on_${on_value}_by_${by_value}.avg ]; then
        echo "Processing ${x}"
        sbatch $sbatch_options -o ${x}/log/abx_on_${on_value}_by_${by_value}.log misc/run_abx_on_x_by_y.sh ${x} ${on_value} ${by_value}
        
    fi
    
done
