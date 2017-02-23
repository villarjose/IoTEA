#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:28:15 2017

@author: villarjose
"""
import numpy as np
import pandas as pd
import inspect
from scipy import signal as scsignal
import scipy.fftpack as scpyfft
import matplotlib.pyplot as plt

    
######################################
## Section devoted to transformations
######################################
def sma(x, axis = 0):
    """Function sma(x)
    Computes the Signal Magnitude Area as the sum of the absolute values of its 
    components in each dimension.

Sintax:
    sma(x)
Parameters:
    x: a numpy array of dimension mxn, with n in {1, 2, 3} or n>=9
    axis:   the axis along with the data series is stored. 
            Follows the python criteria: -1, 0 (default), 1, ...
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
    if x.ndim == 1:
        r = np.sum(np.abs(x))
        rlen = max(1, r.size)
        return r / rlen
    elif x.ndim > 2:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Invalid dimensions of the data array.");
    else:
        rdim = np.max(x.shape * (np.linspace(0, x.ndim-1, x.ndim) == (1-axis)) )
        if rdim > 3 and rdim < 9:
            name = inspect.getframeinfo(inspect.currentframe())[2]
            raise Exception(name + ": Invalid number of columns of the data array.");#def sma(x):
        elif rdim <= 3 :
            r = np.sum(np.abs(x)) # np.fromiter(map(lambda v: sum(abs(v)), x), np.float)
            rlen = max(1, x.shape[axis])
            return r/rlen
        else : #rdim sholud be >=9
            if axis == 0:
                X = x
            else :
                X = x.T
            acc = np.sum(np.abs(X[:,0:3]))
            ba = np.sum(np.abs(X[:,3:6]))
            g = np.sum(np.abs(X[:,6:9]))
            if axis == 0:
                r = np.stack((acc, ba, g)) #np.stack((acc,ba,g),axis=1)
            else :
                r = np.stack((acc, ba, g))
            rlen = max(1, x.shape[axis])
            return r/rlen


def aom(x, axis = 0):
    """Function aom(x)
    Computes the Amount of Movement as the sum of the differences between
the maximum and the minimum values in the different axis of a sample.    

Sintax:
    aom(x, axis)
Parameters:
    x: a numpy array of dimension mxn, with n in {2, 3} or n>=9
    axis:   the axis along with the data series is stored. 
            Follows the python criteria: -1, 0 (default), 1.
            It is not allowed to have mode than 2 dimensions
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
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Invalid dimensions of the data array.");
    elif x.ndim == 1:
        return np.abs(np.max(x) - np.min(x))
    else :
        rdim = np.max(x.shape * (np.linspace(0, x.ndim-1, x.ndim) == (1-axis)))
        if rdim > 3 and rdim < 9:
            name = inspect.getframeinfo(inspect.currentframe())[2]
            raise Exception(name + ": Invalid number of columns of the data array.");
        elif rdim <= 3:
            if axis == 0:
                X = x
            else:
                X = x.T
            Xlen = X.shape[0]
            return np.sum(np.abs(np.max(X, axis = 0) - 
                                 np.min(X, axis = 0))) / Xlen
        else : # rdim >= 9!!
            if axis == 0:
                X = x
            else: 
                X = x.T
            Xlen = X.shape[0]
            acc = np.sum(np.abs(np.max(X[:, 0:3], axis = 0) - np.min(X[:, 0:3], axis = 0) ) )
            ba = np.sum(np.abs(np.max(X[:, 3:6], axis = 0) - np.min(X[:, 3:6], axis = 0) ) )
            g = np.sum(np.abs(np.max(X[:, 6:9], axis = 0) - np.min(X[:, 6:9], axis = 0) ) )
            return np.stack((acc,ba,g))/Xlen


        
def time_between_peaks(x, n = 2, K = 0.9, axis = 0):
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
    time_between_peaks(x, n = 2, K = 0.9, axis = 0)
Parameters:
    x: a numpy array of dimension mxn, n is the number of features to analyze.
       dimensions higher than 2 raise exceptions.
    n: the minimum numer of peaks to detect, default value is 2.
    K: the constant for computing the threshold, default value is 0.9
    axis: the axis along which the data series are arranged, default value is 0
          follows the python criteria. Allowable values are -1, 0, 1.
Returns:
    a numpy vector of dimension 1xn  with the time-between-peaks for each column.
    
    
For instance,if you have an ACCdf object, you can call time-between-peaks using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> tbpks_a = time_between_peaks(a.get_components())
    

    """
    if x.ndim > 2:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Invalid dimensions of the data array.");
    elif x.ndim == 1:
        m = np.mean(x)
        s = np.std(x)
        r = np.array(x > (m + 0.9 * s), dtype = np.float_)
        R = r[1:] - r[0:-1]
        ncolumns = 1
        tbpks = np.zeros(ncolumns)
        A=np.arange(0,R.shape[0])[R==1]
        if A.size > n:
            tdif = A[1:] - A[0:-1]    
            tbpks[0] = np.sum(tdif) / (A.size-1)
        return tbpks
    else :
        if axis == 0:
            X = x
        else :
            X = x.T    
        m = np.mean(X, axis = 0)
        s = np.std(X, axis = 0)
        r =  np.array(X > (m + 0.9 * s), dtype = np.float_) 
        R = r[1:, :] - r[0:-1, :] 
        nvars = X.shape[1]
        tbpks = np.zeros(nvars)
        for c in range(nvars):
            A=np.arange(0,R.shape[0])[R[:,c]==1]
            if A.size < n:
                continue
            else :    
                tdif = A[1:] - A[0:-1]    
                tbpks[c] = np.sum(tdif) / (A.size-1)
        return tbpks


