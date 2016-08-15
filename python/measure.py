#-----------------------------------MEASURE.M-----------------------------------
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

import math
import matplotlib.pyplot as plt

from scipy.signal import *
from numpy import *

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
        
        f = min(max(f,10),30000)
        order = min(max(n+1,1),4)
        Fmax = order*f

        Fs = 192000 #sampling rate (48kHz<Fs<192kHz)
        df = 1 # 1Hz precision
        N = round(Fs/df) #number of samples
        T = 2/df

        #recording @ <Fs>Hz sampling rate
        data = []
        for i in range(N):
                data.append(sin(2*pi*f*i/Fs))
                time.sleep(Fs)


        #windowing or not the response signal
        signal = data#* blackmanharris(N) #Blackman-Harris window
        [fourier, H, THD, SNR] = fct.analyze(signal, Fs, f, order)

        if boolPlot :
                plt.plot(fourier(1),fourier(2)))
                plt.show()

        print('Fundamental (',f,' Hz): ',20*log10(H(1)),' dBV\n')
        for i in range(2,order):
                print('Harmonic ',i-1,' (',i*f,' Hz): ',20*log10(H(i)),' dBV\n')

        print('THD+N : ',THD,'%\n')
        print('SNR   : ',SNR,' dBV\n')

        return true

def readVoltage():
	"""
	INPUTS :
		
	OUPUTS :
	v : float
		voltage read on the pin
	"""
        return v
        
#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':
        
        Fs = 48000
        T = 20
		f = 440
		n=1
		
        t = list(range(0,T,1/Fs)) #time vector
        sinu = sin(2*pi*f*t);

        player = audioplayer (sinu, Fs);

        play (player)

        measure(f,n,1);

        stop (player);
		raw_input('(Press <Enter> to close)')
#--------------------------------------EOF--------------------------------------
