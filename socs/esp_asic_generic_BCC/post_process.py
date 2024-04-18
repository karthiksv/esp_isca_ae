import csv
import numpy as np
import matplotlib.pyplot as plt
input_csv='xcelium/simvision.csv'
Nlines = 0
with open(input_csv) as f:
    for line in f:
        Nlines = Nlines + 1
		
		
timescale=0.125*1E-3
mybase=10
mytime=np.zeros(Nlines)  #Time in usecond
act_nvdla0=np.zeros(Nlines)#Activity of accelerator
freq_nvdla0=np.zeros(Nlines)#ASIC frequency of accelerator in MHz
token_nvdla0=np.zeros(Nlines)#Number of tokens of the accelerator
power_nvdla0=np.zeros(Nlines)#ASIC Power of the accelerator in mW
voltage_nvdla0=np.zeros(Nlines)#ASIC Voltage of the accerator in mV

act_fft0=np.zeros(Nlines)
freq_fft0=np.zeros(Nlines)
token_fft0=np.zeros(Nlines)
power_fft0=np.zeros(Nlines)
voltage_fft0=np.zeros(Nlines)

act_fft1=np.zeros(Nlines)
freq_fft1=np.zeros(Nlines)
token_fft1=np.zeros(Nlines)
power_fft1=np.zeros(Nlines)
voltage_fft1=np.zeros(Nlines)

act_fft2=np.zeros(Nlines)
freq_fft2=np.zeros(Nlines)
token_fft2=np.zeros(Nlines)
power_fft2=np.zeros(Nlines)
voltage_fft2=np.zeros(Nlines)

act_viterbi0=np.zeros(Nlines)
freq_viterbi0=np.zeros(Nlines)
token_viterbi0=np.zeros(Nlines)
power_viterbi0=np.zeros(Nlines)
voltage_viterbi0=np.zeros(Nlines)


act_viterbi1=np.zeros(Nlines)
freq_viterbi1=np.zeros(Nlines)
token_viterbi1=np.zeros(Nlines)
power_viterbi1=np.zeros(Nlines)
voltage_viterbi1=np.zeros(Nlines)

power_total=np.zeros(Nlines)

ASIC_mult=1.0


voltage_FFT=[0.5,0.5,0.6,0.7,0.8,0.9,1]
voltage_VIT=[0.5,0.5,0.6,0.7,0.8,0.9,1]
voltage_NVDLA=[0.6,0.6,0.6,0.7,0.8,0.9,1]

freq_FFT=[0,380,788,1036,1220,1450,1512]
freq_VIT=[0,325,650,960,1200,1360,1360]
freq_NVDLA=[0,400,800,1144,1300,1356,1380]

power_FFT=[0,2.63,5.47,8.38,11.51,15.73,19.28]
power_VIT=[0,8.74,20.06,34.24,50.98,63.54,72.44]
power_NVDLA=[0,33.42608696,66.85217391,111.5317101,144.8463768,169.9716522,192.2]

	
def freq_conv(freqin):
	return(1600-freqin*6.1)
	
	
	
def freq_power_conv(acc,freq):
	if(acc=='FFT'):
		return(np.interp(freq,freq_FFT,power_FFT))
	if(acc=='VIT'):
		return(np.interp(freq,freq_VIT,power_VIT))
	if(acc=='NVDLA'):
		return(np.interp(freq,freq_NVDLA,power_NVDLA))
	return(42)
	
def freq_voltage_conv(acc,freq):
	if(acc=='FFT'):
		return(np.interp(freq,freq_FFT,voltage_FFT))
	if(acc=='VIT'):
		return(np.interp(freq,freq_VIT,voltage_VIT))
	if(acc=='NVDLA'):
		return(np.interp(freq,freq_NVDLA,voltage_NVDLA))
	return(42)


		
