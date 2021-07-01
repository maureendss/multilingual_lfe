Vectors as calculated by Malaviya et al
Taken from https://drive.google.com/file/d/0B47fwl2TZnQaa0s5bDJESno0OTQ/view?resourcekey=0-TXb87Q4OLURZ9i_K5yp1Ag
Github : https://github.com/chaitanyamalaviya/lang-reps

# language vectors
vecs = np.load("lang_vecs.npy", allow_pickle=True,encoding = 'latin1')
vecs.item()['optsrc'+'fra']  # For French
vecs.item()['optsrc'+'ita']  # For Italian
# language cell states
cell_states = np.load("lang_cell_states.npy", allow_pickle=True,encoding = 'latin1')
cell_states.item()['fra'][0]  # For French
cell_states.item()['ita'][0]  # For Italian
