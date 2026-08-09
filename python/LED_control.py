import machine
from machine import Pin, PWM
import gc


import math
import sys
import time

#from full_seq import log_seq



class dimming_sequencer(object):
    """
    To create an in-memory object capable of creating
    the dimming sequence for each colour.
    The big full dimming sequence is only held once.
    """
    def __init__(self):
        #self.full_dimming_seq = self.create_full_dimming_sequence()
        pass

    def get_seq_val(self,val):
        nat_val=math.log(val)

        return 1 - (nat_val/mx)
    
    def linear_to_log(self, linear_val):
        """
        Using the correct formula return a suitably log spaced function 
        based on the given linear float val between 0-1
        
        We need to get the end values right i.e. between 0 and 1
        with inputs with the same range
        So if we are using y=3**x as the basic curve we want the values given by that function between -2 and 2
        to give the curve we want the manipulate the 0-1 input to be across that range
        """
        def this_func(xx):
            return 8.0 ** xx
        
        topx = 2.0
        botx = -2.0
        # manipulate ip
        curve_ip = (linear_val * (topx - botx)) - topx
        # calc the actual func
        rawret = this_func(curve_ip)
        # now squash the o/p between 0-1. 
        # need the max val i.e.o/p at topx
        maxval = this_func(topx)
        
        ret = rawret/maxval
        
        
        return ret
    
    
    
    # #now trying a file that contains the premade seq
    # def create_full_dimming_sequence(self):
    #     return(log_seq)







    def get_colour_dimming_sequence(self, rgbstr, stepnum=64 ):
        """
        Will return a list of 64 steps of dimming or brightening 
        a specific RGB colour along with the position in the sequence that
        the given RGB value is in that sequence.
        """
        
        # first we need the values as integers
        levels = rgb_to_ints(rgbstr)
        # then we need to find the one with the max val
        # or at least one that has the max val
        max_col = "RED"
        if levels['GREEN'] > levels['RED']:
            max_col = "GREEN"
        if levels['BLUE'] > levels[max_col]:
            max_col = "BLUE"
        if "WHITE" in levels and levels['WHITE'] > levels[max_col]:
            max_col = "WHITE"
        max_level = float(levels[max_col])
        lesser_cols = [col for col,v in levels.items() if col != max_col]
        
        if len(lesser_cols) >= 2:
            lesser_levels = {col:levels[col] for col in lesser_cols}
        else:
            raise ValueError(
                "Colour {} is not valid as it does not have at least 2 lesser colours".format(rgbstr)) 

        
        

        # now find what proportion of the full power the max level is
        full = 255.0
        
        # we will need this to find where we are in the dimming sequence
        max_fraction = max_level/full
        
        posi = 0
        
        # dim_seq_len = len(self.full_dimming_seq)
        # we want a relatively big step for our rotary switch control
        
        # we will split the seq up into 64 steps between 0-1
        step = 1.0/stepnum
        linear_sequence = [0.0]
        i=step
        while i < 1.0 + step:
            linear_sequence.append(i)
            i += step
        
        
        # to save memory use
        # we need to replace the big sequence of floats in a log sequence with just the 
        # log sequence of linearly increasing floats we then can convert the log value with a call to 
        # a convertor function
        stepped_dimming_seq = [self.linear_to_log(rawi) for rawi in linear_sequence]
        
        
        # now find our position in it
        for posi,i in enumerate(stepped_dimming_seq):
            if max_fraction <= i:
                break
        position = posi
        # we need the ratios of the colours to stay the same over the range
        # so we will store the ratio of the lesser ones to the max value
        lesser_ratios = {col:(val/max_level if max_level else 0) 
                         for col,val in lesser_levels.items()}
        
        # now we can build the sequence as 3 lists of values keyed by colour
        # the max colour will be the same as the stepped_dimming_seq
        # because it will go from zero to 1
        # the others will be multiplied by their ratios
        # lesser_col0 = [lesser_ratios[lesser_cols[0]] * sd for sd in stepped_dimming_seq]
        # lesser_col1 = [lesser_ratios[lesser_cols[1]] * sd for sd in stepped_dimming_seq]
        # lesser_col2 = [lesser_ratios[lesser_cols[2]] * sd for sd in stepped_dimming_seq] \
        #     if len(lesser_cols) == 3 else None
        
        lesser_col_seqs  = [
            [lesser_ratios[col] * sd for sd in stepped_dimming_seq] for col in lesser_cols
        ]
        
        
        # return a dict with 3 or 4 dimming sequences identified by colour
        # and a position for the given RGB colour in the dimming sequence
        sequences = {
            max_col:stepped_dimming_seq,}
        
        for col, seq in zip(lesser_cols, lesser_col_seqs):
            sequences[col] = seq

        return {
            "position":position,
            "sequences": sequences,
        }



