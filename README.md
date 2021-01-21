# Language Familiarity Effect (LFE)

- Inspired from Thorburn et al (2019)
- Remember, pitch IS taken into account.


## How To 

Prepare conda environment and activate it. 
(use requirements.txt)

### GEt submodules

```
git submodule init
git submodule update
```

Then prepare lang2vec.

```
cd lang2vec
python setup.py install
```

### Prepare Interface

1. Fill out the `kaldi_setup/cmd.sh` and `kaldi_setup/path.sh` accordingly with your setup.

2. Link all files from `kaldi_setup` and `abx` into appropriate local folders (this is where the output of your experiments will go). *Consider creating this local folders into a place with enough storage*.
   ```
   mkdir -p local/kaldi_setup
   mkdir -p local/abx
   cd local/kaldi_setup && ln -s ../../kaldi_setup/* . && cd ../..
   cd local/abx && ln -s ../../abx/* . && cd ../..
   ```

3. Activate Conda Environment.  (use the requirements.txt file)
   __TODO : Give more info on env__


### LAng2vec computing
Check the lang codes in https://wals.info/languoid

Then if you want to create a csv array with the matrices:

`python lang2vec_local/get_distances.py distance --csv_name lang2vec/distances/phonological.csv --distance_type phonological --lang_list "eng deu fin mnd fra ita rus spa"`

### Data Preparation

* Prepares data from any language in the LibriVox database. 

1. Follow instructions from the [data preparation repository](https://github.com/maureendss/data_preparation) (tab : Librivox).

2.
```
cd local/kaldi_setup

lang="English Italian Spanish"

for x in lang; do
   mkdir -p data/librispeech/${lang}
done

```
3. Run `kaldi_setup/local/data_prep/prepare_librivox.sh` with the correct arguments.
 
*e.g.* : `sbatch -n 20 local/data_prep/prepare_librivox.sh ~/data/speech/librivox/finnish/processed/LFE/10h_10spk data/librispeech/train_finnish_10h10spk Finnish`  

*__Todo__ : Give more info / examples in this section*

### Train LFE. 


5. Run local/exp/train_LFE.sh
   *e.g.* : `./local/exp/train_LFE.sh --train_set train_finnish_10h10spk --test_set test_finnish_4h10spk`

6. Run the ABX tests : `cd ../abx/ && bash run_on_x_by_y.sh lfe spk lang`

7. Retrieve the scores : ` ./retrieve_scores.sh lfe abx_on_spk_by_lang.avg`

*Note : Results are prone to minor changes due to the randomness in computing MFCC features*

--------------------

## References

[Thorburn, Craig A., Naomi H. Feldman, and Thomas Schatz. "A quantitative model of the language familiarity effect in infancy." *Proceedings of the Conference on Cognitive Computational Neuroscience*. 2019.](https://www.semanticscholar.org/paper/A-quantitative-model-of-the-language-familiarity-in-Thorburn-Feldman/120328aabaa4570ea6dc6278d537671c7b2d30c7?p2df)
