#!/usr/bin/env python

import sys
import os
import numpy as np
import matplotlib.pyplot as plt

parfiles = sorted(sys.argv[1:])

for p in parfiles:

	par = np.loadtxt(p, comments='C')
	base = os.path.splitext( os.path.basename( p ) )[0]
	par[:,1:4] = np.radians( par[:,1:4] ) # Convert Euler angles to radians
	par[:,1:4] = np.degrees( np.arctan2( np.sin( par[:,1:4] ), np.cos( par[:,1:4] ) ) ) # Convert Euler angles to the -180,+180 range
	par[:,11] = par[:,11] / 100.0 # Have occupancies between 0 and 1
	avgdef = 0.5 * ( par[:,8] + par[:,9] ) # Average defocus
	# filmlist = np.unique( par[:,7] ) # List of film indices
	# print len(filmlist)

	# Check entries with negative defocus:
	# sel = avgdef < 0
	# print np.sum(sel)

	# PSI
	plt.clf()
	plt.hist( par[:,1], bins=360, range=[-180.0,+180.0], weights=par[:,11] )
	plt.title( 'PSI distribution for '+ p )
	plt.xlabel( 'PSI [degrees]' )
	plt.ylabel( 'Counts' )
	plt.savefig( base + '_psi_dist.png', dpi=300 )

	# THETA
	plt.clf()
	plt.hist( par[:,2], bins=360, range=[-180.0,+180.0], weights=par[:,11] )
	plt.title( 'THETA distribution for '+ p )
	plt.xlabel( 'THETA [degrees]' )
	plt.ylabel( 'Counts' )
	plt.savefig( base + '_theta_dist.png', dpi=300 )

	# PHI
	plt.clf()
	plt.hist( par[:,3], bins=360, range=[-180.0,+180.0], weights=par[:,11] )
	plt.title( 'PHI distribution for '+ p )
	plt.xlabel( 'PHI [degrees]' )
	plt.ylabel( 'Counts' )
	plt.savefig( base + '_phi_dist.png', dpi=300 )

	# AVGDEF
	plt.clf()
	plt.hist( avgdef, bins=100, weights=par[:,11] )
	plt.title( 'Average defocus distribution for '+ p )
	plt.xlabel( 'Average defocus [Angstrom]' )
	plt.ylabel( 'Counts' )
	plt.savefig( base + '_avgdef_dist.png', dpi=300 )

	# FILMCOUNT
	plt.clf()
	plt.hist( par[:,7], bins=np.max( par[:,7] ), weights=par[:,11] )
	plt.title( 'Film origin distribution for '+ p )
	plt.xlabel( 'Film #' )
	plt.ylabel( 'Counts' )
	plt.savefig( base + '_film_dist.png', dpi=300 )
