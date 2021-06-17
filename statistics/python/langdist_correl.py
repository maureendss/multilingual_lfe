#!/usr/bin/env python
import lang2vec.lang2vec as l2v
import pandas as pd
import numpy as np
from scipy.spatial import distance
import random
import matplotlib.pyplot as plt
import copy


def read_csv(csv):
    df = pd.read_csv(csv, index_col=0)
    return df.T.to_dict(orient='list')

def compute_distances(lang_dic, dist="cosine"):
    lang_dist={}
    for lang in lang_dic.keys():
        lang_dist[lang] = {}
        for lang2 in lang_dic.keys():
            if dist == "cosine" :
                lang_dist[lang][lang2] = distance.cosine(lang_dic[lang], lang_dic[lang2])
            elif dist == "euclidean" :
                lang_dist[lang][lang2] = distance.euclidean(lang_dic[lang], lang_dic[lang2])
    return lang_dist

def iso2_to_iso3(dic):
    mapping={"ar":"ara", "ca":"cat", "cs":"ces", "cy":"cym", "de":"deu", "rw" :"kin", "en":"eng", "eo":"epo", "es":"spa", "eu":"eus", "fa":"fas", "fr":"fra", "fy-NL":"fry", "it":"ita", "kab":"kab", "nl":"nld", "pl":"pol", "pt":"por", "ru":"rus", "sv-SE":"swe", "ta":"tam", "tr":"tur","tt":"tat", "uk":"ukr", "zh-CN":"zho" }
    new_dic={}
    for k in dic.keys():
        new_dic[mapping[k]] = dic[k]
    return new_dic


def get_correl(dic_a, dic_b):
    a_tmp = pd.DataFrame.from_dict(dic_a)
    a = a_tmp.sort_index().reindex(sorted(a_tmp.columns), axis=1)

    b_tmp = pd.DataFrame.from_dict(dic_b)
    b = b_tmp.sort_index().reindex(sorted(b_tmp.columns), axis=1)

    if not (b.index == a.index).all() and not (b.columns == a.columns).all():
        raise ValueError("Columns and / or Index in dic_a and dic_b are different.")


    pearson = np.corrcoef(remove_nan(a.to_numpy().flatten()),remove_nan(b.to_numpy().flatten()))
    return pearson[0,1]


def get_comparable_distance_vec(d):

    lang_to_remove = []
    dic = copy.deepcopy(d)

    for lang in sorted(list(dic.keys())):
        lang_to_remove.append(lang)
        for l in lang_to_remove :
            dic[lang].pop(l)

    return dic


def remove_nan(array):
    nan_array = np.isnan(array)

    not_nan_array = ~ nan_array

    return array[not_nan_array]





def get_plot(dic_a, dic_b):
    a_tmp = pd.DataFrame.from_dict(dic_a)
    a = a_tmp.sort_index().reindex(sorted(a_tmp.columns), axis=1)

    b_tmp = pd.DataFrame.from_dict(dic_b)
    b = b_tmp.sort_index().reindex(sorted(b_tmp.columns), axis=1)

    a = remove_nan(a.to_numpy().flatten())
    b = remove_nan(b.to_numpy().flatten())
    plt.plot(a, b , 'o', color='black')
    plt.show()

def random_dict_shuffle(d):

    shuffled = list(d.values())
    random.shuffle(shuffled)
    return dict(zip(d, shuffled))

if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument("path_ivec_csv", help="/home/maureen/Desktop/lda_ivectors_2048_tr-train_large_all-1h_ts-train_large_all-1h_lang_ivector.csv") #syntax_knn
    parser.add_argument("path_featvec_csv", help="lang_vecs/syntax_knn.csv")
    parser.add_argument("--permutation", action='store_true')

    parser.parse_args()
    args, leftovers = parser.parse_known_args()

    feat_vec=read_csv(args.path_featvec_csv)
    ivec = iso2_to_iso3(read_csv(args.path_ivec_csv))

    if args.permutation:
        print("Permuting")
        feat_vec=random_dict_shuffle(feat_vec)
        ivec=random_dict_shuffle(ivec)

    feat_vec2dist = get_comparable_distance_vec(compute_distances(feat_vec))
    ivec2dist = get_comparable_distance_vec(compute_distances(ivec, dist = "euclidean"))


    corr = get_correl(feat_vec2dist, ivec2dist)
    print("Pearson Correlation score : ", corr)

    get_plot(feat_vec2dist, ivec2dist)

# python ../statistics/python/langdist_correl.py  --permutation /home/maureen/Desktop/lda_ivectors_2048_tr-train_large_all-1h_ts-train_large_all-1h_lang_ivector.csv lang_vecs/syntax_knn.csv
