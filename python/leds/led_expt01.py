#!/usr/bin/python
import sys
import time

from smbus import SMBus

from PCA9685 import PWM



# channels = {
#     "RED" : 0,
#     "GREEN" : 1,
#     "BLUE" : 15,
# }
channels = {
    "RED" : 11,
    "GREEN" : 10,
    "BLUE" : 9,
}





class LED_driver(object):
    fPWM = 1000
    i2c_address = 0x40 # (standard) adapt to your module
    #channel = 0 # adapt to your wiring

    def __init__(self):
        
        self.bus = SMBus(1) # Raspberry Pi revision 2
        self.pwm = PWM(self.bus, self.i2c_address)
        self.pwm.setFreq(self.fPWM)
    
    def light_led(self,colour,duty):
        self.pwm.setDuty(channels[colour], duty)


    def hex_to_level(self,hex):
        if(len(hex) != 2):
            raise ValueError("Hex value not 2 digits")
        the_int = int(hex,16)
        return float(the_int/255.0) 
    
    def rgb(self,rgb):
        
        levels = {
        "RED" :  self.hex_to_level(rgb[0:2]),
        "GREEN": self.hex_to_level(rgb[2:4]),
        "BLUE" : self.hex_to_level(rgb[4:6]),
        }
        return levels

    def light_with_RGB(self,the_RGB):
        the_levels = self.rgb(the_RGB)
        # import pdb;pdb.set_trace()
        for col,val in the_levels.items():
            self.light_led(col,val)


the_leds = LED_driver()
#the_leds.light_with_RGB("EEEEEE")

cycsize = 300

if __name__ == "__main__":
    args = sys.argv
    if len(args)<2:
        the_leds.light_with_RGB('FFFFFF')
    else:
        if args[1] != "cycle":
            the_leds.light_with_RGB(args[1])
        else:
            the_leds.light_with_RGB("FF0000")
            for b in range(1,cycsize):
                bval = float(b/cycsize)
                the_leds.light_led("GREEN",bval)
                time.sleep(0.001)
                
                
        

