#----------------------------------MEASURE.PY-----------------------------------
# -*- coding: utf-8 -*-

#> [File Name] measure.py
#> [Platform] EC Model5 testbench
#> [Version] alpha
#> [Author] Richard
#> [Date] 16/08/2016
#> [Language] python
#> [Description] Records and computes the harmonic response and several
#> distortion rates to a given frequency calling "analyse.m" function

#function import
import analyze as fct

#external import
import sys
import os
import platform

import scipy.signal as sig
import numpy as np

from FT4222Programmer import ft4222
from FT4222Programmer.adc088s022 import ADC088S022

def init():
	"""
	INPUT:

	OUTPUT :
	PIN : array-like
		dict of hardware element

	Init the Hardware
	"""
	
	devices = ft4222.FT4222.enumerateDevices()

	# checking if the FT4222 is connected
	if not len(devices):
		print "ERROR: Device not found !"
		sys.exit(1)

	#configure GPIO direction
	gpio = ft4222.GPIO(devices[len(devices)-1]['locid'],
				     [	ft4222.GPIO.GPIO_INPUT,
					ft4222.GPIO.GPIO_OUTPUT,
					ft4222.GPIO.GPIO_OUTPUT,
					ft4222.GPIO.GPIO_OUTPUT ] )
	# pin aliases
	POWER = ft4222.GPIO.GPIO_PORT1 
	spi0 = ft4222.FT4222(devices[0]['locid'], 0)
	SELECT_ADC = ft4222.GPIO.GPIO_PORT3
	ADC = ADC088S022(spi0)
	PIN ={'power': POWER,'select_adc':SELECT_ADC,'adc':ADC}

	gpio.set(POWER, True) #power on
	gpio.set(SELECT_ADC, True) # Enable the ADC reading

	return PIN


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
	return : integer
		return 1 if the function has been fully executed       
	"""

        pin = init()
		
	f = min(max(f,10),30000)
	order = min(max(n+2,2),6)
	
	Fs = pin['adc'].Fs
	df = 100 #Hz precision (maximum supported : 10Hz)
	N = np.ceil(Fs/df) #number of samples
	T =1.050/df #take 5% more samples than needed to avoid transient response

	#recording @ <Fs>Hz sampling rate
	data = readVoltage(pin['adc'],T)
	end = len(data)
	nb = int(N)
	print nb
		
	#windowing or not the response signal
	signal = data[end-nb:end] #* sig.blackmanharris(N) #Blackman-Harris window !!!Amplitude issues!!!
	(fourier, H, THD, SINAD) = fct.analyze(signal, Fs, f, order)

	print "Fundamental (",f,"Hz): ",np.round(20*np.log10(H[0]),3),"dBV"

	for i in range(1,order-1):
		print "Harmonic ",i,"(",(i+1)*f,"Hz):",np.round(20*np.log10(H[i]),3),"dBV"

	print "THD+N : ",np.round(THD,3),"%"
	print "SINAD : ",np.round(SINAD,3),"dBV"

	if boolPlot & (("DISPLAY" in os.environ)|(platform.system() == 'WINDOWS')) :    #check if can dipslay
		import matplotlib.pyplot as plt
		plt.plot(fourier[0],fourier[1])
		plt.show()

	#gpio.set(pin['power'], False) #power off !! gpio nonexistant in this scope
		
	return 1

def readVoltage(ADC,T):
	"""
	INPUTS :
	T : float
		reading time (nb of samples wanted / Fs)
		
	OUPUTS :
	data : float
		voltage read on the pin
	"""
	data = ADC.read( ADC088S022.CHANNEL_2, T )

	return data

def readDC(ADC):
	data = np.array(ADC.read( ADC088S022.CHANNEL_2, 0.001 ))
	end = int(len(data))
	v = np.mean(data[end-100:end]) #mean of the 100 last samples
	print v
	return v	

#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':
	
	f = 1000
	n=2
       
	measure(f,n,1)
	print	
#--------------------------------------EOF--------------------------------------
