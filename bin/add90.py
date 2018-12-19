#!/usr/bin/env python

import sys
import numpy as np

parfilein = sys.argv[1]
parfileout = sys.argv[2]

parin = np.loadtxt(parfilein, comments='C')

parin[:,3] += np.random.randint( 0, 3, parin.shape[0]) * 90.0 # Add multiples of 90 degrees to angle PHI
# print 'WARNING: %s will be overwritten with zeroed alignment (Euler angles and shifts) values and all header information will be lost!' % p
np.savetxt(parfileout, parin, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')