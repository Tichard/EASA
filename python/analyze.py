#-----------------------------------ANALYZE.M-----------------------------------
# -*- coding: utf-8 -*-

#> [File Name] analyze.py
#> [Platform] EC Model5 testbench
#> [Version] alpha
#> [Author] Richard
#> [Date] 15/08/2016
#> [Language] python
#> [Description] Computes the harmonic response and several distortion rates 
#> from a response signal to a 'fgen' Hz sinewave sampled at 'Fs' Hz


#function import

#external import
import math
from numpy.fft import *
from numpy import *



def analyze(signal, Fs, fgen, order):
	"""
	INPUTS :
	signal : array_like
		input signal to analyse
	Fs : integer
		sampling frequency
	fgen : integer
		fundamemtal of the input signal
	order : integer
		number of harmonics (fundamental incl.) wanted
		
	OUPUTS :
	
	"""

        N = len(signal) #number of samples
        f = list(range(0,N/2,Fs/N)) #frequency vector

        Sc = abs(fft(signal)/N) #fft in complex domain
        S = 2*Sc[0:N/2] #fft in real domain

        H = []
        for o in range(1,order):  #for all harmonics
                index = round(o*fgen*N/Fs) #index of the frequency
                if index+1 < N/2:
                        H.append(max(S[index:index+1]))
                else: H.append(0)

        # parasite signal created by the system (harmonics + noise)
        HN = S
        i = round((fgen*N/Fs))
        HN[i:i+1] = 0 #excluding fundamental bin
        HN[0:3] = 0 #excluding potentialy VLF and DC bin

        fourier[1] = f
        fourier[2] = S

        # Choose the THD wanted :
        #THD = 100*sqrt(sum(H(2:order).^2))/H(1) #THD_F
        #THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)) #THD_R
        THD = 100*rms(HN)/rms(S) #THD+N

        SNR = 20*log10(rms(S)/rms(HN)) #SNR to dBV

        return [fourier, H, THD, SNR]


def rms(S):
	"""
	computes the RMS in real frequency domain
	
	INPUTS :
	S : array_like
		Real Fourier transform
		
	OUPUTS :
	rms : float
		RMS of the input rfft
	"""
	return sqrt(sum(S^2)/2)

#--------------------------------------EOF--------------------------------------
