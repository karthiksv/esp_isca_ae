from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

from one_pass_token_4way import one_pass

#Specific to this experiment
Nlist=[3,4,5,8,10,12,15,18,20]
circular=True
autostop=True
smart_time=False
eps=1.5
norm=1
Nway=16

#To account for the fact that each 4-way exchange takes 6x more packers than a 1-way exchange, time between 4-way exchanges is increased by 6x
Tstep_avg=6*100
Tstep_range=6*10
Navg_need=100
Npass=100


#Unused as dynamic timing is disabled
refresh_max=100
refresh_min=100

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
		sq_n,conv_time[i],maxerr[i],num_exch[i]=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,True)
	print(N,np.average(conv_time,weights=(conv_time<tmax-1)),np.average(num_exch,weights=(conv_time<tmax-1)),nb_noncov)