def sum_absolute_values(x, axis = 0):
    """Function sum_absolute_values(x)
    Computes the sum of the absolute values for each feature in the array.

Sintax:
    sum_absolute_values(x)
Parameters:
    x: a numpy array of dimension mxn, n is the number of features to analyze
    axis:  -1, 0, 1. According to python criteria. Higher dimensions raise an
           exception. Default value is 0.
Returns:
    a numpy vector of dimension 1xn  with the time-between-peaks for each column.

In case x is a vector, then the return value is the sum of the absolute values of 
its elements.
    
For instance,if you have an ACCdf object, you can call sum_absolute_values using the 
get_components method:
    >>> a = ACCdf(myDataFrame) #this is from a accelerometer
    >>> sav_a = sum_absolute_values(a.get_components())
    

    """
    if x.ndim > 2:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Invalid dimensions of the data array.");
    elif x.ndim == 1:
        return np.sum(np.abs(x))
    else: 
        return np.sum(np.abs(x),axis=axis)




######################################
## Section devoted to FFT
######################################
def fft_wf(X, wf = 'hanning', axis = 0):
    """Function fft_wf
    Returns the required window function for computing FFT.

Column vectors are supposed. 
However, you are free to choose the axis following the python criteria:
    axis is 0  then the data is arranged in column vectors
    axis is 1  then the data is arranged in row vectors
    axis is 2  then your data is a surface with axis 1 and 2...
    axis is -1 then fft considers the last dimension
The default value is 0.

Syntax:    
    y = fft_wf(X)
    y = fft_wf(X, wf = 'hanning')
    y = fft_wf(X, axis = 0)
    y = fft_wf(X, 'hanning',  0)
Parameters:
    X:    the data, which is required for determining the output dimensions
    wf:   the window function name. Valid values are: {'hanning', 'hamming',
          'bartlett', 'blackman', 'kaiser'}.
          A different value raises an exception.
          Default value is 'hanning', which is the best one to force the 
          'periodicity' of the signal in X.
    axis: the dimension of X that represents the window size. See comment above.
Returns:
    the vector/matrix with the repetitions of the window so the size and shape 
    matches that of X

FFT related functions:
    fft_wf
    fft_fft
    fft_fft_energy
    fft_energy
    
Related links:
    http://www.ni.com/white-paper/4844/es/
    https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.fftpack.fft.html
    https://docs.scipy.org/doc/numpy-1.10.0/reference/routines.window.html
        
    """
    if wf == 'hanning':
        if X.ndim == 1:
            return np.hanning(X.size)#.reshape(X.shape)
        elif axis == 0:
            return np.tile(np.hanning(X.shape[0]), reps = [X.shape[1], 1]).T
        elif axis == 1:
            return np.tile(np.hanning(X.shape[1]), reps = [X.shape[0], 1])
    elif wf == 'bartlett':
        if X.ndim == 1:
            return np.bartlett(X.size)#.reshape(X.shape)
        elif axis == 0:
            return np.tile(np.bartlett(X.shape[0]), reps = [X.shape[1], 1]).T
        elif axis == 1:
            return np.tile(np.bartlett(X.shape[1]), reps = [X.shape[0], 1])
    elif wf == 'blackman':
        if X.ndim == 1:
            return np.blackman(X.size)#.reshape(X.shape)
        elif axis == 0:
            return np.tile(np.blackman(X.shape[0]), reps = [X.shape[1], 1]).T
        elif axis == 1:
            return np.tile(np.blackman(X.shape[1]), reps = [X.shape[0], 1])
    elif wf == 'hamming':
        if X.ndim == 1:
            return np.hamming(X.size)#.reshape(X.shape)
        elif axis == 0:
            return np.tile(np.hamming(X.shape[0]), reps = [X.shape[1], 1]).T
        elif axis == 1:
            return np.tile(np.hamming(X.shape[1]), reps = [X.shape[0], 1])
    elif wf == 'kaiser':
        if X.ndim == 1:
            return np.kaiser(X.size,  4.65448)#.reshape(X.shape)
        elif axis == 0:
            return np.tile(np.kaiser(X.shape[0],  4.65448), reps = [X.shape[1], 1]).T
        elif axis == 1:
            return np.tile(np.kaiser(X.shape[1],  4.65448), reps = [X.shape[0], 1])
    else:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Invalid name for a numpy window function.");


