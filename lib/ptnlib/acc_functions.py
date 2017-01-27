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
    Computes the Signal Amount Ratio as the sum of the absolute values of its 
    components in each dimension.

Sintax:
    sma(x)
Parameters:
    x: a numpy array of dimension mxn
Returns:
    a numpy vector of dimension 1xm
    
    
For instance,if you have an ACCdf object, you can call sma using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> sma_a = sma(a.get_components())
    
    """
    r = np.fromiter(map(lambda x: sum(abs(x)), p), np.float)
    return sum(r)/len(r)
