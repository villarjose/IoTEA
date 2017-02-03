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
    a numpy vector of dimension 1xm or mx3
    
    
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
    if x.shape[1] <= 3: #case of ACCdf
        r = np.fromiter(map(lambda v: sum(abs(v)), x), np.float)
        return np.sum(r)/len(r)
    elif x.shape[1] >=9: #case of ACC_BA_Gdf
        acc = np.fromiter(map(lambda v: sum(abs(v)), x[:,0:3]), np.float)
        ba = np.fromiter(map(lambda v: sum(abs(v)), x[:,3:6]), np.float)
        g = np.fromiter(map(lambda v: sum(abs(v)), x[:,6:9]), np.float)
        r = np.stack((acc,ba,g),axis=1)
        xlen = max(1, x.shape[0])
        return np.sum(r)/xlen
    else:
        raise Exception("SMA: Invalid number of columns of the data array.");


def aom(x):
    """Function aom(x)
    Computes the Amount of Movement as the sum of the differences between
the maximum and the minimum values in the different axis of a sample.    

Sintax:
    aom(x)
Parameters:
    x: a numpy array of dimension mxn, with n in {1, 2, 3} or n>=9
Returns:
    a numpy vector of dimension 1xm or mx3
    
    
For instance,if you have an ACCdf object, you can call sma using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> sma_a = aom(a.get_components())
    
And if you have an ACC_BA_Gdf object, you can call sma using the get_components 
method:
    >>> a = ACC_BA_Gdf(myDataFrame) #this is from a accelerometer
    >>> sma_a = aom(a.get_components())
In this latter case, SMA is computed for the acc, ba, and g components, but not 
for the modulus of these accelerations -ACC, BA and G-. Therefore, the output 
is an array of mx3 -<sma(acc), sma(ba), sma(g)>-.

    """
    if x.shape[1] <= 3: #case of ACCdf
        r = np.abs(np.max(x, axis=1) - np.min(x, axis=1))
        return np.sum(r)
    elif x.shape[1] >=9: #case of ACC_BA_Gdf
        acc = np.abs(np.max(x[:, 0:3], axis=1) - np.min(x[:, 0:3], axis=1))
        ba = np.abs(np.max(x[:, 3:6], axis=1) - np.min(x[:, 3:6], axis=1))
        g = np.abs(np.max(x[:, 6:9], axis=1) - np.min(x[:, 6:9], axis=1))
        return np.sum(np.stack((acc,ba,g),axis=1), axis=1)
    else:
        raise Exception("AOM: Invalid number of columns of the data array.");

        
        
        
        