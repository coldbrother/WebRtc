#!/usr/bin/python3 
# -*- coding:UTF-8 -*-
import ctypes
import array 
import sys  
import os 
from ctypes import *
import wave 
import numpy as np 
import math 

ll          =   ctypes.cdll.LoadLibrary
webrtclib   =   ll("./webrtclib.so")

#filename = 'sample_L.wav'
#filename = 'test_case1.wav'
filename = 'lhydd_1C_16bit_32K_01.wav'
#print(dataout)

f = wave.open(filename,"rb")
params  = f.getparams()
nchannels, sampwidth , framerate, nframes = params[:4]
print("params")
print(nchannels,sampwidth,framerate,nframes)

data1 = f.readframes(nframes)  
data1 = np.fromstring(data1, np.int16)
print(data1.size)

dataout = np.zeros((data1.size))
dataout = dataout.astype(np.int16)

b_arr = (c_short*data1.size)(*dataout)
c_arr = (c_short*data1.size)(*dataout)
#    print(b_arr)
a_arr = (c_short*data1.size)(*data1)
    
dataoutall = np.zeros(data1.size)
dataoutall = dataoutall.astype(np.int16)

webrtclib.NoiseSuppression32(a_arr , b_arr, 32000 ,0,data1.size*2)
#webrtclib.NoiseSuppression32(b_arr , c_arr, 32000 , 1,data1.size*2)
#for i in range(160):
for i  in range(data1.size):
    dataoutall[i] = b_arr[i]
print("out")
        
dataoutall  = dataoutall.tostring()
wave_out  = wave.open("out_web4.wav",'w')
wave_out.setnchannels(1)
wave_out.setsampwidth(2)
wave_out.setframerate(32000)
wave_out.writeframes(dataoutall)
print("done")