MAX = (2**16) - 1

colour_sequencer = dimming_sequencer()



class Direct_LED_driver(object):
    """
    Adaptation of driver written for the Magicball
    Especially for use with ESP32.
    To control an array of 3 LEDs with PWM on the ESP32.

    """
    # the frequency of the PWM signal. Although the ESP32 can do much higher frequencies, 
    # we are using the lower frequency to get us dimming resolution which was the main point 
    # of the bedlamp project. The higher frequencies give us more steps but there is a 
    # trade off with the resolution of the dimming. 
    # The lower frequencies give us more steps but they are more visible as a flicker.
    fPWM = 500
    
    def __init__(self,channels):
        """
        Takes a dict of pin numbers keyed by colour
        e.g.
        {
              "RED" : 0,
            "GREEN" : 1,
             "BLUE" : 2,
             "WHITE" : 3, # not required but can be used for a white LED if you have one
        }
        On the ESP32 the PWM levels are a 16 bit integer
        i.e. 0 - 65535
        """
        

        self.channels = channels

        # self.pins = {
        #       "RED" : PWM(Pin(channels['RED']), freq=self.fPWM ),
        #     "GREEN" : PWM(Pin(channels['GREEN']), freq=self.fPWM),
        #      "BLUE" : PWM(Pin(channels['BLUE']), freq=self.fPWM),
        # }

        self.pins = {col: PWM(Pin(channels[col]), freq=self.fPWM) for col in channels.keys()}


        # for col,this_pin in self.pins.items():
        #     this_pin.


        self.dim_seq = None
        self.dim_posi = None
        self.levels = {}
    
    def set_led(self,colour,rawduty):
        """
        Colour is a string "RED","GREEN" or "BLUE" and "WHITE" if you have a white LED
        rawduty is a 0-1 float
        So must be converted to the ESP32's level
        """
        gc.collect()
        duty = int(MAX * rawduty)
        print("colour={} raw={} duty={}".format(
            colour, rawduty, duty
        ))
        self.pins[colour].duty_u16(duty)

    def turn_off(self):
        for col in self.channels.keys():
            self.pins[col].duty_u16(0)


    def hex_to_level(self,hex):
        if(len(hex) != 2):
            raise ValueError(f"Hex value |{hex}| is not 2 digits")
        the_int = int(hex,16)
        return float(the_int/255.0) 
    
    def rgb_to_levels(self,rgb):
        """
        Takes a 6 or 8 digit RGB hex string 
        and returns a dict of the levels for each colour as floats between 0-1"""


        
        levels = {
        "RED" :  {'level':self.hex_to_level(rgb[0:2]),
                  'hex':rgb[0:2]},
        "GREEN": {'level':self.hex_to_level(rgb[2:4]),
                  'hex':rgb[2:4]},
        "BLUE" : {'level':self.hex_to_level(rgb[4:6]),
                  'hex':rgb[4:6]},
        }
        if "WHITE" in self.channels.keys():
            if len(rgb) == 8:
                levels["WHITE"] = {'level':self.hex_to_level(rgb[6:8]),
                                   'hex':rgb[6:8]}
            else:
                levels["WHITE"] = {'level':0.0,
                                   'hex':"00"}
        return levels

    def light_with_RGB(self,the_RGB, stepcount=64):
        """
        Will light the LED with the given RGB colour. 
        BUT ALSO 
        To create a dimmable sequence, this needs to be called first.
        stepcount defines how many steps in the dimming sequence
        """
        self.stepcount = stepcount
        the_levels = self.rgb_to_levels(the_RGB)
        # import pdb;pdb.set_trace()
        for col,val in the_levels.items():
            self.set_led(col,val['level'])
        self.levels = the_levels

        self.RGB = the_RGB
        
        self.setup_sequence(the_RGB, stepcount)
    

    def lights_to_saved_levels(self, the_RGB, seq_posi, stepcount=64):
        """
        To set the LEDS to the exact levels saved from UI
        """
        # first set things up
        self.setup_sequence(the_RGB, stepcount)
        
        # self.light_with_floats({
        #     "RED": self.dim_seq['RED'][seq_posi],
        #     "GREEN":self.dim_seq['GREEN'][seq_posi] ,
        #     "BLUE":self.dim_seq['BLUE'][seq_posi]   
        # },reset_seq=False)

        # we are now ensuring white will be dealt with
        self.light_with_floats({
            col: self.dim_seq[col][seq_posi] for col in self.dim_seq.keys()
        },reset_seq=False)



        self.RGB = the_RGB
        self.dim_posi = seq_posi
        self.stepcount = stepcount

    def get_exact_levels(self):
        """
        Get the save-able light values.
        Returns a dict with RGB and sequence position
        """
        return {
                     "RGB": self.RGB,
            "seq_position": self.dim_posi
        }



    def setup_sequence(self,the_RGB, stepcount):
        seq_data = colour_sequencer.get_colour_dimming_sequence(
            the_RGB, stepcount)
        self.dim_seq = seq_data['sequences']
        self.dim_posi = seq_data['position']
        
        # for this_val in self.dim_seq['RED']:
        #     print("{}".format(this_val))

    def light_with_floats(self,duties,reset_seq=True):
        """
        takes a dict of floats keyed by colour
        """
        for col,duty in duties.items():
                self.set_led(col,duty)
        if(reset_seq):
            self.dim_seq = None
            self.dim_posi = None

    
    def get_posi_duties(self):
        # return {
        #     "RED": self.dim_seq['RED'][self.dim_posi],
        #     "GREEN":self.dim_seq['GREEN'][self.dim_posi] ,
        #     "BLUE":self.dim_seq['BLUE'][self.dim_posi]
            
        # }
        return {col:self.dim_seq[col][self.dim_posi] for col in self.dim_seq.keys()}
    
    def get_posi(self):
        """
        For the max posi we will just return RED as they 
        should all be the same
        """
        if not self.dim_seq:
            return None
        else:
            return {
                "posi":self.dim_posi,
                "maxposi":len(self.dim_seq['RED']),
            }
    
    def set_brightness_on_seq(self, posi):
        """
        set the brightness of the LED on the dimming sequence
        from the integer position.
        """
        if posi > self.stepcount -1:
            posi = self.stepcount -1
        elif posi < 0:
            posi = 0

        self.dim_posi = posi

        # self.light_with_floats({
        #     "RED": self.dim_seq['RED'][posi],
        #     "GREEN":self.dim_seq['GREEN'][posi] ,
        #     "BLUE":self.dim_seq['BLUE'][posi]   
        # },reset_seq=False)

        self.light_with_floats({
            col: self.dim_seq[col][posi] for col in self.channels.keys()
        },reset_seq=False)


    
    def dim(self,step_size =1):
        #print(f"posi={self.dim_posi}")
        if self.dim_posi is None:
            return
        self.dim_posi-=step_size
        if self.dim_posi < 0:
            self.dim_posi =0
        
        #self.light_with_floats(self.dim_seq[self.dim_posi],reset_seq=False)
        self.light_with_floats(self.get_posi_duties(),reset_seq=False)
        
    def brighten(self,step_size =1):
        #print(f"posi={self.dim_posi}")
        
        if self.dim_posi is None:
            return 
        
        #import pdb;pdb.set_trace()
        self.dim_posi+=step_size
        seqlen = len(self.dim_seq['RED'])
        if not (self.dim_posi < seqlen):
            self.dim_posi = seqlen -1
            
        self.light_with_floats(self.get_posi_duties() ,reset_seq=False)
        
    
    
        
    
    

def rgb_to_ints(rgb):        
        levels = {
        "RED" :  int(rgb[0:2],16),
        "GREEN": int(rgb[2:4],16),
        "BLUE" : int(rgb[4:6],16),
        }
        return levels    






    
    
    
    
    
    
    
    
    
    
    








