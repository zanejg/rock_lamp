#!/usr/bin/python
import sys
import time

import LED_control as LC
import random

from hardware import channels

# channels = [
# {
#     "RED" : 0,
#     "GREEN" : 1,
#     "BLUE" : 2,
# },
# {
#     "RED" : 5,
#     "GREEN" : 4,
#     "BLUE" : 3,
# },
# {
#     "RED" : 8,
#     "GREEN" : 7,
#     "BLUE" : 6,
# },
# {
#     "RED" : 11,
#     "GREEN" : 10,
#     "BLUE" : 9,
# },
# ]


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



if __name__ == "__main__":
    args = sys.argv
    if len(args)<2:
        for i in range(0,4):
            fld.all_same_RGB('888888')
    
    else:
        #LEDnum = int(args[1])
        command = args[1]
        #import pdb;pdb.set_trace()
        if check_hex(command):# != "cycle":
            fld.all_same_RGB(command)
        else:
            if command == "pulse":
                if len(args) > 2:
                    col = args[2]
                    if check_hex(col):
                        fld.all_same_RGB(col)
                        
                        seqdata = LC.get_colour_dimming_sequence(col)
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
                    
                    
                    
                    
                
                