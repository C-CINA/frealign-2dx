#!/usr/bin/env python

import numpy as np
import sys
import os
import matplotlib.pyplot as plt
from optparse import OptionParser


def main():

	progname = os.path.basename(sys.argv[0])
	usage = progname + """ [options] <par file1> <par file2> ... <par fileN>

	Given one or more FREALIGN .par files, generates a new .par file for each of them, with modified alignment parameters.

	Output:

		-New .par file(s)

	 """

	parser = OptionParser(usage)
	
	parser.add_option("--add", metavar='"0.0 0.0 0.0 0.0 0.0"', default="0 0 0 0 0", type="string", help="Five real numbers to be added to the parameters (PSI, THETA, PHI, SHX, SHY). PSI, THETA and PHI in degrees, SHX and SHY in Angstroems.")
	
	parser.add_option("--out", metavar="reoriented", type="string", default="reoriented", help="Output string to be appended to the .par file name.")

	(options, args) = parser.parse_args()

	command = ' '.join(sys.argv)

	if options.out == None:

		options.out = 'reoriented'

	parfiles = sorted(args)

	add = np.zeros((5), dtype=float)
	if options.add != None:

		addstr = options.add.split()

		for i in np.arange(5):

			add[i] = float(addstr[i])

	for p in parfiles:

		par = np.loadtxt(p, comments='C')

		par[:,1:6] += add

		np.savetxt(p[:-4]+'-'+options.out+'.par', par, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%d', '%.2f', '%.2f', '%.2f', '%.2f', '%d', '%.4f', '%.2f', '%.2f'], delimiter='    ')

if __name__ == "__main__":
	main()