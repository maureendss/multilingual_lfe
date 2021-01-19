#!/usr/bin/env python 

import lang2vec.lang2vec as l2v
import pandas as pd

if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("mode", help="<distance> or <list_lang>")
    parser.add_argument("--lang_list", help="list of languages separated by spaces. Use iso codes from https://wals.info/languoid. ", default="eng deu fin mnd fra ita rus spa")
    parser.add_argument("--distance_type", help="what kind of distance to compute", default="phonological")
    parser.add_argument("--csv_name", help="path to csv", default="phono_distances.csv") 
    parser.parse_args()
    args, leftovers = parser.parse_known_args()

    langs = args.lang_list.split(" ")

    
    
    if args.mode == "list_lang":

        for x in l2v.LANGUAGES :
            print(x)



    elif args.mode == "distance":
        df = pd.DataFrame(data=l2v.distance(args.distance_type, langs), index=langs, columns=langs)
        df.to_csv(args.csv_name)

    else :
        print("Only two modes are currently accepted: <distance> and <list_lang>")
