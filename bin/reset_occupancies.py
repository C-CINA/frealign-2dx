#!/usr/bin/env python

import sys
import numpy as np

parfile = sys.argv[1]

print 'WARNING: %s will be overwritten with reset occupancy values and all header information will be lost!' % parfile

par = np.loadtxt(parfile, comments='C')

# par[:,11] = np.random.random((par.shape[0])) * 100.0 # Generate a random class assignment for each particle in each class
par[:,11] = 100.0 # Reset all occupancies to 100.0 %

np.savetxt(parfile, par, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')

print 'Done!'