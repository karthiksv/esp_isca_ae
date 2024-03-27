from __future__ import division

import numpy as np
from random import random
from random import seed
from random import shuffle

import matplotlib.pyplot as plt

from one_pass_token_smart_timing_heter import one_pass

#Specific to this experiment
Nlist=[2,3,4,5,8,10,12,15,18,20]
Nacclist=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
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

print("N,conv_time,num_exch,mean_err,max_err,num_nonconvergence,num_emergencies")
conv_timeA=np.zeros((len(Nacclist),len(Nlist)))
init_errA=np.zeros((len(Nacclist),len(Nlist)))

u=0
v=0
for Nacc in Nacclist:
	v=0
	for N in Nlist:
		print(Nacc,N)
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
			#	break
			conv_timeA[u][v]=np.mean(conv_time)
			init_errA[u][v]=np.mean(initial_err)
		v=v+1
	u=u+1

print(conv_timeA)
print(init_errA)
