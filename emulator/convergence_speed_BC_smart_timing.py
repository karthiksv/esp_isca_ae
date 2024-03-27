from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

#from one_pass_token import one_pass
from one_pass_token_smart_timing import one_pass

#Specific to this experiment
Nlist=[3,4,5,8,10,12,15,18,20]
#Nlist=[18]
circular=True
autostop=True
smart_time=True
eps=1.5
norm=1
Nway=16
Tstep_avg=100
Tstep_range=10
Navg_need=100
Npass=100

refresh_max=2000
refresh_min=28

conv_time=np.zeros(Npass)
num_exch=np.zeros(Npass)
maxerr=np.zeros(Npass)
nb_noncov=0

print("N,conv_time,num_exch,num_nonconv")
for N in Nlist:
	tmax=N*200*Tstep_avg
	Ttot=50*N**2
	nb_noncov=0
	hotspot_iters=np.zeros(Npass)
	for i in range (Npass):
		sq_n,num_exch[i],conv_time[i],foobar,maxerr[i],hotspot_iters[i]=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,smart_time,Nway,refresh_max,refresh_min)
	print(N,np.mean(conv_time),np.mean(num_exch),nb_noncov)

