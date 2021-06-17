#!/usr/bin/env python

import numpy as np
import kaldiio
import os, shutil
import itertools
import pandas as pd
#read from feats.scp
#add feats scp direc

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("ivec", help="path to the lang_ivectors.ark file")
    parser.add_argument("output_csv", help="path to the output vectors file")
    parser.parse_args()
    args, leftovers = parser.parse_known_args()


    lang2vec={}
    with kaldiio.ReadHelper('ark:{}'.format(args.ivec)) as reader:
        for key, numpy_array in reader:
            lang2vec[key] = numpy_array

    lang2vec_df = pd.DataFrame.from_dict(lang2vec, orient='index')
    lang2vec_df.to_csv(args.output_csv)

            
