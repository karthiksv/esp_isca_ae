from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

#Constants
C_TS = 0.21
C_CRR = 0.96
C_BCC = 0.66
C_BC = 0.2
C_PT = np.power(10,-2.5)

#X values
Tw=np.array((0.02, 0.05, 0.2, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 20, 25, 30))
Tw_pt = np.array((0.038, 0.057, 1.42, 1.54, 6.62, 7.9, 0.21, 0.3, 1.82, 2.67, 9.74, 11.4))
Nmax_pt = np.array((4, 4, 16, 16, 256, 256, 4, 4, 16, 16, 256, 256))
N=np.array(range(4,260,4))

def NMax(c, type):
	if (type==0):	#centralized
		return np.sqrt(1000*Tw/c)
	else:		#decentralized
		return np.cbrt(np.square(1000*Tw/c))

def Overhead(c, type):
	if (type==0):	#centralized
		tran_duration = c*0.001*N
	else:		#decentralized
		
		tran_duration = c*0.001*np.sqrt(N)
	return N*tran_duration/10
	
	

def main():
	nmax_ts = NMax(C_TS, 0)
	nmax_crr = NMax(C_CRR, 0)
	nmax_bcc = NMax(C_BCC, 0)
	nmax_bc = NMax(C_BC, 1)
	scaled_Tw_pt = C_PT*Tw_pt*Nmax_pt
	
	overhead_ts = Overhead(C_TS, 0)
	overhead_crr = Overhead(C_CRR, 0)
	overhead_bcc = Overhead(C_BCC, 0)
	overhead_bc = Overhead(C_BC, 1)
	overhead_pt = scaled_Tw_pt/10

	print(overhead_pt)

	plt.figure('Maximum supported accelerators')	
	plt.plot(Tw, nmax_ts, color='orange')
	plt.plot(Tw, nmax_crr, color='red')
	plt.plot(Tw, nmax_bcc, color='grey')
	plt.plot(Tw, nmax_bc, color='blue')
	plt.scatter(scaled_Tw_pt, Nmax_pt, color='green', marker='s')

	plt.xlabel('Tw (ms)')
	plt.ylabel('NMax')
	plt.legend(['TS', 'CR-R', 'BC-C', 'BC'], loc='upper left')

	ax=plt.gca()
	ax.set_xlim([0,10])
	ax.set_ylim([0,1400])

	plt.show()

	plt.figure('PM Overhead')	
	plt.plot(N, overhead_ts, color='orange')
	plt.plot(N, overhead_crr, color='red')
	plt.plot(N, overhead_bcc, color='grey')
	plt.plot(N, overhead_bc, color='blue')
	plt.scatter(Nmax_pt, overhead_pt, color='green', marker='s')

	plt.legend(['TS', 'CR-R', 'BC-C', 'BC'], loc='upper left')
	plt.xlabel('Number of tiles (N)')
	plt.ylabel('PM Overhead (%)')

	ax=plt.gca()
	ax.set_ylim([0,1])
	ax.set_yticklabels([f'{x:.0%}' for x in ax.get_yticks()]) 

	plt.show()

if __name__ == "__main__":
	main()