def fft_fft(X, axis = 0):
    """Fucntion fft_fft
    Computes the FFT using the scypy.fftpack package.

This is a sort of decorator which assumes that by default your data is arranged in column vectors.    

However, you are free to choose the axis following the python criteria:
    axis is 0  then the data is arranged in column vectors
    axis is 1  then the data is arranged in row vectors
    axis is 2  then your data is a surface with axis 1 and 2...
    axis is -1 then fft considers the last dimension
The default value is 0.

Syntax:
    y = fft_fft(X)
    y = fft_fft(X, a)
Parameters:
    X:     the vecotr/matrix with the data
    a:     the axis: -1, 0 (default), 1, ...
Returns:
    y:     the vector/matrix with the fft coefficients.

FFT related functions:
    fft_wf
    fft_fft
    fft_fft_energy
    fft_energy
    
Related links:
    http://www.ni.com/white-paper/4844/es/
    https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.fftpack.fft.html
    https://docs.scipy.org/doc/numpy-1.10.0/reference/routines.window.html
        
    """
    if X.ndim == 1:
        return scpyfft.fft(X)
    else :
        return scpyfft.fft(X, axis)


def fft_fft_energy(X, axis = 0):
    """Fucntion fft_fft_energy
    Computes the energy in the frequency domain by computing FFT using the scypy.fftpack package.

This is a sort of decorator which assumes that by default your data is arranged in column vectors.    

However, you are free to choose the axis following the python criteria:
    axis is 0  then the data is arranged in column vectors
    axis is 1  then the data is arranged in row vectors
    axis is 2  then your data is a surface with axis 1 and 2...
    axis is -1 then fft considers the last dimension
The default value is 0.

Syntax:
    y = fft_fft_energy(X)
    y = fft_fft_energy(X, a)
Parameters:
    X:     the vecotr/matrix with the data
    a:     the axis: -1, 0 (default), 1, ...
Returns:
    y:     the sum of the squares of the FFT components along the given axis.
           all the elements are np.float_

FFT related functions:
    fft_wf
    fft_fft
    fft_fft_energy
    fft_energy
    
Related links:
    http://www.ni.com/white-paper/4844/es/
    https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.fftpack.fft.html
    https://docs.scipy.org/doc/numpy-1.10.0/reference/routines.window.html
        
    """
    f = fft_fft(X, axis)
    return np.sum(f*np.conj(f), axis, dtype = np.float_)
    

