import matplotlib.pyplot as plt
PLOT = 1


from convergence_speed_BC_baseline import *
convergence_speed_BC_baseline()

from convergence_speed_BC_4way import *
convergence_speed_BC_4way()

from convergence_speed_BC_smart_timing import *
convergence_speed_BC_smart_timing()

from convergence_heterogeneity import *
convergence_heterogeneity()

if PLOT:
	
	plt.figure('1-way vs 4 way')	
	#fig, ax1 = plt.subplots()
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
	#plt.legend(['Conv_time (1 way)', 'Conv Time (4 way)','# exchanges (1 way)', '# exchanges (4 way)'], loc='best')

	ax1.set_xlabel('d=sqrt(N)')
	ax1.set_ylabel('Convergence Time (cycles)')
	ax2.set_ylabel('Num packets exchanged')

	plt.show()

	plt.figure('Smart timing')	
	ax1=plt.gca()
	ax2 = ax1.twinx()

	conv_data_baseline = pd.read_csv(conv_file_baseline)
	ax1.plot(conv_data_baseline['N'],conv_data_baseline['conv_time'], 'r-')
	exch_data_baseline = pd.read_csv(exch_file_baseline)
	ax2.plot(exch_data_baseline['N'],exch_data_baseline['num_exchanges'], 'r--')
	
	conv_data_smart_timing = pd.read_csv(conv_file_smart_timing)
	ax1.plot(conv_data_smart_timing['N'],conv_data_smart_timing['conv_time'], 'b-')
	exch_data_smart_timing = pd.read_csv(exch_file_smart_timing)
	ax2.plot(exch_data_smart_timing['N'],exch_data_smart_timing['num_exchanges'], 'b--')

	ax1.set_xlabel('d=sqrt(N)')
	ax1.set_ylabel('Convergence Time (cycles)')
	ax2.set_ylabel('Num packets exchanged')

	plt.show()
	#from convergence_heterogeneity import *
	#convergence_heterogeneity()
