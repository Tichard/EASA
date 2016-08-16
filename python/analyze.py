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
	HN[i-1:i+2] = 0 #excluding fundamental bin
	F = np.array(S[:]-HN[:]) #isolating the fundamental bin
	HN[0:3] = 0 #excluding potentialy VLF and DC bin

	fourier = [[],[],[]]
	fourier[0] = f
	fourier[1] = S

	# Choose the THD wanted :
	#THD = 100*sqrt(sum(H(2:order).^2))/H(1) #THD_F !!OBSOLETE!!
	#THD = 100*sqrt(sum(H(2:order).^2)/sum(H(1:order).^2)) #THD_R !!OBSOLETE!!
	THD = 100*rms(HN)/rms(F) #THD+N

	SNR = 20*np.log10(rms(F)/rms(HN)) #SNR to dBV

	return (fourier, H, THD, SNR)


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

	import platform
	import random as rd
	import scipy.signal as sig
	import matplotlib.pyplot as plt
	
	Fs = 117000 #sampling rate 117kHz
	df = 0.1 # 1Hz precision
	N = np.ceil(Fs/df) #number of samples
	
	n = np.arange(N)
	f = 1000
	h = 1
	order = min(max(h+2,2),6)

	sinu  = np.sin(2*np.pi*f*n/Fs)+ 0.0007*np.random.rand(N)

	signal = sinu #* sig.blackmanharris(N) #Blackman-Harris window !!!Amplitude issues!!!

	(fourier, H, THD, SNR) = analyze(signal, Fs, f, order)

	print "Fundamental (",f,"Hz): ",np.round(20*np.log10(H[0]),3),"dBV"

	for i in range(1,order-1):
		print "Harmonic ",i,"(",(i+1)*f,"Hz):",np.round(20*np.log10(H[i]),3),"dBV"

	print "THD+N : ",np.round(THD,3),"%"
	print "SNR   : ",np.round(SNR,3),"dBV"

	if platform.system()== 'Windows':
		plt.plot(fourier[0],fourier[1])
		plt.show()

#--------------------------------------EOF--------------------------------------