def fft_energy(f, axis = 0):    
    """Fucntion fft_energy
    Computes the energy of the given signals.

This is a sort of decorator which assumes that by default your data is arranged in column vectors.    

However, you are free to choose the axis following the python criteria:
    axis is 0  then the data is arranged in column vectors
    axis is 1  then the data is arranged in row vectors
    axis is 2  then your data is a surface with axis 1 and 2...
    axis is -1 then fft considers the last dimension
The default value is 0.

Syntax:
    y = fft_energy(X)
    y = fft_energy(X, a)
Parameters:
    X:     the vecotr/matrix with the FTT transformation  
    a:     the axis: -1, 0 (default), 1, ...
Returns:
    y:     the sum of the squares of the FFT components along the given axis.
           all the elements are np.float_

FFT related functions:
    fft_wf
    fft_fft
    fft_fft_energy
    fft_energy
    
Related links:
    http://www.ni.com/white-paper/4844/es/
    https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.fftpack.fft.html
    https://docs.scipy.org/doc/numpy-1.10.0/reference/routines.window.html
        
    """
    return np.sum(f*np.conj(f), axis, dtype = np.float_)
        

######################################
## Section devoted to filtering
######################################
def filter_ellip_design(n=3,Rp=1.0,Rs=80.0, wn=0.25,tpe='lowpass'):
    """Function filter_ellip_design
    Creates an elliptical filter for the set of given parameters. This is rather specific to this project.

Syntax:
    filter_ellip_design(n=3,Rp=1,Rs=80, wn=0.25,tpe='lowpass')
Parameters:
    The parameters follow the statements publish at https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.signal.ellip.html
    n:      the order of the filter
    Rp:     the maximum ripple allowed below unity gain in the passband. In db.
    Rs:     the minimum attenuation required in the stop band, in db.
    wn:     a scalar or length-2 sequence giving the critical frequencies. 
    tpe:    should be in ['lowpass', 'highpass', 'bandpass', 'bandstop']
    
    The remaining ellip parameters are preset to analog=False and output='ba'.
Returns:
    b, a:   ndarray, ndarray. Numerator (b) and denominator (a) polynomials of the IIR filter. 


Example of use:
    >>>  n,d = filter_ellip_design(8, 3.0, 3.5, 0.25, 'highpass')

Filtering related functions:
    filter_ellip_design
    filter_acc_create_filters
    filter_filtering_column_wise
    filter_acc_component_filtering
    

    """
    if tpe not in ['lowpass', 'highpass', 'bandpass', 'bandstop']:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": wrong type of filter. It should be 'high' or 'low'") 
    num, den = scsignal.ellip(N=n, rs=Rs, rp=Rp, Wn=wn, btype=tpe, analog=False, output='ba')
    return (num, den)

    
