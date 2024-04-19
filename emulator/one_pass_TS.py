from __future__ import division

import numpy as np
from random import random
from random import seed
import matplotlib.pyplot as plt

DEBUG = False

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
	

	total_pool_tokens = 0
	GREEDY = True
	break_flag = False
	DEBUG2=0

	#Thermal emergency - init params
	hotspot = 0
	last_hotspot = np.zeros((N,N))

	#Initialize the tokens needs, has and timer

	agents_refresh=((np.random.rand(N,N)-0.5)*Tstep_range*2+Tstep_avg).astype(int)
	agents_needs=(np.random.rand(N,N)*Navg_need*2).astype(int)
	agents_has=np.zeros((N,N))
	agents_timer=np.zeros((N,N))
	starving=np.zeros((N,N))
	agents_corner=(np.random.rand(N,N)*4).astype(int)#0-3 as N,S,E,W
	fair_token_count = Ttot/(N**2)

	sq_error=np.zeros(tmax)
	
	agents_ref_monitored=np.zeros((6,tmax))
	
	total_exchanges=0
	total_hops=0
	num_hotspots = 0	# num instances of hotspots
	i=0
	cycles = 0

	for k in range(Ttot):
		x=int(random()*N)
		y=int(random()*N)
		agents_has[x][y]=agents_has[x][y]+1
		
	#Compute optimal allocation
	fair_token_count_array = fair_token_count*np.ones((N,N))
	fair_token_count_array = np.minimum(agents_needs,fair_token_count_array)
	#Tleftover=Ttot-np.sum(fair_token_count_array)
	#while (Tleftover>0) :
	#	for node in range(N**2):
	#		x = int(node/N)
	#		y = node % N
	#		if ((agents_needs[x][y]>fair_token_count_array[x][y]) and Tleftover>0):
	#			fair_token_count_array[x][y]=fair_token_count_array[x][y]+1
	#			Tleftover=Tleftover-1

	#Run the script
	while (i<tmax):
		for node in range(N**2):	#Traverse across all nodes one by one
			#node_id = x*N+y	
			x = int(node/N)
			y = node % N


			if (agents_has[x][y]>agents_needs[x][y]):
				give_tokens=agents_has[x][y]-agents_needs[x][y]
				total_pool_tokens=total_pool_tokens+give_tokens
				agents_has[x][y]=agents_has[x][y]-give_tokens
			
			else:
				if (total_pool_tokens==0):
					GREEDY=False
					starving[x][y]=True
						
				else:	
					take_tokens=min(total_pool_tokens,agents_needs[x][y]-agents_has[x][y])
					total_pool_tokens=total_pool_tokens-take_tokens
					agents_has[x][y]=agents_has[x][y]+take_tokens
					if(starving[x][y]):#if this tile was starving before now it's not and we reset the pool to GREEDY
						starving[x][y]=False
						GREEDY=True
			if(not(GREEDY) and (agents_has[x][y]>fair_token_count)):
				give_tokens=agents_has[x][y]-fair_token_count
				total_pool_tokens=total_pool_tokens+give_tokens
				agents_has[x][y]=agents_has[x][y]-give_tokens

					
			#Compute hotspots, when has>=max for the tiles and all its neighbors
			if (i>0 and agents_has[x][y]>0):	#thermal emergency only when tile is active for more than 1 iteration and after 1st iteration 
				if (last_hotspot[x][y]==1):
					hotspot = is_hotspot(agents_has, agents_needs, x, y, N) 
				last_hotspot[x][y] = 1					
			else:
				hotspot = 0
				last_hotspot[x][y] = 0

			num_hotspots =  num_hotspots + hotspot
			
			
			if (norm==1):
				sq_error[i]=np.sum((-agents_has+fair_token_count_array).clip(0))*1.0/(N**2)
			elif(norm==2):
				sq_error[i]=np.sum((agents_has-fair_token_count_array)**2)*1.0/(N**2)
			elif(norm==0):
				sq_error[i]=np.max(abs(agents_has-fair_token_count_array))	



			if(autostop and sq_error[i]<=eps):
				break_flag = True
				if DEBUG2:
					print(sq_error[i])
					print("Converged")
				break
			#if(total_pool_tokens==0):
			#	break_flag = True
			#	if DEBUG:
			#		print("Pool empty")
			#	break
			if (i==(tmax-1)):
				break_flag = True
				if DEBUG2:
					print("Timeout")
					print(str(i)+": Error: ", sq_error[i])
					print("Has: ",agents_has)
					print("Needs: ",agents_needs)
					print("Target: ",fair_token_count_array)

				break
				
			i = i+1
			if DEBUG:
				print(str(i)+": Error: ", sq_error[i])
				print("Has: ",agents_has)
				print("Needs: ",agents_needs)
				print("Pool: ",total_pool_tokens)
			
			#Increment cycles by one to move to the next tile in the sequence
			cycles = cycles + Tstep_avg	

		if (break_flag):
			break
				
	#plt.plot(sq_error);
	return(sq_error[i-1],total_exchanges,cycles,np.max(abs(agents_has-fair_token_count_array)), num_hotspots)
