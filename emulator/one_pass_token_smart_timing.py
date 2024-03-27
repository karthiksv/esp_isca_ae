from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

def is_hotspot(a_has, a_needs, x, y, N):
	center_val = a_has[x][y]-a_needs[x][y]
	west_val = a_has[x-1][y]-a_needs[x-1][y] if x>0 else -1
	east_val = a_has[x+1][y]-a_needs[x+1][y] if x<N-1 else -1
	south_val = a_has[x][y-1]-a_needs[x][y-1] if y>0 else -1
	north_val = a_has[x][y+1]-a_needs[x][y+1] if y<N-1 else -1

	diff_arr = np.array([center_val,west_val,east_val,south_val,north_val])
		
	return int((diff_arr>=0).all())	# if has>=needs for all tiles
	
	

def one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,smart_time,Nway,refresh_max,refresh_min):
	#If autostop, sims breaks after reachingg Err threshold
	#eps: Err threshold
	#N : side of the squre, N^2 agents
	#Ttot total number of tokens available
	#Refresh rate of each tile is random uniform selection between [Tstep_avg-Tstep_range;Tstep_avg+Tstep_range] (ticks unit)
	#tmax max number of ticks to run
	#Token need is andom uniform selection between [0;2*Navg_need]
	#If circluar, connections are made betwen bottom/top and left/right
	#Norm: Norm used to measure the total error 1 or 2. 1: sum of abs, 2 sum of squares 
	#smart_time: Enable exponential backoff 
	

	a_up=1.5
	a_down=0.25

	#Thermal emergency - init params
	hotspot = 0
	last_hotspot = np.zeros((N,N))

	if(circular and N>2): #Loop around array
		xmin=-1
		ymin=-1
		xmax=N
		ymax=N
	else:
		xmin=0
		ymin=0
		xmax=N-1
		ymax=N-1
	
	#Initialize the tokens needs, has and timer

	agents_refresh=((np.random.rand(N,N)-0.5)*Tstep_range*2+Tstep_avg).astype(int)
	agents_needs=(np.random.rand(N,N)*Navg_need*2).astype(int)
	agents_has=np.zeros((N,N))
	agents_timer=np.zeros((N,N))
	agents_corner=(np.random.rand(N,N)*4).astype(int)#0-3 as N,S,E,W

	sq_error=np.zeros(tmax)
	
	agents_ref_monitored=np.zeros((6,tmax))
	
	total_exchanges=0
	total_hops=0
	num_hotspots = 0	# num instances of hotspots

	for i in range(Ttot):
		x=int(random()*N)
		y=int(random()*N)
		agents_has[x][y]=agents_has[x][y]+1
	
	#agents_has=np.zeros((N,N))+Ttot/N**2
	#Run the script
	for i in range(tmax):
		agents_timer=agents_timer+1
		agents_ref_monitored[0][i]=agents_refresh[0][0]
		agents_ref_monitored[1][i]=agents_refresh[min(2,N-1)][min(2,N-1)]
		agents_ref_monitored[2][i]=agents_refresh[min(7,N-1)][min(5,N-1)]
		agents_ref_monitored[3][i]=np.average(agents_refresh)
		agents_ref_monitored[4][i]=np.min(agents_refresh)
		agents_ref_monitored[5][i]=np.max(agents_refresh)
		if (norm==1):
			sq_error[i]=np.sum(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs))))/(N**2)
		elif(norm==2):
			sq_error[i]=np.sum((agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs)))**2)**0.5
		elif(norm==0):
			sq_error[i]=np.max(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs))))	
				
		if(i%Tstep_avg==0 and N>30):
			print(100*i/tmax)
			print(sq_error[i])
		if(autostop and sq_error[i]<eps):
			break;		
					
		for x in range(N):
			for y in range(N):
				if(agents_timer[x][y]>=agents_refresh[x][y]):
					agents_timer[x][y]=0
					self_n=agents_needs[x][y]
					self_h=agents_has[x][y]
					
					#Default
					xother=x
					yother=y
					
					if((agents_corner[x][y]==0 or agents_corner[x][y]==4 or agents_corner[x][y]==8 or agents_corner[x][y]==12) and x>xmin):
						xother=(x-1)%N
						yother=y
					if((agents_corner[x][y]==1 or agents_corner[x][y]==5 or agents_corner[x][y]==9 or agents_corner[x][y]==13) and y>ymin):
						xother=x
						yother=(y-1)%N
					if((agents_corner[x][y]==2 or agents_corner[x][y]==6 or agents_corner[x][y]==10 or agents_corner[x][y]==14) and x<xmax):
						xother=(x+1)%N
						yother=y
					if((agents_corner[x][y]==3 or agents_corner[x][y]==7 or agents_corner[x][y]==11 or agents_corner[x][y]==15) and y<ymax):
						xother=x
						yother=(y+1)%N		
					if(agents_corner[x][y]==16):
						xother=int(random()*N)
						yother=int(random()*N)
																											
					other_n=agents_needs[xother][yother]
					other_h=agents_has[xother][yother]
					if((self_n+other_n)>0):
						#Npassed=round(self_n*(self_h+other_h)/(self_n+other_n)-self_h)
						Npassed=round((self_n*other_h-self_h*other_n)/(self_n+other_n))
					else:
						Npassed=round((self_h+other_h)/2)
					agents_has[xother][yother]=agents_has[xother][yother]-Npassed
					agents_has[x][y]=agents_has[x][y]+Npassed
					
					if(Npassed>=0):
						total_exchanges=total_exchanges+2;#*(abs(x-xother)+abs(y-yother))
						total_hops=total_hops+2*(abs(x-xother)+abs(y-yother));
					else:
						total_exchanges=total_exchanges+1;#*(abs(x-xother)+abs(y-yother))
						total_hops=total_hops+1*(abs(x-xother)+abs(y-yother));
					#total_exchanges=total_exchanges+2						
					if(Npassed==0 and smart_time and (xother!=x or yother!=y)):
						agents_refresh[x][y]=min(agents_refresh[x][y]*a_up,refresh_max)
						agents_refresh[xother][yother]=min(agents_refresh[xother][yother]*a_up,refresh_max)
					elif(smart_time and (xother!=x or yother!=y)):
						agents_refresh[x][y]=max(agents_refresh[x][y]*a_down,refresh_min)
						agents_refresh[xother][yother]=max(agents_refresh[xother][yother]*a_down,refresh_min)
										
					agents_corner[x][y]=(agents_corner[x][y]+1)%Nway
					
					#Compute hotspots, when has>=max for the tiles and all its neighbors
					if (i>0 and agents_has[x][y]>0):	#thermal emergency only when tile is active for more than 1 iteration and after 1st iteration 
							if (last_hotspot[x][y]==1):
								hotspot = is_hotspot(agents_has, agents_needs, x, y, N) 
							last_hotspot[x][y] = 1					
					else:
						hotspot = 0
						last_hotspot[x][y] = 0

					num_hotspots =  num_hotspots + hotspot
				
						
	#plt.plot(sq_error);

	return(sq_error,total_exchanges,i,agents_ref_monitored,np.max(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs)))), num_hotspots)
	
