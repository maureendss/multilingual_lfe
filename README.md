# Language Familiarity Effect (LFE)

- Inspired from Thorburn et al (2019)



## How To 

### Prepare Interface

1. Fill out the `kaldi_setup/cmd.sh` and `kaldi_setup/path.sh` accordingly with your setup.

2. Link all files from `kaldi_setup` and `abx` into appropriate local folders (this is where the output of your experiments will go). *Consider creating this local folders into a place with enough storage*.
   ```
   mkdir -p local/kaldi_setup
   mkdir -p local/abx
   cd local/kaldi_setup && ln -s ../../kaldi_setup/* . && cd ../..
   cd local/abx && ln -s ../../abx/* . && cd ../..
   ```

3. Activate Conda Environment.  __TODO : Give info on env__

### Data Preparation

* Prepares data from any language in the LibriVox database. 

1. Follow instructions from the [data preparation repository](https://github.com/maureendss/data_preparation) (tab : Librivox).
2. Run `kaldi_setup/local/data_prep/prepare_librivox.sh` with the correct arguments.

*__Todo__ : Give more info / examples in this section*

### Train LFE. 


5. Run local/run_cogsci.sh : `cd local/kaldi_setup && local/run_cogsci.sh`

6. Run the ABX tests : `cd ../abx/ && ./run_by_spk.sh EMIME-controlled`

7. Retrieve the scores : `./retrieve_scores.sh EMIME-controlled > EMIME-controlled.byspk.scores.txt

*Note : Results are prone to minor changes due to the randomness in computing MFCC features*

--------------------

## References

[Thorburn, Craig A., Naomi H. Feldman, and Thomas Schatz. "A quantitative model of the language familiarity effect in infancy." *Proceedings of the Conference on Cognitive Computational Neuroscience*. 2019.](https://www.semanticscholar.org/paper/A-quantitative-model-of-the-language-familiarity-in-Thorburn-Feldman/120328aabaa4570ea6dc6278d537671c7b2d30c7?p2df)
