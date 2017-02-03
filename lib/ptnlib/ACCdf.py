#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:35:49 2017

@author: villarjose at uniovi.es

"""


import numpy as np
import pandas as pd



"""
##############################################################
class ACCdf(pd.DataFrame):
This class derives from pandas.DataFrame, and its aim is to
determine if a given sequence is a tri-axial-accelerometer 
time series: that is, we may have one of the three following
scenarios:
   <x>-axis + class, so we have a mx2 DataFrame
   <x,y>-axis + class, so we have a mx3 DataFrame
   <x,y,z>-axis + class, so we have a mx4 DataFrame
   
The test method generates an Exception when the DataFrame does
not match with one of the previous options.

To create one ACCdf we use the constructor:
>>> d = pd.DataFrame([[2,0],[3,1],[4,0]])
>>> a = ACCdf(d) #if wrong, an Exception arises

To extract the components from the data -that is, forgetting 
about the class values-, you can use the get_components method:
>>> npa = a.get_components() #npa is a np.array

To obtain the class values, use the get_class method:
>>> c = a.get_class()  #c is a np.array

In all the cases, the returned arrays are COPIED from the 
original data!!!! Tha is, both get_components and get_class
method create a copy of the data.

"""
class ACCdf(pd.DataFrame):
    'A pandas.DataFrame for managing 3D acceleration samples'
    
    def test(self):
        print(self.shape[1], self.shape)
        if self.shape[1] not in [2,3,4]:
            raise Exception("not a 1/2/3 D acceleration signal")
        
    
    def __init__(self, *args, **kwargs):
        super(ACCdf, self).__init__(*args, **kwargs)
        self.test()
    
    def get_components(self):
        cn = self.shape[1]
        if cn==2:
            v = self.values[:,0]
        elif cn==3:
            v = self.values[:,0:1]
        else: #the case of 3Dacc
            v = self.values[:,0:3]
        return np.copy(v)
    
    def get_class(self):
        v = self.values[:,-1]
        return np.copy(v)


    
"""
##############################################################
class ACC_BA_Gdf(pd.DataFrame):
This class derives from pandas.DataFrame, and its aim is to
determine if a given sequence might include the tri-axial
accelerometer values from a sensor plus the Body Acceleration
and the Gravity acceleration -that should have been previously
filtered-. So, the incoming DataFrame should have dimension 
   m x (12 + 1)
with m the number of samples, 12 comes from: 3 for ACC, 3 for 
BA and 3 for G, and 3 comes from the modulus of ACC, BA and G; 
finally, the 1 comes from the class. 
   
The test method generates an Exception when the DataFrame does
not match with the previous dimension.

To create one ACC_BA_Gdf we use the constructor:
>>> d = pd.DataFrame([[2,0],[3,1],[4,0]]) #expecting a m x 13 DataFrame
>>> a = ACC_BA_Gdf(d) #if wrong, an Exception arises

To extract the components from the data -that is, forgetting 
about the class values-, you can use the get_components method.
You must specify the acceleration you wish to obtain:
    ACC_BA_Gdf.acc()  for the three components of ACC
    ACC_BA_Gdf.ba()   for the three components of BA
    ACC_BA_Gdf.g()    for the three components of G
    ACC_BA_Gdf.ACC()  for the modulus of ACC  
    ACC_BA_Gdf.BA()   for the modulus of BA   
    ACC_BA_Gdf.G()    for the modulus of G  
>>> npa = a.get_components(ACC_BA_Gdf.BA()) #npa is a np.array

To obtain the class values, use the get_class method:
>>> c = a.get_class()  #c is a np.array

In all the cases, the returned arrays are COPIED from the 
original data!!!! Tha is, both get_components and get_class
method create a copy of the data.

"""
class ACC_BA_Gdf(pd.DataFrame):
    'A pandas.DataFrame for managing 3D acceleration samples'
    
    @staticmethod
    def acc():
        return 1
    @staticmethod
    def ba():
        return 2
    @staticmethod
    def g():
        return 4
    @staticmethod
    def ACC():
        return 8
    @staticmethod
    def BA():
        return 16
    @staticmethod
    def G():
        return 32
    @staticmethod
    def ALL():
        return 64
        
    def test(self):
        print(self.shape[1], self.shape)
        if self.shape[1] != 13:
            raise Exception("not a ACC+BA+G+Class acceleration signal")
        
    
    def __init__(self, *args, **kwargs):
        super(ACCdf, self).__init__(*args, **kwargs)
        self.test()
    
    def get_components(self,comp):
        if comp == self.acc():
            v = self.values[:,0:3]
        elif comp == self.ba():
            v = self.values[:,3:6]
        elif comp == self.g(): 
            v = self.values[:,6:9]
        elif comp == self.ACC(): 
            v = self.values[:,9]
        elif comp == self.BA(): 
            v = self.values[:,10]
        elif comp == self.G(): 
            v = self.values[:,11]
        elif comp == self.ALL():
            v = self.values[:,0:-1]
        return np.copy(v)
    
    def get_class(self):
        v = self.values[:,-1]
        return np.copy(v)
    
    
        
