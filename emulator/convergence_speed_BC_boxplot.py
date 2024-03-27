from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

from one_pass_token_smart_timing import one_pass

#Specific to this experiment
Nlist=[4,8,12,16,20]
circular=True
autostop=True
smart_time=False
eps=1.5
norm=1
Nway=16
#Common between all experiments
Tstep_avg=100
Tstep_range=10
Navg_need=100
Npass=1000

refresh_max=100
refresh_min=100

conv_time=np.zeros(Npass)
num_exch=np.zeros(Npass)
maxerr=np.zeros(Npass)
nb_noncov=0

print("N,conv_time,num_exch,mean_err,max_err,num_nonconvergence")
myfile=open("BC_boxplot.csv", "w")
for N in Nlist:
	tmax=N*200*Tstep_avg
	Ttot=50*N**2
	nb_noncov=0
	hotspot_iters=np.zeros(Npass)
	for i in range (Npass):
		sq_n,num_exch[i],conv_time[i],foobar,maxerr[i],hotspot_iters[i]=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,smart_time,Nway,refresh_max,refresh_min)
		if(conv_time[i]==(tmax-1)):
			nb_noncov=nb_noncov+1
			break
		myfile.write(str(N)+ " " + str(conv_time[i]) +"\n")	

	print(N,np.mean(conv_time),np.max(conv_time),np.min(conv_time))
	

