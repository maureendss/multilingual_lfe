#!/usr/bin/env python

from itertools import combinations
import os


def read_avg(dir_path):
    with open(os.path.join(dir_path, "abx_on_spk_by_lang.avg"), 'r') as infile:
        score = infile.readline().strip()
    return float(score)*100


def get_lfe(lang_pair, path_template):

    l1 = lang_pair[0]
    l2 = lang_pair[1]
    same_a = path_template.replace('<L_TRAIN>', l1).replace('<L_TEST>', l1)
    same_b = path_template.replace('<L_TRAIN>', l2).replace('<L_TEST>', l2)
    diff_a = path_template.replace('<L_TRAIN>', l2).replace('<L_TEST>', l1)
    diff_b = path_template.replace('<L_TRAIN>', l1).replace('<L_TEST>', l2)

    same_a_score = read_avg(same_a)
    same_b_score = read_avg(same_b)
    diff_a_score = read_avg(diff_a) 
    diff_b_score = read_avg(diff_b)  

    s_same  = (same_a_score + same_b_score)/2
    s_diff  = (diff_a_score + diff_b_score)/2 
    s_lfe = (s_diff - s_same)/s_same

    return s_lfe*100
    
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("abx_directory", help="This only works in a very specific setup. ")
    parser.add_argument("--abx_template_name", help="give the name of the directory with <L_TRAIN> and <L_TEST> in the setup.", default="ivector_2048_tr-<L_TRAIN>_train-15h-60spk_ts-<L_TEST>_test-0h-20spk")
    parser.add_argument("--lang_list", help="list of languages (at least two to have a pair)", default="ca cy de en fa fr it kab rw")
    parser.parse_args()
    args, leftovers = parser.parse_known_args()


    lang_list = args.lang_list.split(" ")
    lang_pairs = [x for x in combinations(lang_list,2)]

    for lp in lang_pairs :

        path_template = os.path.join(args.abx_directory, args.abx_template_name)
        try:
            print("Langpair {} - LFE : {}".format(lp, round(get_lfe(lp, path_template),3)))
        except:
            pass
            #print("Couldn't retrieve pair {}".format(lp))
