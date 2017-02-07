#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:28:15 2017

@author: villarjose
"""
import numpy as np
import pandas as pd

def sma(x):
    """Function sma(x)
    Computes the Signal Magnitude Area as the sum of the absolute values of its 
    components in each dimension.

Sintax:
    sma(x)
Parameters:
    x: a numpy array of dimension mxn, with n in {1, 2, 3} or n>=9
Returns:
    a numpy vector of dimension 1x1 or 1x3
    
    
For instance,if you have an ACCdf object, you can call sma using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> sma_a = sma(a.get_components())

And if you have an ACC_BA_Gdf object, you can call sma using the get_components 
method:
    >>> a = ACC_BA_Gdf(myDataFrame) #this is from a accelerometer
    >>> sma_a = sma(a.get_components())
In this latter case, SMA is computed for the acc, ba, and g components, but not 
for the modulus of these accelerations -ACC, BA and G-. Therefore, the output 
is an array of mx3 -<sma(acc), sma(ba), sma(g)>-.

    """
    if x.ndim > 2:
        raise Exception("SMA: Invalid dimensions of the data array.");
    if x.ndim == 1 or (x.ndim == 2 and x.shape[0]==1) : #case of a vector
        r = np.sum(np.abs(x))
        rlen = min(1, r.size)
        return r / rlen
    if x.shape[1] <= 3: #case of ACCdf 
        r = np.sum(np.abs(x),axis=0) # np.fromiter(map(lambda v: sum(abs(v)), x), np.float)
        rlen = max(1, r.size)
        return np.sum(r)/len(r)
    elif x.shape[1] >=9: #case of ACC_BA_Gdf
        acc = np.sum(np.abs(x[:,0:3]),axis=0) #np.fromiter(map(lambda v: sum(abs(v)), x[:,0:3]), np.float)
        ba = np.sum(np.abs(x[:,3:6]),axis=0) #np.fromiter(map(lambda v: sum(abs(v)), x[:,3:6]), np.float)
        g = np.sum(np.abs(x[:,6:9]),axis=0) #np.fromiter(map(lambda v: sum(abs(v)), x[:,6:9]), np.float)
        
        r = np.stack((np.sum(acc), np.sum(ba), np.sum(g))) #np.stack((acc,ba,g),axis=1)
        xlen = max(1, x.shape[0])
        return r/xlen
    else:
        raise Exception("SMA: Invalid number of columns of the data array.");


def aom(x):
    """Function aom(x)
    Computes the Amount of Movement as the sum of the differences between
the maximum and the minimum values in the different axis of a sample.    

Sintax:
    aom(x)
Parameters:
    x: a numpy array of dimension mxn, with n in {2, 3} or n>=9
Returns:
    a numpy vector of dimension 1x1 or 1x3
    
    
For instance,if you have an ACCdf object, you can call aom using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> aom_a = aom(a.get_components())
    
And if you have an ACC_BA_Gdf object, you can call aom using the get_components 
method:
    >>> a = ACC_BA_Gdf(myDataFrame) #this is from a accelerometer
    >>> aom_a = aom(a.get_components())
In this latter case, AoM is computed for the acc, ba, and g components, but not 
for the modulus of these accelerations -ACC, BA and G-. Therefore, the output 
is an array of mx3 -<aom(acc), aom(ba), aom(g)>-.

    """
    if x.ndim > 2:
        raise Exception("AoM: Invalid dimensions of the data array.");
    if x.ndim == 1 or (x.ndim == 2 and x.shape[0]==1) : #case of a vector
        r = np.abs(np.max(x, axis=0) - np.min(x, axis=0))
        return np.sum(r)                                #yes, it is a 0.0 !!!!
    if x.shape[1] <= 3: #case of ACCdf
        r = np.abs(np.max(x, axis=1) - np.min(x, axis=1))
        return np.sum(r)
    elif x.shape[1] >=9: #case of ACC_BA_Gdf
        acc = np.abs(np.max(x[:, 0:3], axis=1) - np.min(x[:, 0:3], axis=1))
        ba = np.abs(np.max(x[:, 3:6], axis=1) - np.min(x[:, 3:6], axis=1))
        g = np.abs(np.max(x[:, 6:9], axis=1) - np.min(x[:, 6:9], axis=1))
        return np.sum(np.stack((acc,ba,g),axis=1), axis=1)
    else:
        raise Exception("AoM: Invalid number of columns of the data array.");

        
def time_between_peaks(x, n = 2, K = 0.9):
    """Function time_between_peaks(x)
    Computes the time-between-peaks as stated in 
   GENERALIZED MODELS FOR THE CLASSIFICATION OF ABNORMAL MOVEMENTS IN DAILY LIFE 
   AND ITS APPLICABILITY TO EPILEPSY CONVULSION RECOGNITION; Jose R. Villar, 
   Paula Vergara, Manuel Menendez, Enrique de la Cal, Victor M. Gonzalez and
   Javier Sedano; International Journal of Neural Systems.

The algorithm is:
   1.- Find the sequences with value higher than mean+K*std within the window,
   we use K set to 0.9 as default.
   2.- Keep the rising points from each of these sequences
   3.- Measure the mean time between them.

Sintax:
    time_between_peaks(x)
    time_between_peaks(x, 2)
    time_between_peaks(x, n = 2, K = 0.9)
Parameters:
    x: a numpy array of dimension mxn, n is the number of features to analyze
    n: the minimum numer of peaks to detect
    K: the constant for computing the threshold
Returns:
    a numpy vector of dimension 1xn  with the time-between-peaks for each column.
    
    
For instance,if you have an ACCdf object, you can call time-between-peaks using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> tbpks_a = time_between_peaks(a.get_components())
    

    """
    if x.ndim == 1 or (x.ndim == 2 and x.shape[0]==1) :
        m = np.mean(x)
        s = np.std(x)
        r = x > (m + 0.9 * s)
        R = r[1:] ^ r[0:-1]
        ncolumns = 1
        tbpks = np.zeros(ncolumns)
        A=np.arange(0,R.shape[0])[R==True]
        if A.size > n:
            tdif = A[1:] - A[0:-1]    
            tbpks[0] = np.sum(tdif) / (A.size-1)
            #print(str(c)+': ', A, tdif)
    else:
        m = np.mean(x, axis = 0)
        s = np.std(x, axis = 0)
        r = x > (m + 0.9 * s)
        R = r[1:, :] ^ r[0:-1, :]
        ncolumns = x.shape[1]
        tbpks = np.zeros(ncolumns)
        for c in range(ncolumns):
            A=np.arange(0,R.shape[0])[R[:,c]==True]
            if A.size < n:
                continue
            else :    
                tdif = A[1:] - A[0:-1]    
                tbpks[c] = np.sum(tdif) / (A.size-1)
                #print(str(c)+': ', A, tdif)
    return tbpks


def sum_absolute_values(x):
    """Function time_between_peaks(x)
    Computes the sum of the absolute values for each feature in the array.

Sintax:
    sum_absolute_values(x)
Parameters:
    x: a numpy array of dimension mxn, n is the number of features to analyze
Returns:
    a numpy vector of dimension 1xn  with the time-between-peaks for each column.

In case x is a vector, then the return value is the sum of the absolute values of 
its elements.
    
For instance,if you have an ACCdf object, you can call sum_absolute_values using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> sav_a = sum_absolute_values(a.get_components())
    

    """
    if x.ndim == 1 or (x.ndim == 2 and x.shape[0]==1) :
        na = 1
    else: 
        na = 0
    return np.sum(np.abs(A),axis=na)



