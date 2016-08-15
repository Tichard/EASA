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

import math as m

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
        N = m.ceil(Fs/df) #number of samples
        T = 0.2

        #recording @ <Fs>Hz sampling rate
        data = readVoltage(T)
        

	#windowing or not the response signal
        signal = data * sig blackmanharris(N) #Blackman-Harris window
        [fourier, H, THD, SNR] = fct.analyze(signal, Fs, f, order)

        print('Fundamental (',f,' Hz): ',20*log10(H(1)),' dBV\n')
        for i in range(2,order):
                print('Harmonic ',i-1,' (',i*f,' Hz): ',20*m.log10(H(i)),' dBV\n')

        print('THD+N : ',THD,'%\n')
        print('SNR   : ',SNR,' dBV\n')

        return true

def readVoltage(T):
	"""
	INPUTS :
	T : float
		reading time
		
	OUPUTS :
	v : float
		voltage read on the pin
	"""
        data = adc.read( ADC088S022.CHANNEL_0,T )

        return data
        
#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':
        
        Fs = 48000
        T = 20
        f = 440
        n=1
       
        measure(f,n);

        raw_input('(Press <Enter> to close)')
#--------------------------------------EOF--------------------------------------
