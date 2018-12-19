#!/usr/bin/env python

import sys
import numpy as np

if len(sys.argv) > 2:

	outfile = sys.argv[3]

else:

	print 'WARNING: %s will be overwritten with randomized occupancy values and all header information will be lost!' % sys.argv[1]
	outfile = sys.argv[1]

par_in = np.loadtxt(sys.argv[1], comments='C')
par_ref = np.loadtxt(sys.argv[2], comments='C')

par_in[:,8:11] = par_ref[:,8:11]

np.savetxt(outfile, par_in, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')