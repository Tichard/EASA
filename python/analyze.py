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
	import platfom
	import sys
	import random as rd
	import scipy.signal as sig


	boolPlot = 1
		
	Fs = 117000 #sampling rate 117kHz
	df = 0.1 # 1Hz precision
	N = np.ceil(Fs/df) #number of samples
	
	n = np.arange(N)
	f = 1000
	h = 2
	order = min(max(h+2,2),6)

	a = [1,0.00005,0.00003]
	
	THD_real = 100*np.sqrt((a[1]**2+a[2]**2)/(a[0]**2))
	SINAD_real = 10*np.log10((a[0]**2)/(a[1]**2+a[2]**2))        
	

	sinu  = a[0]*np.sin(2*np.pi*f*n/Fs)+a[1]*np.sin(4*np.pi*f*n/Fs)+a[2]*np.sin(6*np.pi*f*n/Fs)

	signal = sinu #* sig.blackmanharris(N) #Blackman-Harris window !!!Amplitude issues!!!

	(fourier, H, THD, SINAD) = analyze(signal, Fs, f, order)

	print "Fundamental (",f,"Hz): ",np.round(20*np.log10(H[0]),2),"dBV                     ",
	if np.round(H[0],2) == np.round(a[0],2):
		sys.stdout.write("\033[32m")
		print "OK"
	else :
		sys.stdout.write("\033[31m")
		print "ERROR"
	sys.stdout.write("\033[37m")

	for i in range(1,order-1):
		print "Harmonic ",i,"(",(i+1)*f,"Hz):",np.round(20*np.log10(H[i]),2),"dB                    ",
		if np.round(H[i],2) == np.round(a[i],2):
			sys.stdout.write("\033[32m")
			print "OK"
		else:
			sys.stdout.write("\033[31m")
			print "ERROR"
		sys.stdout.write("\033[37m")

	print "THD+N                : ",np.round(THD,3),"%                     ",
	if  np.round(THD,3) == np.round(THD_real,3):
		sys.stdout.write("\033[32m")
		print "OK"
	else:
		sys.stdout.write("\033[31m")
		print "ERROR"
	sys.stdout.write("\033[37m")
	
	print "SINAD                : ",np.round(SINAD,1),"dBV                    ",
	if np.round(SINAD,4) == np.round(SINAD_real,4) :
		sys.stdout.write("\033[32m")
		print"OK"
	else:
		sys.stdout.write("\033[31m")
		print "ERROR"
	sys.stdout.write("\033[37m")
	
	if boolPlot & (("DISPLAY" in os.environ)|(platform.system() == 'WINDOWS')) :    #check if can dipslay
		import matplotlib.pyplot as plt
		plt.plot(fourier[0],fourier[1])
		plt.show()

#--------------------------------------EOF--------------------------------------