with open(input_csv) as csv_file:
	csv_reader = csv.reader(csv_file, delimiter=',')
	i = 0
	for row in csv_reader:
		#print(row)
		if (i>110):#Skip first row
			mytime[i-1]=(1/ASIC_mult)*float(row[0])*timescale
			act_nvdla0[i-1]=int(row[3])
			freq_nvdla0[i-1]=ASIC_mult*freq_conv(int(row[2],base=mybase) )
			token_nvdla0[i-1]=int(row[4],base=mybase)
			power_nvdla0[i-1]=act_nvdla0[i-1]*freq_power_conv('NVDLA',freq_nvdla0[i-1])
			voltage_nvdla0[i-1]=freq_voltage_conv('NVDLA',freq_nvdla0[i-1])
			
			act_fft0[i-1]=int(row[7])
			freq_fft0[i-1]=ASIC_mult*freq_conv(int(row[6],base=mybase) )
			token_fft0[i-1]=int(row[8],base=mybase)			
			power_fft0[i-1]=act_fft0[i-1]*freq_power_conv('FFT',freq_fft0[i-1])
			voltage_fft0[i-1]=freq_voltage_conv('FFT',freq_fft0[i-1])
			
			act_viterbi0[i-1]=int(row[11])
			freq_viterbi0[i-1]=ASIC_mult*freq_conv(int(row[10],base=mybase) )
			token_viterbi0[i-1]=int(row[12],base=mybase)			
			power_viterbi0[i-1]=act_viterbi0[i-1]*freq_power_conv('VIT',freq_viterbi0[i-1])
			voltage_viterbi0[i-1]=freq_voltage_conv('VIT',freq_viterbi0[i-1])

			act_fft1[i-1]=int(row[15])
			freq_fft1[i-1]=ASIC_mult*freq_conv(int(row[14],base=mybase) )
			token_fft1[i-1]=int(row[16],base=mybase)			
			power_fft1[i-1]=act_fft1[i-1]*freq_power_conv('FFT',freq_fft1[i-1])
			voltage_fft1[i-1]=freq_voltage_conv('FFT',freq_fft1[i-1])
			
			act_viterbi1[i-1]=int(row[19])
			freq_viterbi1[i-1]=ASIC_mult*freq_conv(int(row[18],base=mybase) )
			token_viterbi1[i-1]=int(row[20],base=mybase)	
			power_viterbi1[i-1]=act_viterbi1[i-1]*freq_power_conv('VIT',freq_viterbi1[i-1])
			voltage_viterbi1[i-1]=freq_voltage_conv('VIT',freq_viterbi1[i-1])
			
			act_fft2[i-1]=int(row[23])
			freq_fft2[i-1]=ASIC_mult*freq_conv(int(row[22],base=mybase) )
			token_fft2[i-1]=int(row[24],base=mybase)			
			power_fft2[i-1]=act_fft2[i-1]*freq_power_conv('FFT',freq_fft2[i-1])
			voltage_fft2[i-1]=freq_voltage_conv('FFT',freq_fft2[i-1])

		i=i+1

power_total=power_nvdla0+power_fft0+power_fft1+power_fft2+power_viterbi0+power_viterbi1


tend=1

act_tot=act_fft2+act_fft1+act_fft0+act_viterbi1+act_viterbi0+act_nvdla0

#plt.plot(act_tot)
#plt.show()
t0=np.min(np.nonzero(act_tot))
t1=np.max(np.nonzero(act_tot))


delta_act_tot=abs(np.diff(act_tot))
Nrange=200
ntr=0
responses=[]
'''
for i in range(t0-10,t1+200):
	if delta_act_tot[i]!=0:
		#Activity change
		j=i-1
		ntr+=1
		is_stable=False
		while(not(is_stable)):
			is_stable=True
			j+=1
			for k in range(Nrange):
				is_stable=is_stable and (freq_fft2[j+k]==freq_fft2[j]) and (freq_fft1[j+k]==freq_fft1[j]) and (freq_fft0[j+k]==freq_fft0[j]) and (freq_viterbi0[j+k]==freq_viterbi0[j]) and (freq_viterbi1[j+k]==freq_viterbi1[j]) and (freq_nvdla0[j+k]==freq_nvdla0[j]) and ((freq_fft2[j+k]!=freq_fft2[i]) or (freq_fft1[j+k]!=freq_fft1[i]) or (freq_fft0[j+k]!=freq_fft0[i]) or (freq_viterbi0[j+k]!=freq_viterbi0[i]) or (freq_viterbi1[j+k]!=freq_viterbi1[i]) or (freq_nvdla0[j+k]!=freq_nvdla0[i])) 
		print("Transition " + str(ntr) + " Start " + str(mytime[i]-mytime[t0]) + " end " + str(mytime[j]-mytime[t0]) + " duration " + str(mytime[j]-mytime[i]))
		responses.append(mytime[j]-mytime[i])
print(np.average(responses))
'''

