#!/usr/bin/env python
import lang2vec.lang2vec as l2v
import pandas as pd
import numpy as np
from scipy.spatial import distance
from scipy import stats
import random
import matplotlib.pyplot as plt
import copy
from tqdm import tqdm

#dictionaries are sorted in python 3. 7 +

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


def pearsonr(df):

    pearson = np.corrcoef(df['ivector'], df['feature'])
    return pearson[0,1]


def reduce_langpair_dic(d):

    lang_to_remove = []
    dic = copy.deepcopy(d)

    for lang in sorted(list(dic.keys())):
        lang_to_remove.append(lang)
        for l in lang_to_remove :
            dic[lang].pop(l)

    #Now we create a new dictionary with items together.
    d2 = {}
    for k in sorted(list(dic.keys())):
        for k2 in sorted(list(dic[k].keys())):
            d2[k+"-"+k2]= dic[k][k2]

    return d2


#def remove_nan(array):
#    nan_array = np.isnan(array)

#    not_nan_array = ~ nan_array

#    return array[not_nan_array]



def create_df(feat_vec, ivec):

    featvec2dist = compute_distances(feat_vec)
    ivec2dist = compute_distances(ivec, dist = "euclidean")

    feat = reduce_langpair_dic(featvec2dist)
    ivec = reduce_langpair_dic(ivec2dist)

    df = pd.DataFrame({"ivector":pd.Series(ivec),"feature":pd.Series(feat)})
    return df

def get_plot(df, plot_path, ivec_label="Ivector Euc Distance (LDA)", feature_label="Linguistic Feature Distance", show=True):
    import seaborn as sns
    sns.set_theme()

    plt.figure()
    x = df['ivector']
    y = df['feature']

    # normalise ivector
    x = (x-x.min())/(x.max()-x.min())



    m, b = np.polyfit(x, y, 1)
    plt.plot(x, m*x + b)

    plt.plot(x,y , '.', color="black")
    plt.xlabel(ivec_label)
    plt.ylabel(feature_label)


    plt.savefig(plot_path)
    if show:
        plt.show()


def random_dict_shuffle(d):

    shuffled = list(d.values())
    random.shuffle(shuffled)
    return dict(zip(d, shuffled))


def correl_with_perm(feat_vec, ivec, nperm=999):

    r = pearsonr(create_df(feat_vec, ivec))

    r_res = []
    for x in tqdm(range(nperm)):
        #if x%100 == 0:
        #    print("iteration #", x)
        feat_vec_perm=random_dict_shuffle(feat_vec)
        ivec_perm=random_dict_shuffle(ivec)
        r_res.append(pearsonr(create_df(feat_vec_perm, ivec_perm)))

    r_res_altonly = r_res #only so that we can plot distrib later
    r_res.append(r)

    #calculate your p value by comparing them to your potential correlations.
    # see https://www.reddit.com/r/AskStatistics/comments/a47av6/permutation_test_with_pearson_correlation/
    #If you get 1e-5 out, that means none of the resampled correlations were as big (in absolute terms) as the sample one; in that situation it's an upper bound on the p-value.

    abs_r_res = list(map(abs, r_res))
    p_value = np.mean([i>=r for i in abs_r_res])

    return r, p_value, np.sort(r_res_altonly)



if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument("path_ivec_csv", help="/home/maureen/Desktop/lda_ivectors_2048_tr-train_large_all-1h_ts-train_large_all-1h_lang_ivector.csv") #syntax_knn
    parser.add_argument("path_featvec_csv", help="lang_vecs/syntax_knn.csv")
    parser.add_argument("--permutation", action='store_true')
    parser.add_argument("--nperm", type=int, default=999)
    parser.add_argument("--no_plot", action='store_true')
    parser.add_argument("--plot", default="corr.png")
    parser.add_argument("--ivec_label", default="Ivector Euc Distance (LDA)")
    parser.add_argument("--feature_label", default="Linguistic Feature Distance")


    parser.parse_args()
    args, leftovers = parser.parse_known_args()

    feat_vec=read_csv(args.path_featvec_csv)
    ivec = iso2_to_iso3(read_csv(args.path_ivec_csv))
    #feat_vec=read_csv("lang_vecs/syntax_knn.csv")
    #ivec = iso2_to_iso3(read_csv("/home/maureen/Desktop/lda_ivectors_2048_tr-train_large_all-1h_ts-train_large_all-1h_lang_ivector.csv"))

    #if args.permutation:
        #print("Permuting")
        #feat_vec=random_dict_shuffle(feat_vec)
        #ivec=random_dict_shuffle(ivec)
    #df = create_df(feat_vec, ivec)
    #corr = pearsonr(df)
    df = create_df(feat_vec, ivec)
    if args.permutation:
        corr, p_value, r_res_altonly = correl_with_perm(feat_vec, ivec, nperm=args.nperm)
        print("Pearson Correlation score : ", corr, " and p.value of : ", p_value)


        #show plot
        #y_values = stats.norm(np.mean(r_res_altonly), np.std(r_res_altonly))
        #plt.plot(r_res_altonly, y_values.pdf(r_res_altonly))
        #plt.plot(corr,0,'ro')
        #plt.vlines(corr, 0, 1, 'r')
        #plt.show()


        import seaborn as sns
        data = r_res_altonly
        plt.figure()
        sns.set_style('whitegrid')
        sns.kdeplot(np.array(data), bw=0.5)
        plt.plot([corr, corr], [0, max(r_res_altonly)])
        plt.xlabel("Correlation score")


    else:
        corr = pearsonr(df)
        print("Pearson Correlation score : ", corr)

    if not args.no_plot:
        get_plot(df, args.plot, ivec_label=args.ivec_label, feature_label=args.feature_label)

# python ../statistics/python/langdist_correl.py  --permutation --nperm 9999 /home/maureen/Desktop/lda_ivectors_2048_tr-train_large_all-1h_ts-train_large_all-1h_lang_ivector.csv lang_vecs/syntax_knn.csv
