#----------------------------------ANALYZE.PY-----------------------------------
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
import math as m
import numpy.fft as ft
import numpy
import scipy.signal as sig

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

        S = abs(ft.rfft(signal)) #fft in real domain

        H = []
        for o in range(1,order):  #for all harmonics
                index = m.ceil(o*fgen*N/Fs) #index of the frequency
                if index+1 < N/2:
                        H.append(max(S[index:index+1]))
                else: H.append(0)

        # parasite signal created by the system (harmonics + noise)
        HN = S
        i = m.ceil((fgen*N/Fs))
        HN[i:i+1] = 0 #excluding fundamental bin
        HN[0:3] = 0 #excluding potentialy VLF and DC bin

	fourier = [[],[]]
        fourier[1][] = f
        fourier[2][] = S

        # Choose the THD wanted :
        #THD = 100*sqrt(sum(H(2:order).^2))/H(1) #THD_F
        #THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)) #THD_R
        THD = 100*rms(HN)/rms(S) #THD+N

        SNR = 20*m.log10(rms(S)/rms(HN)) #SNR to dBV

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
	return m.sqrt(sum(S^2)/2)

#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':
	Fs = 117000
	df = 1
	N = Fs/df
	T = 0.2
	t = numpy.array(range(Fs))/Fs
	f = 1000

	sinu = []
	for i in t: 
		sinu.append(m.sin(2*m.pi*f*i))

        signal = sinu * sig.blackmanharris(N) #Blackman-Harris window

	analyze(signal, Fs, f,2)

        raw_input('(Press <Enter> to close)')


#--------------------------------------EOF--------------------------------------
