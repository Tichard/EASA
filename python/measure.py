#----------------------------------MEASURE.PY-----------------------------------
# -*- coding: utf-8 -*-

#> [File Name] measure.py
#> [Platform] EC Model5 testbench
#> [Version] alpha
#> [Author] Richard
#> [Date] 15/08/2016
#> [Language] python
#> [Description] Records and computes the harmonic response and several
#> distortion rates to a given frequency calling "analyse.m" function

#function import
import analyze as fct

#external import
import sys
import time

import scipy.signal as sig
import numpy as np

from FT4222Programmer import ft4222
from FT4222Programmer.adc088s022 import ADC088S022


def measure(f, n=0,boolPlot=0):
	"""
	INPUTS :
	f : integer
		frequency to measure
	n : integer
		number of computed harmonics wanted
	boolPlot : boolean
		plot the fft
		
	OUPUTS :
	
	"""
	devices = ft4222.FT4222.enumerateDevices()
	spi0 = ft4222.FT4222(devices[0]['locid'], 0)
	adc = ADC088S022(spi0)

	
	f = min(max(f,10),30000)
	order = min(max(n+1,1),4)
	Fmax = order*f

	Fs = 117000 #sampling rate 117kHz
	df = 1 # 1Hz precision
	N = np.ceil(Fs/df) #number of samples
	T = N/Fs

	#recording @ <Fs>Hz sampling rate
	data = readVoltage(T)
	end = len(data)
	

	#windowing or not the response signal
	signal = data[end-N:end] #* sig.blackmanharris(N) #Blackman-Harris window !!!Amplitude issues!!!
	[fourier, H, THD, SNR] = fct.analyze(signal, Fs, f, order)

	print "Fundamental (",f,"Hz): ",np.round(20*np.log10(H[0]),3),"dBV"
	for i in range(1,order-1):
		print "Harmonic ",i,"(",(i+1)*f,"Hz):",np.round(20*np.log10(H[i]),3),"dBV"

	print "THD+N : ",np.round(THD,3),"%"
	print "SNR   : ",np.round(SNR,3),"dBV"

	return 1

def readVoltage(T):
	"""
	INPUTS :
	T : float
		reading time
		
	OUPUTS :
	data : float
		voltage read on the pin
	"""
	data = adc.read( ADC088S022.CHANNEL_0,T )
	
	return data
	
#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':
	
	Fs = 48000
	T = 20
	f = 1000
	n=1
       
	measure(f,n);
#--------------------------------------EOF--------------------------------------
