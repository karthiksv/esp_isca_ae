import matplotlib.pyplot as plt
PLOT = 1
HET_ONLY=1 #Set =1 to run the convergence and heterogeneity check only

if (HET_ONLY!=1):
	from convergence_speed_BC_baseline import *
	convergence_speed_BC_baseline()

	from convergence_speed_BC_4way import *
	convergence_speed_BC_4way()

	from convergence_speed_BC_smart_timing import *
	convergence_speed_BC_smart_timing()

from convergence_heterogeneity import *
convergence_heterogeneity()

if (PLOT and (HET_ONLY!=1)):
	
	#plt.figure('1-way vs 4 way')	
	#fig, ax1 = plt.subplots()
	fig = plt.subplots(figsize =(12, 8)) 
	plt.title('1-way vs 4 way')	
	ax1=plt.gca()
	ax2 = ax1.twinx()

	conv_data_baseline = pd.read_csv(conv_file_baseline)
	ax1.plot(conv_data_baseline['N'],conv_data_baseline['conv_time'], 'r-', label='Conv Time (1 way)')
	exch_data_baseline = pd.read_csv(exch_file_baseline)
	ax2.plot(exch_data_baseline['N'],exch_data_baseline['num_exchanges'], 'r--', label='Num Exch (1 way)')

	conv_data_4way = pd.read_csv(conv_file_4way)
	ax1.plot(conv_data_4way['N'],conv_data_4way['conv_time'], 'b-', label='Conv Time (4 way)')
	exch_data_4way = pd.read_csv(exch_file_4way)
	ax2.plot(exch_data_4way['N'],exch_data_4way['num_exchanges'], 'b--', label='Num Exch (4 way)')
	ax1.legend(loc='upper left')
	ax2.legend(loc='upper right')

	ax1.set_xlabel('d=sqrt(N)')
	ax1.set_ylabel('Convergence Time (cycles)')
	ax2.set_ylabel('Num packets exchanged')

	plt.show()

	fig = plt.subplots(figsize =(12, 8)) 
	plt.title('Smart timing')	
	ax1=plt.gca()
	ax2 = ax1.twinx()

	conv_data_baseline = pd.read_csv(conv_file_baseline)
	ax1.plot(conv_data_baseline['N'],conv_data_baseline['conv_time'], 'r-', label='Conv Time (default)')
	exch_data_baseline = pd.read_csv(exch_file_baseline)
	ax2.plot(exch_data_baseline['N'],exch_data_baseline['num_exchanges'], 'r--', label='Num Exch (default)')
	
	conv_data_smart_timing = pd.read_csv(conv_file_smart_timing)
	ax1.plot(conv_data_smart_timing['N'],conv_data_smart_timing['conv_time'], 'b-', label='Conv time (Smart timing)')
	exch_data_smart_timing = pd.read_csv(exch_file_smart_timing)
	ax2.plot(exch_data_smart_timing['N'],exch_data_smart_timing['num_exchanges'], 'b--', label='Num Exch (Smart timing)')

	ax1.set_xlabel('d=sqrt(N)')
	ax1.set_ylabel('Convergence Time (cycles)')
	ax2.set_ylabel('Num packets exchanged')

	ax1.legend(loc='upper left')
	ax2.legend(loc='upper right')

	plt.show()

if PLOT:	
	#plt.figure('Heterogeneity')
	
	# set width of bar 
	barWidth = 0.1
	fig = plt.subplots(figsize =(12, 8)) 
	plt.title('Impact of accelerator heterogeneity')	
	ax1=plt.gca()
	ax2 = ax1.twinx()
	
	convdata=pd.read_csv('conv_het_file.csv').T
	errdata=pd.read_csv('err_het_file.csv')
	
	convdata_new = convdata[:][:-1]
	errdata_new = errdata.iloc[:,:-1][:]
	ind = [int(convdata[i]['N']) for i in range(0,len(convdata.T))]
	

	# Set position of bar on X axis 
	b = np.arange(len(convdata_new[0])) 
	for i in range(0,len(ind)):
		br = [x + (i-len(ind)/2)*barWidth for x in b] 
		ax1.bar(br, convdata_new[i], width = barWidth, 
	        edgecolor ='black', label ='N='+str(ind[i])) 
	
	ax1.set_xlabel('Degree of heterogeneity (Nacc)', fontweight ='bold', fontsize = 15) 
	ax1.set_ylabel('Convergence time', fontweight ='bold', fontsize = 15)
	ax2.set_ylabel('Error', fontweight ='bold', fontsize = 15)
	plt.xticks([r + barWidth for r in range(len(convdata))], np.arange(1,len(convdata)+1)) 
	
	ax1.legend(loc='upper left')
	mean_errdata = [np.mean([errdata[e][j] for j in np.where(errdata[e]>0)]) for e in errdata.columns]
	ax2.plot(mean_errdata,'r--', label='Mean error')
	ax2.legend(loc='upper center')
	
	plt.show() 






