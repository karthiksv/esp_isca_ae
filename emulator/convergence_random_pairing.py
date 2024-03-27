from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

from one_pass_token_smart_timing import one_pass


#Specific to this experiment
N=10
circular=True
autostop=False
eps=1
Npass=100

#Common between all experiments
Tstep_avg=50
Tstep_range=5
tmax=N*20*Tstep_avg
#tmax=3540*10
Ttot=50*N**2
Navg_need=100
norm=1
Nway=16

sq_n=np.zeros(tmax)

err_final_norand=np.zeros(Npass)
err_final_rand=np.zeros(Npass)
max_err=np.zeros(Npass)

linx=np.linspace(0,tmax,tmax)

for i in range (Npass):
	print(i)
	sq_n,foo1,a,foo3,max_err[i],foo5=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,True,16,2000,100)
	err_final_rand[i]=sq_n[a]
print(err_final_rand)
print(max_err)


for i in range (Npass):
	print(i)
	sq_n,foo1,a,foo3,max_err[i],foo5=one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,False,16,2000,100)
	err_final_norand[i]=sq_n[a]
print(err_final_norand)
print(max_err)


plt.hist(err_final_norand, bins=50, alpha=0.7, label="noRand",color="blue",range=[0,10])
plt.hist(err_final_rand, bins=50, alpha=0.7, label="Rand",color="red",range=[0,10])

#n, 
#bins, patches = plt.hist(x=err_final)
#plt.grid(axis='y', alpha=0.75)
plt.xlabel('Value',fontsize=24)
plt.ylabel('Frequency',fontsize=24)
plt.yticks(fontsize=24)
plt.xticks(fontsize=24)
plt.grid()
#plt.title('Err distribution, N='+str(N**2))
ax = plt.gca()
#caption="mu="+"{:.3f}".format(np.average(err_final)) + " sig=" + "{:.3f}".format(np.std(err_final)) + " max=" + "{:.3f}".format(np.amax(err_final))
#ax.text(0.5,1,transform = ax.transAxes)
#maxfreq = n.max()
np.savetxt("err_worand"+str(N)+"x"+str(N)+".csv", err_final_norand, delimiter=",")
np.savetxt("err_wrand"+str(N)+"x"+str(N)+".csv", err_final_rand, delimiter=",")

plt.show()
caption_norand="mu="+"{:.3f}".format(np.average(err_final_norand)) + " sig=" + "{:.3f}".format(np.std(err_final_norand)) + " max=" + "{:.3f}".format(np.amax(err_final_norand))
caption_rand="mu="+"{:.3f}".format(np.average(err_final_rand)) + " sig=" + "{:.3f}".format(np.std(err_final_rand)) + " max=" + "{:.3f}".format(np.amax(err_final_rand))


print(caption_norand)
print(caption_rand)
