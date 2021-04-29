#!/usr/bin/env python

import numpy as np
import kaldiio
from scipy.spatial import distance
from sklearn.metrics import pairwise
import os, shutil
import pandas as pd
import itertools
#read from feats.scp
#add feats scp direc

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("ivec", help="path to the lang_ivectors.ark file")
    parser.add_argument("out_dist", help="path to the output distance matrix")
    parser.add_argument("--distance", help="distance to calculate. Either cosine or euclidean. Cosine is cosine similarity.", default='cosine')
    parser.parse_args()
    args, leftovers = parser.parse_known_args()


    lang2vec={}
    with kaldiio.ReadHelper('ark:{}'.format(args.ivec)) as reader:
        for key, numpy_array in reader:
            lang2vec[key] = numpy_array

    pair2dist = {}
    pairs=list(itertools.combinations(lang2vec.keys(), 2))
    for langpair in pairs:


        if args.distance == "cosine":
            score = 1 - distance.cosine(lang2vec[langpair[0]], lang2vec[langpair[1]])
        elif args.distance == "euclidean":
            score = distance.euclidean(lang2vec[langpair[0]], lang2vec[langpair[1]])

        else:
            raise ValueError('Only accepting cosine and euclidean distance')
        pair2dist['-'.join(langpair)] = score
        #pair2dist['-'.join(langpair[::-1])] = cosine_similarity
        
            
    with open(args.out_dist, 'w') as outfile:
        for k,v in pair2dist.items():
            outfile.write('{} {}\n'.format(k,v))
            
