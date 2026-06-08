import machine
from machine import Pin, PWM

import time



pwm0 = PWM(Pin(5))         # create PWM object from a pin
freq = pwm0.freq()         # get current frequency (default 5kHz)
pwm0.freq(1000)            # set PWM frequency from 1Hz to 40MHz

# arr = [34,35,32,33,25,26,27,14,12,13,23,22,21,19,18,5,17,16,4,0,2,15]


# for i in arr:
# 	try:
# 		this_pwm = PWM(Pin(i))
# 		print("PIN {} IS supported".format(i))
# 	except ValueError:
# 		print("PIN {} NOT supported".format(i))



# cc = 0
# start_time = time.ticks_us()
# print("start")
# for i in range(0,65535):
#     cc=i
# stop_time = time.ticks_us()
# run_time_secs  = (stop_time - start_time) / (10**6)
# print("time taken = {} secs ".format(run_time_secs))



duty_u16 = pwm0.duty_u16() # get current duty cycle, range 0-65535
# set duty cycle from 0 to 65535 as a ratio duty_u16/65535, (now 75%)
duty_denom = 2**16




#pwm0.duty_u16(2**16*3//4)  
print("start counter duty")
duty_step = duty_denom//100
this_duty = 0
for i in range(0,10):
	for the_duty in range(0,65535):
		pwm0.duty_u16(the_duty)
		time.sleep_us(100)
	print("loop")
	
