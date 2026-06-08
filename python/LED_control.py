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
        max_level = float(levels[max_col])
        lesser_cols = [col for col,v in levels.items() if col != max_col]
        lesser_levels = {lesser_cols[0]:levels[lesser_cols[0]],
                        lesser_cols[1]:levels[lesser_cols[1]]}
        
        

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
        # log sequence of linearly increasing floats we then can conertha the log value with a call to 
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
        lesser_col0 = [lesser_ratios[lesser_cols[0]] * sd for sd in stepped_dimming_seq]
        lesser_col1 = [lesser_ratios[lesser_cols[1]] * sd for sd in stepped_dimming_seq]
        
        
        # return a dict with 3 dimming sequences identified by colour
        # and a position for the given RGB colour in the dimming sequence
        return {
            "position":position,
            "sequences": {
                max_col:stepped_dimming_seq,
                lesser_cols[0]:lesser_col0,
                lesser_cols[1]:lesser_col1,
            },
        }



MAX = (2**16) - 1

colour_sequencer = dimming_sequencer()



class Direct_LED_driver(object):
    """
    Adaptation of driver written for the Magicball
    Especially for use with ESP32
    """
    fPWM = 250
    
    def __init__(self,channels):
        """
        Takes a dict of pin numbers keyed by colour
        e.g.
        {
              "RED" : 0,
            "GREEN" : 1,
             "BLUE" : 2,
        }
        On the ESP32 the PWM levels are a 16 integer
        i.e. 0 - 65535


        """
        
        # self.bus = SMBus(1) # Raspberry Pi revision 2
        # self.pwm = PWM(self.bus, self.i2c_address)
        # self.pwm.setFreq(self.fPWM)

        

        self.channels = channels

        self.pins = {
              "RED" : PWM(Pin(channels['RED']), freq=self.fPWM ),
            "GREEN" : PWM(Pin(channels['GREEN']), freq=self.fPWM),
             "BLUE" : PWM(Pin(channels['BLUE']), freq=self.fPWM),
        }
        # for col,this_pin in self.pins.items():
        #     this_pin.


        self.dim_seq = None
        self.dim_posi = None
        self.levels = {}
    
    def set_led(self,colour,rawduty):
        """
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
        for col in ['RED','GREEN','BLUE']:
            self.pins[col].duty_u16(0)


    def hex_to_level(self,hex):
        if(len(hex) != 2):
            raise ValueError(f"Hex value |{hex}| is not 2 digits")
        the_int = int(hex,16)
        return float(the_int/255.0) 
    
    def rgb_to_levels(self,rgb):
        
        levels = {
        "RED" :  {'level':self.hex_to_level(rgb[0:2]),
                  'hex':rgb[0:2]},
        "GREEN": {'level':self.hex_to_level(rgb[2:4]),
                  'hex':rgb[2:4]},
        "BLUE" : {'level':self.hex_to_level(rgb[4:6]),
                  'hex':rgb[4:6]},
        }
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
        
        self.light_with_floats({
            "RED": self.dim_seq['RED'][seq_posi],
            "GREEN":self.dim_seq['GREEN'][seq_posi] ,
            "BLUE":self.dim_seq['BLUE'][seq_posi]   
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
        return {
            "RED": self.dim_seq['RED'][self.dim_posi],
            "GREEN":self.dim_seq['GREEN'][self.dim_posi] ,
            "BLUE":self.dim_seq['BLUE'][self.dim_posi]
            
        }
    
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

        self.light_with_floats({
            "RED": self.dim_seq['RED'][posi],
            "GREEN":self.dim_seq['GREEN'][posi] ,
            "BLUE":self.dim_seq['BLUE'][posi]   
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
        
    
    
        
    
    
    

class four_LED_driver(object):
    def __init__(self,LEDs):
        """
        Takes list of 4 LED driver dicts
        """
        
        self.LEDs = [Direct_LED_driver(LED) for LED in LEDs]
        
    def all_same_RGB(self,the_RGB):
        for this_LED in self.LEDs:
            this_LED.light_with_RGB(the_RGB)

    def all_same_saved(self, saved_levels):
        for idx,this_LED in enumerate(self.LEDs):
            this_LED.lights_to_saved_levels(saved_levels['RGB'], 
                                            saved_levels['seq_position'])
    
    def get_current_levels(self):
        """
        Get all of the LEDs levels
        """
        ret = [ll.get_exact_levels() 
               for ll in self.LEDs]
        print("CURRENT LEVELS = {}".format(ret))
        return ret


    def all_same_float(self,the_duties):
        """
        For this we need a dict with a float for each col
        """
        for this_LED in self.LEDs:
            for col,duty in the_duties.items():
                this_LED.set_led(col,duty)
        
    def all_off(self):
        for this_LED in self.LEDs:
            this_LED.turn_off()
        
    def set_each(self,the_leds):
        """
        Takes a list of dicts each keyed by colour
        """
        for lednum,this_led in enumerate(the_leds):
            self.LEDs[lednum].light_with_floats(this_led)
            # for col,duty in this_led.items():
            #     self.LEDs[lednum].set_led(col,duty)

    def set_all_on_seq(self, posi):
        for this_LED in self.LEDs:
            this_LED.set_brightness_on_seq(posi)
    
    def step_one_colour(self, colour,direction):
        """
        Brighten or dim one colour on all the LEDs 
        by 32 out of 256 = 256/8
        direction = "dim" or "brighten"
        """
        step_size = 32
        dir_coeff = -1 if direction=="dim" else 1
        
        rgb_list = []
        for this_led in self.LEDs:
            the_RGB = ""
            #import pdb;pdb.set_trace()
            for this_col in ['RED','GREEN','BLUE']:
                if this_col == colour:
                    current_col = int(this_led.levels[this_col]['hex'],16)
                    if (dir_coeff == -1 and current_col == 0 or
                        dir_coeff == 1 and current_col > 233):
                        # set the travel limits
                        dir_coeff =0
                    
                    new_col = current_col + (step_size * dir_coeff)
                    the_RGB += "00" if new_col < 19 else hex(new_col)[2:]
                else:
                    the_RGB += this_led.levels[this_col]['hex']
            
            rgb_list.append(the_RGB)
            
        #import pdb;pdb.set_trace()
        self.set_each_RGB(rgb_list)
            
            
    def set_each_RGB(self,the_leds):
        """
        Takes a list of RGBs
        Will also create the dimming sequences for each and
        set them up.
        If an entry is None it will skip it.
        """
        for lednum,this_RGB in enumerate(the_leds):
            if this_RGB is not None:
                self.LEDs[lednum].light_with_RGB(this_RGB)
            


def rgb_to_ints(rgb):        
        levels = {
        "RED" :  int(rgb[0:2],16),
        "GREEN": int(rgb[2:4],16),
        "BLUE" : int(rgb[4:6],16),
        }
        return levels    






    
    
    
    
    
    
    
    
    
    
    








