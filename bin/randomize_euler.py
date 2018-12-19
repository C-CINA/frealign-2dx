#!/usr/bin/env python

import sys
import numpy as np

parfiles = sorted(sys.argv[1:])

par = np.loadtxt(parfiles[0], comments='C')

for p in parfiles:

	par = np.loadtxt(p, comments='C')
	par[:,1:4] = np.random.random((par.shape[0],3)) * 360.0 # Generate random Euler angles
	print 'WARNING: %s will be overwritten with randomized occupancy values and all header information will be lost!' % p
	np.savetxt(p, par, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')