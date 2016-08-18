#----------------------------------ANALYZE.PY-----------------------------------
# -*- coding: utf-8 -*-

#> [File Name] analyze.py
#> [Platform] EC Model5 testbench
#> [Version] alpha
#> [Author] Richard
#> [Date] 16/08/2016
#> [Language] python
#> [Description] Computes the harmonic response and several distortion rates 
#> from a response signal to a 'fgen' Hz sinewave sampled at 'Fs' Hz


#function import

#external import
import numpy.fft as ft
import numpy as np

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
	df = float(Fs)/N
	f = np.arange(0,N/2)*df #frequency vector

	Sc = abs(ft.fft(signal)/N) #fft in complex domain
	S = 2*Sc[:N/2] #fft in real domain

	H = []
	for o in range(1,order):  #for all harmonics
		index = np.ceil(o*fgen*N/Fs) #index of the frequency
		if index+1 < N/2:
			H.append(max(S[index:index+1]))
		else: H.append(0)

	# parasite signal created by the system (harmonics + noise)
	HN = np.array(S[:])
	
	i = np.ceil((float(fgen)*N/Fs))
	bw =int(0.1*fgen*N/Fs) # 20% bandwidth gate (10% each side)
	
	HN[i-bw:i+bw] = 0 #excluding fundamental bin
	
	F = np.array(S[:]-HN[:]) #isolating the fundamental bin
	
	HN[:2*bw] = 0 #excluding potentialy VLF and DC bin

	fourier = [[],[],[]]
	fourier[0] = f
	fourier[1] = F
	fourier[2] = HN

	# Choose the THD wanted :
	#THD = 100*sqrt(sum(H(2:order).^2))/H(1) #THD_F !!OBSOLETE!!
	#THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)) #THD_R !!OBSOLETE!!
	THD = 100*rms(HN)/rms(F) #THD+N

	SINAD = 20*np.log10(rms(F)/rms(HN)) #SINAD to dBV

	return (fourier, H, THD, SINAD)


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
	return np.sqrt(np.sum(S*S)/2)

#-------------------------------MODULE TEST ZONE--------------------------------

if __name__ == '__main__':

	import os
	import platform
	import sys
	import random as rd
	import scipy.signal as sig


	boolPlot = 1
		
	Fs = 938000 #sampling rate 938kHz
	df = 2 #Hz precision
	N = np.ceil(Fs/df) #number of samples
	
	n = np.arange(N)
	f = 1000
	h = 2
	order = min(max(h+2,2),6)

	sinu  =(0.5+0.01*np.random.rand(N))*np.sin((2+0.005*np.random.rand(N))*np.pi*f*n/Fs)


	signal = sinu #* sig.blackmanharris(N) #Blackman-Harris window !!!Amplitude issues!!!

	(fourier, H, THD, SINAD) = analyze(signal, Fs, f, order)

	print "Fundamental (",f,"Hz): ",np.round(20*np.log10(H[0]),2),"dBV"

	for i in range(1,order-1):
		print "Harmonic ",i,"(",(i+1)*f,"Hz):",np.round(20*np.log10(H[i]),2),"dB"

	print "THD+N                : ",np.round(THD,3),"%"
	
	print "SINAD                : ",np.round(SINAD,1),"dBV"

	if boolPlot & (("DISPLAY" in os.environ)|(platform.system() == 'Windows')) :    #check if can dipslay
		import matplotlib.pyplot as plt
		plt.subplot(211)        
		plt.plot(n/Fs,sinu)
		plt.subplot(212)
		plt.plot(fourier[0],fourier[1],fourier[0],fourier[2])
		plt.show()

#--------------------------------------EOF--------------------------------------