def filter_acc_create_filters():
    """Creates the filter polynomia and the sliding windows for obtaining BA and G from raw ACC.
    
Syntax:
    ba_num, ba_den, ba_zi, g_num, g_den, g_zi, ba_order, g_order = filter_acc_create_filters()
Returns:
    ba_num:   the numerator for filtering the BA from the raw ACC
    ba_den:   the denominator for filtering the BA from the raw ACC 
    ba_zi:    the BA previous state window, needed to compute the next filter step. A column per
              each of the axis components of the ACC.
    g_num:    the numerator for filtering the G from the raw ACC 
    g_den:    the denominator for filtering the G from the raw ACC  
    g_zi:     the G previous state window, needed to compute the next filter step. A column per
              each of the axis components of the ACC. 
    ba_order: the order of the BA highpass filter 
    g_order:  the order of the G lowpass filter
    
Filtering related functions:
    filter_ellip_design
    filter_acc_create_filters
    filter_filtering_column_wise
    filter_acc_component_filtering
    
Extra doc I've used:
    http://mpastell.com/2009/05/11/iir-filter-design-with-python-and-scipy/
    
    """
    [hpf_b, hpf_a]=filter_ellip_design(8, 3, 3.5, 0.25, 'highpass')
    [lpf_b, lpf_a]=filter_ellip_design(3, 0.1, 100, 0.3, 'lowpass')
    #these are the initial conditions for each filter: BA-->hpf, G-->lpf
    #they are all initilized to zero.
    orderLow=3 
    orderHigh=8
    hpf_ba_zi = scsignal.lfilter_zi(hpf_b, hpf_a) 
    lpf_g_zi = scsignal.lfilter_zi(lpf_b, lpf_a) 
    hpf_ba_zi = np.tile(hpf_ba_zi.reshape(-1,1), [1, 3]) #one per axis!
    lpf_g_zi = np.tile(lpf_g_zi.reshape(-1,1), [1, 3])
    return (hpf_b, hpf_a, hpf_ba_zi, lpf_b, lpf_a, lpf_g_zi, orderLow, orderHigh)



def filter_filtering_column_wise(x, num, den, z):
    """Applies the given IIR filter polynomia -with the initial conditions- to column vector x.
    
Syntax:
    y, zf = filter_filtering_column_wise(x, num, den, z)
Parameters:
    x:     the column vector on which the filter is to be computed
    num:   the filter's numerator polynomial
    den:   the filter's denominator polynomial
    z:     the initial conditions
Returns:
    y:     the filtered output
    zf:    the next call's initial conditions
    
Filtering related functions:
    filter_ellip_design
    filter_acc_create_filters
    filter_filtering_column_wise
    filter_acc_component_filtering
    
    """
    y, zf = scsignal.lfilter(num, den, x, axis=-1, zi=z*x[0])
    return y, zf


def filter_acc_component_filtering(X, num, den, Z):
    """Applies the given IIR filter polynomia -with the initial conditions- to several column features in x.
    
    This function calls filter_filtering_column_wise for each column vector, and then compounds the output.
    
    The way this function should be used is illustrated with an example:
    >>> ba_num, ba_den, ba_zi, g_num, g_den, g_zi, ba_order, g_order = filter_acc_create_filters()
    >>> ...
    >>> ACC = np.random.random((100,3)) #let's suppose this is a 3DACC sliding window
    >>> ba, ba_zi = filter_acc_component_filtering(ACC, ba_num, ba_den, ba_zi)
    >>> g, g_zi = filter_acc_component_filtering(ACC, g_num, g_den, g_zi)
    Now we have the corresponding filtered BA and G for the current sliding window, plus the initial conditions
    of future calls.
    
Syntax:
    y, zf = filter_acc_component_filtering(x, num, den, z)
Parameters:
    x:     the column matrix, with several column acc fetures, on which the filter is to be computed
    num:   the filter's numerator polynomial
    den:   the filter's denominator polynomial
    z:     the initial conditions, with the same number of columns as x
Returns:
    y:     the filtered output, one column per column in x
    zf:    the next call's initial conditions, one column per column in x
    
Filtering related functions:
    filter_ellip_design
    filter_acc_create_filters
    filter_filtering_column_wise
    filter_acc_component_filtering
    
    """    
    Y = np.zeros(X.shape)
    zf = np.zeros(Z.shape)
    for i in range(X.shape[1]):
        Y[:,i],zf[:,i] = filter_filtering_column_wise(X[:,i], num, den, Z[:,i])
    return Y,zf




def main():
    pass

if __name__ == '__main__':
    x = np.random.random((32,3))
    X = np.random.random((32,12))
    XT = X.T
    xt = x.T
    q = np.tile(x,reps=3)
    
    time_between_peaks(x)
    
    main()
