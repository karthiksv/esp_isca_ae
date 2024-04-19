from __future__ import division

import numpy as np
from random import random
import random as r
from random import seed
import matplotlib.pyplot as plt
from enum import Enum

#Enumerate directions
CENTER, NORTH, SOUTH, EAST, WEST = range(5)
DEBUG = 0
extra_rand=False
RAND_INTERVAL=1000
MIN_EXCHANGE=1
IF_PARALLEL=1

def one_pass(autostop,eps,N,Ttot,Tstep_avg,Tstep_range,tmax,Navg_need,circular,norm,exc_count):
	#If autostop, sims breaks after reachingg Err threshold
	#eps: Err threshold
	#N : side of the squre, N^2 agents
	#Ttot total number of tokens available
	#Refresh rate of each tile is random uniform selection between [Tstep_avg-Tstep_range;Tstep_avg+Tstep_range] (ticks unit)
	#tmax max number of ticks to run
	#Token need is andom uniform selection between [0;2*Navg_need]
	#If circluar, connections are made betwen bottom/top and left/right
	#Norm: Norm used to measure the total error 1 or 2. 1: sum of abs, 2 sum of squares 
	#exc_count: if True, returns the total number of token exchanges rahter than the number of ticks

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
	tot_time=0
	for x in range(0,N):
		for y in range(0,N):
			if (agents_needs[x][y]==0):
				agents_needs[x][y]=1

	agents_has=np.zeros((N,N))
	agents_timer=np.zeros((N,N))
	#nb_has_list=np.zeros((N,N,4))		#monitor neighbor's tokens
	#nb_needs_list=np.zeros((N,N,4))	#monitor neighbor's tokens
	#agents_corner=(np.random.rand(N,N)*16).astype(int)#0-3 as N,S,E,W
	agents_corner=(np.random.rand(N,N)*4).astype(int)#0-3 as N,S,E,W

	sq_error=np.zeros(tmax)
	total_exchanges=0
	old_sq_error=1e8	# some large value

	for i in range(Ttot):
		x=int(random()*N)
		y=int(random()*N)
		agents_has[x][y]=agents_has[x][y]+1

	#print(np.sum(np.sum(agents_has)), Ttot)
		
	#Run the script
	for i in range(tmax):
		if(i%Tstep_avg==0 and N>200):
			print(100*i/tmax)
			
		agents_timer=agents_timer+1
		mean_ratio=np.sum(agents_has)*1.0/np.sum(agents_needs)
		if (norm==1):
			sq_error[i]=np.sum(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs))))/(N**2)
		elif(norm==2):
			sq_error[i]=np.sum((agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs)))**2)/(N**2)
		elif(norm==0):
			sq_error[i]=np.max(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs))))	

		if DEBUG:
			print("Starting error: "+str(i))
			print(sq_error[i], mean_ratio)

		if(autostop and sq_error[i]<eps):
			break;				
		#if (old_sq_error <= sq_error[i]):	#not converging
		#	extra_rand = True
		#else:
		#	extra_rand = False
		###extra_rand = True
		for x in range(N):
			for y in range(N):
				if(agents_timer[x][y]>=agents_refresh[x][y]):
					agents_timer[x][y]=0
					self_n=agents_needs[x][y]
					self_h=agents_has[x][y]
					x_inds=np.array([0,0,0,1,-1])
					y_inds=np.array([0,1,-1,0,0])
					
					xrand=int(random()*N)
					yrand=int(random()*N)
					if((abs(x-xrand)+abs(y-yrand))<2):
						yrand=(y+1)%N
						xrand=x
						
					#if((agents_corner[x][y]%4)<3):
					nb_has_list=np.array([self_h, agents_has[x][(y+1)%N], agents_has[x][(y-1)%N], agents_has[(x+1)%N][y],agents_has[(x-1)%N][y]])
					nb_needs_list=np.array([self_n, agents_needs[x][(y+1)%N], agents_needs[x][(y-1)%N], agents_needs[(x+1)%N][y],agents_needs[(x-1)%N][y]])

					if(extra_rand and i%RAND_INTERVAL==(RAND_INTERVAL-1)):
						#nb_has_list=np.array([self_h, agents_has[x][(y+1)%N], agents_has[x][(y-1)%N], agents_has[(x+1)%N][y],agents_has[(x-1)%N][y]])
						#nb_needs_list=np.array([self_n, agents_needs[x][(y+1)%N], agents_needs[x][(y-1)%N], agents_needs[(x+1)%N][y],agents_needs[(x-1)%N][y]])
						min_tokens_tile=np.where(nb_has_list==np.min(nb_has_list))
						rand_tokens_tile=r.randrange(0,5)	
						if MIN_EXCHANGE:
							selected_tile = min_tokens_tile
						else:
							selected_tile = np.array([rand_tokens_tile])

						tmp_has=nb_has_list[selected_tile]
						if DEBUG:
							print("Old list: ")
							print(agents_has)
							print("Time " +str(i) +" Exchanging tokens... (" +str(xrand) + "," +str(yrand)+"):"+str(agents_has[xrand][yrand])+" and "+str(selected_tile)+": "+str(nb_has_list[selected_tile]))

						nb_has_list[min_tokens_tile] = agents_has[xrand][yrand]
						new_x=(x+x_inds[selected_tile])%N
						new_y=(y+y_inds[selected_tile])%N
						#agents_has[new_x[0]][new_y[0]] = agents_has[xrand][yrand]
						#agents_has[xrand][yrand] = tmp_has[0]
						
						if DEBUG:
							print("New list: ")
							#print(nb_has_list)
							print(agents_has)
							print(new_x[0], new_y[0])
							print("Exchanged tokens... (" +str(xrand) + "," +str(yrand)+"):"+str(agents_has[xrand][yrand])+" and "+str(selected_tile)+": "+str(agents_has[new_x[0]][new_y[0]]))
						#nb_has_list=np.array([self_h, agents_has[xrand][yrand], agents_has[x][(y-1)%N], agents_has[(x+1)%N][y],agents_has[(x-1)%N][y]])
						#nb_needs_list=np.array([self_n, agents_needs[xrand][yrand], agents_needs[x][(y-1)%N], agents_needs[(x+1)%N][y],agents_needs[(x-1)%N][y]])		
	
					nb_ratios=np.zeros(5)

					for nh in range(0,np.size(nb_has_list)):
						nb_ratios[nh] = nb_has_list[nh]/nb_needs_list[nh]	if nb_needs_list[nh]>0 else 0

					deficit_ratio = np.sum(nb_has_list)/np.sum(nb_needs_list)  if np.sum(nb_needs_list)>0 else 0 # avg ratio of has to needs tokens
					
					#avg_deficit_tokens = np.ceil((np.sum(nb_needs_list) - np.sum(nb_has_list))/5)	#average deficit tokens in the system - rounded up
					#if (avg_deficit_tokens<0):
					#	avg_deficit_tokens=0	# No deficit
					if DEBUG:
						print("Starting token count: "+str(i))
						print ("Has: " +str(np.sum(nb_has_list)))
						print (nb_has_list)
						print ("Needs: ")
						print (nb_needs_list)
						print ("Deficit ratio: ")
						print (deficit_ratio)

					surplus_token_pool = 0
					for DIR in range(0,5):
						nb_contribution = np.floor(nb_has_list[DIR]-nb_needs_list[DIR]*deficit_ratio)
						if(nb_contribution > 0):
							#if(nb_contribution <= nb_has_list[DIR]):	
							nb_has_list[DIR] = nb_has_list[DIR] - nb_contribution
							surplus_token_pool = surplus_token_pool + nb_contribution
						else:
							nb_contribution = 0
					
					if DEBUG:
						print("Surplus token count before distribution: "+str(i))
						print (x,y,surplus_token_pool)
					
					#Distributing tokens starting from a random tile
					DIR=r.randrange(0,5)	
					satisfied = np.zeros(5)
					while (surplus_token_pool > 0):
						if(nb_ratios[DIR] < deficit_ratio):
							nb_has_list[DIR] = nb_has_list[DIR] + 1	
							nb_ratios[DIR] = nb_has_list[DIR]/nb_needs_list[DIR] if nb_needs_list[DIR]>0 else 0
							surplus_token_pool = surplus_token_pool - 1;
						else:
							satisfied[DIR] = 1	#this tile is satisfied
						DIR = (DIR + 1)%5
						if(np.prod(satisfied) == 1):
							break

					if DEBUG:
						print("Surplus token count after distribution: "+str(i))
						print (x,y,surplus_token_pool)
						
					#Compute number of token exchanges -- indicated by number of tiles whose has count changed during the epoch
					token_diff_arr=nb_has_list - np.array([self_h, agents_has[x][(y+1)%N], agents_has[x][(y-1)%N], agents_has[(x+1)%N][y],agents_has[(x-1)%N][y]])
					#total_exchanges = total_exchanges + 3*(abs((x+1)%N-x)+abs((x-1)%N-x)+abs((y-1)%N-y))
					total_exchanges = total_exchanges + 8 + len(token_diff_arr[np.where(token_diff_arr<0)]) + len(token_diff_arr[np.where(token_diff_arr>0)])
					#agents_corner[x][y]=(agents_corner[x][y]+1)%16
					#Update has count for all agents	
					agents_has[x][y] = nb_has_list[CENTER]
					#if(agents_corner[x][y]%4<3 or not(extra_rand)):
						#agents_has[x][(y+1)%N] = nb_has_list[NORTH]
						#total_exchanges = total_exchanges + 3
						#total_exchanges = total_exchanges + 3*(abs((y+1)%N-y))
					#else:
						#agents_has[xrand][yrand] = nb_has_list[NORTH]
						#total_exchanges = total_exchanges + 3*(abs(yrand-y)+abs(xrand-x))

					agents_has[x][(y+1)%N] = nb_has_list[NORTH]
					agents_has[x][(y-1)%N] = nb_has_list[SOUTH]
					agents_has[(x+1)%N][y] = nb_has_list[EAST]
					agents_has[(x-1)%N][y] = nb_has_list[WEST]
					
					# 5 cycles -> send request from CENTER and receive token count from neighbors - overlapped
					# token_diff_arr<0 -> CENTER receives tokens, 2 cycles (1 request + 1 receive), token_diff_arr>0 -> CENTER sends tokens (only 1 cycle) overlapped with receive
					tot_time = tot_time + 5 + max(len(token_diff_arr[np.where(token_diff_arr<0)]),len(token_diff_arr[np.where(token_diff_arr>0)])) + len(token_diff_arr[np.where(token_diff_arr<0)])
					#tot_time = tot_time + 4 + 2*len(token_diff_arr[np.where(token_diff_arr<0)]) + len(token_diff_arr[np.where(token_diff_arr>0)])
					
					if DEBUG:
						print("Updated token count: ", str(i))
						print ("Has: " +str(np.sum(nb_has_list)))
						print (nb_has_list)
						print("Satisfied tiles: ", str(i))
						print (satisfied)
					old_sq_error = sq_error[i]

	parallel_factor = int(N/3)*int(N/3) if ((IF_PARALLEL*N)>3) else 1
	#parallel_factor = 1
	if(exc_count or i==(tmax-1)):	
		return(sq_error[i],i,np.max(abs(agents_has/agents_needs-mean_ratio)/mean_ratio),total_exchanges)
		#return(sq_error[i],i,np.max(abs(agents_has-(agents_needs*Ttot*1.0/np.sum(agents_needs)))),total_exchanges)
	else:
		return(sq_error[i],i)
