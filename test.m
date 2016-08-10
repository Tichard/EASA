%------------------------------------TEST.M-------------------------------------

%{
	> [File Name] test.m
	> [Platform] Octave GNU
	> [Version] 1.00
	> [Author] Richard
	> [Date] 10/08/2016
	> [Language] .m file
	> [Description] Tests function file
%}


%-----------------------------------INCLUDES------------------------------------
%load the audio package (player/recorder)
pkg load audio;

%load the implemented functions
addpath ("./src");

%-----------------------------------FUNCTION------------------------------------

function test_measure(f,n)
	
	Fs = 44100;
	T = 3;
	t = 0:1/Fs:T-(1/Fs); %time vector
	sinu = cos(2*pi*f*t);
	
	player = audioplayer (sinu, Fs);
	play (player);
	
	measure(f,n);
	
	stop (player);
endfunction

%------------------------------------SCRIPT-------------------------------------

%clear all
clear;
clc;
%clf;

%sweep(10,30000,3);
test_measure(400,4);

%--------------------------------------EOF--------------------------------------
