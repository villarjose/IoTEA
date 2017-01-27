#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 27 11:35:49 2017

@author: ec1cgi
"""
import numpy as np
import pandas as pd

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


