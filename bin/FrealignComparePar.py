#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import os
import sys

# par_initial = '/home/ricardo/Dropbox/Biozentrum/Events/LabRetreat_2016/data/cAMP-2015-November_frealign_prerefine-5.4-initial.par'
# par_final = '/home/ricardo/Dropbox/Biozentrum/Events/LabRetreat_2016/data/cAMP-2015-November_frealign_prerefine-5.4.par'
# diff_out = '/home/ricardo/Dropbox/Biozentrum/Events/LabRetreat_2016/data/cAMP-2015-November_frealign_prerefine-5.4-diff.txt'
# par_initial = '/scratch/data/MloK1/cAMP-2015-November/frealign/C4_134/pre-refine/FBOOST_F/gctf/MloK1_1_r1.par'
# par_final = '/scratch/data/MloK1/cAMP-2015-November/frealign/C4_134/pre-refine/FBOOST_F/gctf/MloK1_10_r1.par'
# diff_out = '/scratch/data/MloK1/cAMP-2015-November/frealign/C4_134/pre-refine/FBOOST_F/gctf/MloK1_1-10_diff.txt'

par_initial = sys.argv[1]
par_final = sys.argv[2]
diff_out = sys.argv[3]

euler = ['TLTAXIS', 'TLTANG', 'TAXA']

ini = np.loadtxt(par_initial, comments='C')

fin = np.loadtxt(par_final, comments='C')

# print np.min(ini[:,2])
# print np.max(ini[:,2])

ini[:,1:4] = np.radians(ini[:,1:4])

fin[:,1:4] = np.radians(fin[:,1:4])

# inisin = np.sin(ini[:,1:4])
# inicos = np.cos(ini[:,1:4])
# finsin = np.sin(fin[:,1:4])
# fincos = np.cos(fin[:,1:4])
sin = np.sin(ini[:,1:4]-fin[:,1:4])
cos = np.cos(ini[:,1:4]-fin[:,1:4])

# diff = np.zeros((np.shape(ini)[0],6))
mediandiff = np.zeros((1,3))
meandiff = np.zeros((1,3))
stddiff = np.zeros((1,3))

# for i in np.arange(3):

# 	# diff[:,i] = np.degrees(np.arctan2(inisin[:,i]-finsin[:,i], inicos[:,i]-fincos[:,i]))
# 	diff[:,i] = np.degrees(np.arctan2(sin[:,i], cos[:,i]))
diff = ini[:,:6]
diff[:,1:4] = np.degrees(np.arctan2(sin, cos))
diff[:,4:6] = ini[:,4:6]-fin[:,4:6]
# 	meandiff[0,i] = np.degrees(np.arctan2(np.mean(np.sin(np.radians(diff[:,i]))), np.mean(np.cos(np.radians(diff[:,i])))))
# 	stddiff[0,i] = np.degrees(np.arctan2(np.std(np.sin(np.radians(diff[:,i]))), np.std(np.cos(np.radians(diff[:,i])))))
# 	mediandiff[0,i] = np.degrees(np.arctan2(np.median(np.sin(np.radians(np.abs(diff[:,i])))), np.median(np.cos(np.radians(np.abs(diff[:,i]))))))

# 	print '%s difference: %.2f mean, %.2f standard deviation' % (euler[i], meandiff[0,i], stddiff[0,i])
# 	print '%s max abs. difference: %.2f' % (euler[i], np.max(np.abs(diff[:,i])))
# 	print '%s min abs. difference: %.2f' % (euler[i], np.min(np.abs(diff[:,i])))
# 	print '%s median abs. difference: %.2f' % (euler[i], mediandiff[0,i])

# 	plt.clf()
# 	plt.hist(diff[:,i],bins=120,range=[-180.0,+180.0])
# 	plt.title(euler[i]+' change in pre-refinement')
# 	plt.xlabel('Change [degrees]')
# 	plt.ylabel('# of crystals')
# 	plt.savefig(os.path.dirname(diff_out)+'/'+euler[i]+'_change_hist.png',dpi=300)

# deltasig = np.degrees(np.arccos(np.sin(ini[:,2]) * np.sin(fin[:,2]) + np.cos(ini[:,2]) * np.cos(fin[:,2]) * np.cos(ini[:,1]-fin[:,1])))
# plt.clf()
# plt.hist(deltasig,bins=180,range=[0,+180.0])
# plt.title('Angular change during pre-refinement (normal vector)')
# plt.xlabel('Change [degrees]')
# plt.ylabel('# of crystals')
# plt.savefig(os.path.dirname(diff_out)+'/'+'angular_change_hist.png',dpi=300)

# shxabs = np.abs(fin[:,4])
# print 'SHX difference: %.2f mean, %.2f standard deviation' % (np.mean(fin[:,4]), np.std(fin[:,4]))
# print 'SHX max abs. difference: %.2f' % (np.max(shxabs))
# print 'SHX min abs. difference: %.2f' % (np.min(shxabs))
# print 'SHX median abs. difference: %.2f' % (np.median(shxabs))

# plt.clf()
# plt.hist(fin[:,4],bins=25)
# plt.title('SHX change during pre-refinement')
# plt.xlabel('Change [Angstroems]')
# plt.ylabel('# of crystals')
# plt.savefig(os.path.dirname(diff_out)+'/'+'SHX_change_hist.png',dpi=300)

# shyabs = np.abs(fin[:,5])
# print 'SHY difference: %.2f mean, %.2f standard deviation' % (np.mean(fin[:,5]), np.std(fin[:,5]))
# print 'SHY max abs. difference: %.2f' % (np.max(shyabs))
# print 'SHY min abs. difference: %.2f' % (np.min(shyabs))
# print 'SHY median abs. difference: %.2f' % (np.median(shyabs))

# plt.clf()
# plt.hist(fin[:,5],bins=25)
# plt.title('SHY change during pre-refinement')
# plt.xlabel('Change [Angstroems]')
# plt.ylabel('# of crystals')
# plt.savefig(os.path.dirname(diff_out)+'/'+'SHY_change_hist.png',dpi=300)

# shxyabs = np.sqrt(np.sum(fin[:,4:6]**2,1))
# print 'Translational difference: %.2f mean, %.2f standard deviation' % (np.mean(shxyabs), np.std(shxyabs))
# print 'Translational max abs. difference: %.2f' % (np.max(shxyabs))
# print 'Translational min abs. difference: %.2f' % (np.min(shxyabs))
# print 'Translational median abs. difference: %.2f' % (np.median(shxyabs))

# plt.clf()
# plt.hist(shxyabs,bins=50)
# plt.title('Translational change during pre-refinement')
# plt.xlabel('Change [Angstroems]')
# plt.ylabel('# of crystals')
# plt.savefig(os.path.dirname(diff_out)+'/'+'translational_change_hist.png',dpi=300)

np.savetxt(diff_out, diff, fmt=['%d', '%.2f', '%.2f', '%.2f', '%.2f', '%.2f'], delimiter='\t')