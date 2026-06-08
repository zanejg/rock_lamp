#!/usr/bin/python
import sys
import time

import LED_control as LC
import random

channels = [
{
      "RED" : 5,
    "GREEN" : 18,
     "BLUE" : 19,
},
{
      "RED" : 21,
    "GREEN" : 22,
     "BLUE" : 23,
},
{
      "RED" : 33,
    "GREEN" : 25,
     "BLUE" : 26,
},
{
      "RED" : 27,
    "GREEN" : 14,
     "BLUE" : 12,
},
]


fld = LC.four_LED_driver(channels)


def check_hex(the_hex):
    """
    Check that the given string is a six digit hex number
    """
    if len(the_hex) != 6:
        return False
    
    try:
        hh = int(the_hex,16)
    except ValueError:
        return False
    
    return True


def dimwhite(col):
    for i in range(0,4):
        fld.all_same_RGB('888888')

def ledrun(command, col=None):

    if check_hex(command):
        fld.all_same_RGB(command)
    else:
        if command == "pulse":
            if col is not None:
                if check_hex(col):
                    fld.all_same_RGB(col)
                    
                    seqdata = LC.colour_sequencer.get_colour_dimming_sequence(col)
                    print(seqdata.keys())
                    
                    posi = seqdata["position"]
                    seq = seqdata['sequences']
                    slen = len(seq['RED'])
                    direction = "up"
                    while(True):
                        fld.all_same_float({
                            "RED":seq['RED'][posi],
                            "GREEN":seq['GREEN'][posi],
                            "BLUE":seq['BLUE'][posi],
                        })
                            
                        if direction == "up":
                            posi+=1
                            if posi == slen:
                                direction="down"
                        if direction == "down":
                            posi-=1
                            if posi == 0:
                                direction="up"
                        
                            
                        time.sleep(0.001)
                    
                else:
                    print("Pulse needs a colour")
        elif command == "rand":
            while(True):
                the_leds = []
                for led in range(0,4):
                    ledcol = {}
                    for col in ["RED","GREEN","BLUE"]:
                        ledcol[col] = random.randrange(0,255)/255.0
                    the_leds.append(ledcol)
                fld.set_each(the_leds)
                time.sleep(0.2)
        else:
            print("""Command (1st parm) must be one of "pulse"(with col) or "rand".""")

                    
                    
                    
                
                