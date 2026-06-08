from rotary_irq_esp import RotaryIRQ
import time
from machine import Pin



# CLOCK = 11
# DATA = 10
# BUTTON = 9
        
CLOCK = 34
DATA = 39
BUTTON = 36


btn = Pin(BUTTON, Pin.IN)


def rt():

    print("setting up rotary")
    
    
    r = RotaryIRQ(pin_num_clk=CLOCK, 
                pin_num_dt=DATA, 
                min_val=0, 
                max_val=25, 
                reverse=True, 
                range_mode=RotaryIRQ.RANGE_WRAP)

    
    


              
    val_old = r.value()

    print("Loop")
    while(True):
        print("value={} button={}".format(r.value(), btn.value()))
        time.sleep_ms(100)

    
    
    
    