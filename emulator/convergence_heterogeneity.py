from __future__ import division

import numpy as np
from random import random
from random import seed
from random import shuffle

import matplotlib.pyplot as plt
import pandas as pd

from one_pass_token_smart_timing_heter import one_pass

#Specific to this experiment
Nlist=[2,3,4,5,8,10,12,15,18,20]
#Nlist=[2,3]
Nacclist=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
#Nacclist=[1,2,3]
autostop=True
circular=True
smart_time=False
eps=1.5
norm=1
Nway=16#17 for random
#Common between all experiments
Tstep_avg=100
Tstep_range=10
Navg_need=100
Npass=100

#Only used for Smart timing
refresh_max=10
refresh_min=10

conv_time=np.zeros(Npass)
num_exch=np.zeros(Npass)
maxerr=np.zeros(Npass)
initial_err=np.zeros(Npass)
nb_noncov=0

#File write
conv_file = "conv_het_file.csv"
err_file = "err_het_file.csv"

GEN_CSV=1

def convergence_heterogeneity():
	u=0
	v=0

	#print("Nacc,N,conv_time,num_exch,mean_err,max_err,num_nonconvergence,num_emergencies")
	conv_timeA=np.zeros((len(Nlist),len(Nacclist)))
	init_errA=np.zeros((len(Nlist),len(Nacclist)))

	if GEN_CSV:
		fconv = open(conv_file, 'w')
		ferr = open(err_file, 'w')

		fconv.write("N,conv_time")
		for i in range(len(Nacclist)):
			fconv.write(",")
		fconv.write("\n")
		ferr.write("N,init_err")
		for i in range(len(Nacclist)):
			ferr.write(",")
		ferr.write("\n")
		for N in Nlist:
			v=0
			fconv.write(str(N)+",")
			ferr.write(str(N)+",")
			for Nacc in Nacclist:
				if(N**2>=Nacc):
					tmax=N*20*Tstep_avg
					Ttot=50*N**2
					nb_noncov=0
					hotspot_iters=np.zeros(Npass)

					for i in range (Npass):
						sq_n,num_exch[i],conv_time[i],foobar,maxerr[i],hotspot_iters[i]=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,smart_time,Nway,refresh_max,refresh_min,Nacc)
						initial_err[i]=sq_n[0]
						if(conv_time[i]==(tmax-1)):
							nb_noncov=nb_noncov+1
							# break

					conv_timeA[u][v]=np.mean(conv_time)
					init_errA[u][v]=np.mean(initial_err)
					fconv.write(str(conv_timeA[u][v]) + ",")
					ferr.write(str(init_errA[u][v]) + ",")
					#fconv.write(str(Nacc)+","+str(N)+","+str(conv_timeA[u][v]))
					#ferr.write(str(Nacc)+","+str(N)+","+str(init_errA[u][v]))
				else:
					fconv.write("0,")
					ferr.write("0,")
				v=v+1
			fconv.write("\n")
			ferr.write("\n")
			u=u+1

		fconv.close()
		ferr.close()

#print("Please use heterogeneity_python_post_process.xls for generating graphs form csv \n")