#print(mytime)
mylabel=['FFT0','FFT1','FFT2','Viterbi0','Viterbi1','NVDLA0',]
fig = plt.figure()
fig.patch.set_facecolor('white')
'''
plt.plot(mytime,voltage_nvdla0)
plt.plot(mytime,voltage_fft0)
plt.plot(mytime,voltage_viterbi0)
plt.plot(mytime,voltage_fft1)
plt.plot(mytime,voltage_viterbi1)
plt.plot(mytime,voltage_fft2)
'''
#plt.stackplot(mytime[t0-40:-1]-mytime[t0-40], power_fft0[t0-40:-1], power_fft1[t0-40:-1],power_fft2[t0-40:-1],power_viterbi0[t0-40:-1],power_viterbi1[t0-40:-1],power_nvdla0[t0-40:-1], labels=mylabel)


#plt.stackplot(mytime[t0-40:-1]-mytime[t0-40], power_fft0[t0-40:-1], power_fft1[t0-40:-1],power_fft2[t0-40:-1],power_viterbi0[t0-40:-1],power_viterbi1[t0-40:-1],power_nvdla0[t0-40:-1], labels=mylabel)#,label=['NVDLA0','FFT0','FFT1','FFT2','VIT0','VIT1'])
plt.stackplot(mytime[t0-40:t1+tend]-mytime[t0-40], power_fft0[t0-40:t1+tend], power_fft1[t0-40:t1+tend],power_fft2[t0-40:t1+tend],power_viterbi0[t0-40:t1+tend],power_viterbi1[t0-40:t1+tend],power_nvdla0[t0-40:t1+tend], labels=mylabel)#,label=['NVDLA0','FFT0','FFT1','FFT2','VIT0','VIT1'])

plt.xlabel('Time [us]',fontsize=18)
plt.ylabel('Power [mW]',fontsize=18)
#plt.xlim(159, 160.01 )
#plt.xlim(0, 585 )
TT1=0
TT2=mytime[t1+tend]-mytime[t0-40]+10
plt.xlim(TT1,TT2  )
#plt.xlim(198, 213 )

plt.ylim(0, 65 ) 
#plt.xticks(np.arange(0,585,step=50),fontsize=16)
plt.xticks(np.arange(TT1,TT2,step=20),fontsize=17)
plt.yticks(fontsize=17)

fig.set_figwidth(6)
fig.set_figheight(4)
#fig.set_figwidth(6)
#fig.set_figheight(3)

#plt.plot(mytime,voltage_nvdla0,mytime,voltage_fft0,mytime,voltage_viterbi0)
#plt.plot(mytime,freq_nvdla0,mytime,freq_fft0,mytime,freq_viterbi0)
plt.savefig('foo.png', bbox_inches='tight')

plt.show()


#token_tot=token_fft2+token_fft1+token_fft0+token_viterbi1+token_viterbi0+token_nvdla0
#plt.xlabel('Time [us]',fontsize=18)
#plt.ylabel('Token count',fontsize=18)
#plt.plot(mytime[t0-40:t1+tend]-mytime[t0-40],token_tot[t0-40:t1+tend])
#plt.show()
'''
plt.stackplot(mytime[t0-40:-1]-mytime[t0-40], power_fft0[t0-40:-1], power_fft1[t0-40:-1],power_fft2[t0-40:-1],power_viterbi0[t0-40:-1],power_viterbi1[t0-40:-1],power_nvdla0[t0-40:-1], labels=mylabel)#,label=['NVDLA0','FFT0','FFT1','FFT2','VIT0','VIT1'])
plt.xlabel('Time [us]',fontsize=18)
plt.ylabel('Power [mW]',fontsize=18)
plt.xticks(fontsize=16)
plt.yticks(fontsize=16)
#plt.plot(mytime,voltage_nvdla0,mytime,voltage_fft0,mytime,voltage_viterbi0)
#plt.plot(mytime,freq_nvdla0,mytime,freq_fft0,mytime,freq_viterbi0)
plt.show()
'''
print("Run time: "+str(mytime[t1]-mytime[t0])+ " us")


