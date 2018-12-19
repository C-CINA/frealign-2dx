#!/usr/bin/env python

import sys
import numpy as np

k_list = []
par_list = []

for arg in sys.argv[1:]:

	if arg[-4:] == '.par':

		par_list.append(arg)

	else:

		k_list.append(int(arg))

# parfiles = sorted(sys.argv[1:-1])
# k = int(sys.argv[-1]) - 1
parfiles = sorted(par_list)
k_list = np.array(k_list) - 1


K = len(parfiles)
# print K
par = np.loadtxt(parfiles[0], comments='C')

parmat = np.zeros( (par.shape[0], par.shape[1], K) )
# print parmat.shape
parmat[:,:,0] = par

occ = np.zeros( ( par.shape[0], K ) )
occ[:,0] = parmat[:,11,0]

i = 1
for p in parfiles[1:]:

	parmat[:,:,i] = np.loadtxt(p, comments='C')
	occ[:,i] = parmat[:,11,i]

	i += 1

# Select when the sum of desired classes occupancies is higher than the others:

# # Sum the occupancies of the desired classes:
# sumocc = np.reshape(np.sum(occ[:,k], axis=1), (par.shape[0], 1))
# idx = np.argmax( occ[:,k], axis=1 ) # Find which of the desired classes has higher occupancy for each particle

# # Check which particles have sum of the desired occupancies greater than the others:
# compare = sumocc >= occ

# # Create boolean array for selecting only the desired particles:
# sel = np.all(compare, axis=1)

idx = np.argmax( occ, axis=1 )
# print idx[:10]
sel = np.zeros((par.shape[0], 1), dtype=bool)

for k in k_list:

	sel += (idx == k).reshape(((par.shape[0], 1)))

# print sum(sel)
# sel = np.where( idx == k )[0]
sel = np.where( sel == True )[0]
# print len(idx)
# print len(sel)
out = parmat[sel,:,idx[sel]]
# print out.shape
# print out[0,:]
# print 'Writing .par file with %d/%d particles from class %d...' % (out.shape[0], par.shape[0], k+1)
print 'Writing .par file with %d/%d particles from class(es)' % (out.shape[0], par.shape[0]), k_list+1,'...'
# np.savetxt(parfiles[0][:-6]+'class'+str(k+1)+'.par', out, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')
np.savetxt(parfiles[0][:-6]+'selected.par', out, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')
print 'Done!'