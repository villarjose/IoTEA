#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 23 09:24:45 2017

@author: villarjose
"""


import numpy as np
import pandas as pd
import inspect
from scipy import signal as scsignal
import scipy.fftpack as scpyfft
import matplotlib.pyplot as plt

def wd_wrist_identification(guv, currentg, weight=0.9):
    """returns if the current gravity components (currentg) follows the gravity 
unit vector (guv) or its negative version (-guv). This function shall be use to
determine in which wrist the 3DACC wearable device is placed on.

Syntax:
    out = wd_wrist_identification(guv, currentg)
    out = wd_wrist_identification(guv, currentg, 0.8)
Parameters:
    guv:      gravity unit vector, obtained from wrist_gravity_unit_vector(). 
              This is a three component np.array.
    currentg: current g components extracted from the gathered data.
              This is a three component np.array.
    weight:   The minimum amount of signal of G the direction of guv should 
              attain to decided guv is the majority direction.          
Returns:
    1 when currentg follows guv, -1 when currentg follows -guv, 0 otherwise
    
Related functions:
    wd_wrist_identification
    wd_get_left_hand_guv
    wd_get_right_hand_guv
    
    """
    if guv.ndim != currentg.ndim or guv.size != currentg.size:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": Missmatching dimensions between guv and currentg.");
    else :
        g = np.copy(guv) / np.sqrt(np.sum(guv*guv))
        cg = np.copy(currentg) / np.sqrt(np.sum(currentg*currentg))
        r = g * cg
        p = np.sqrt(np.sum(r*r))
        if p >= weight:
            d = np.sum(np.sign(r))
            if d > 0:
                return 1
            elif d < 0:
                return -1
            else:
                return 0
        else :
            return 0

def wd_get_left_hand_guv():
    """Returns the gravity unit vector for the wearable device placed on the
left hand wrist.

Syntax:
    guv = wd_get_left_hand_guv()
Parameters:
    None
Returns:
    the three axis vector for the wearable device properly placed on the left
    hand wrist, which is [0, -1, 0].
    
This is because of how the axis of the 3DACC have been placed on the wearable 
device.

Extended versions of this function perhaps needs to get access to the WD 
technical information. Or even to a data base of valid WDs.
Related functions:
    wd_wrist_identification
    wd_get_left_hand_guv
    wd_get_right_hand_guv
    
    """    
    return np.array([0, -1, 0])

    
def wd_get_right_hand_guv():
    """Returns the gravity unit vector for the wearable device placed on the
left hand wrist.

Syntax:
    guv = wd_get_left_hand_guv()
Parameters:
    None
Returns:
    the three axis vector for the wearable device properly placed on the left
    hand wrist, which is [0, sa1, 0].
    
This is because of how the axis of the 3DACC have been placed on the wearable 
device.

Extended versions of this function perhaps needs to get access to the WD 
technical information. Or even to a data base of valid WDs.


Related functions:
    wd_wrist_identification
    wd_get_left_hand_guv
    wd_get_right_hand_guv
    wd_participant_wd_location
    wd_get_wd_hand
    
    """    
    return np.array([0, 1, 0])
    
    
def wd_participant_wd_location(currentg, win = None, defHand = 'left', wsize = 30):
    '''Returns the window with the identification of the placement of the wd

Syntax:
    w = wd_participant_wd_location(currentg, win)   
    w = wd_participant_wd_location(currentg, defHand = 'left')   
    w = wd_participant_wd_location(currentg, defHand = 'left', wsize = 30)   
    w = wd_participant_wd_location(currentg, wsize = 40)   
    w = wd_participant_wd_location(currentg, win = None, defHand = 'left', wsize = 30)   
Parameters:
    currentg:   the current ACM components of the gravity <gx, gy, gz>
    win:        the previous matches of currentg following guv or -guv. If not
                given, then it is generated with zeros, a vector of wsize size.
    defHand:    the default hand where the WD is expected. This hand defines 
                the guv accodingly.
                Valid values: 'left' 'right'. 
                Default value is 'left'
    wsize:      the window size, used when win is not given to create the first
                window with zeroes.
Returns:
    an updated sliding window, where  the value at position 0 is forgotten, 
    the -1 position is set up with the wd_wrist_identification.
    
Related functions:
    wd_wrist_identification
    wd_get_left_hand_guv
    wd_get_right_hand_guv
    wd_participant_wd_location
    wd_get_wd_hand

    '''
    defHand = defHand.lower()
    if defHand == 'left' :
        guv = wd_get_left_hand_guv()
    elif defHand == 'right':
        guv = wd_get_right_hand_guv()
    else:
        name = inspect.getframeinfo(inspect.currentframe())[2]
        raise Exception(name + ": hand reference not int {'left','right'}.");
    if type(win) == type(None):
        w = np.zeros(wsize)
    else:
        w = win
    cv = wd_wrist_identification(guv, currentg)
    if cv == 1 or cv == -1:
        w[0:-1] = w[1:]
        w[-1] = cv
    return w
    
    
def wd_get_wd_hand(win, pctg = 0.75):
    '''Returns the current guess in which nahd the wd is placed on.
    
Syntax:
   w = wd_get_wd_hand(win)    
   w = wd_get_wd_hand(win, 0.75)    
Parameters:
    win:   the np.array with the latest matches of current gravity components 
           belonging to the left or right hand. See functions
           wd_participant_wd_location
    pctg:  the minimum percentage of votes the winner hand should reach.
           Default value is 0.75
Returns:
    1 for the current hand that defines the guv, -1 for the counterhand. 
    0 whenever no candidate hand reaches the minimum vote percentage.         


Related functions:
    wd_wrist_identification
    wd_get_left_hand_guv
    wd_get_right_hand_guv
    wd_participant_wd_location
    wd_get_wd_hand
    
    '''
    sguv = np.sum(win == 1) / win.size
    snguv = np.sum(win == -1) / win.size
    if sguv >= pctg:
        return 1
    elif snguv >= pctg:
        return -1
    else:
        return 0
        
        
    
if __name__=='__main__':
    g = np.random.random(3)
    cg = np.random.random(3)
    w = wd_wrist_identification(g, cg)
    print(w)
    w = wd_participant_wd_location(cg)
    print(w)
    
    
    