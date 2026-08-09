import machine

import time

# # To run the LEDs for testing
# import e32LEDrun as run
import LED_control

# for a start we will onlly be using a button to try different colours and brightness levels



pin_array = {
    "RED" : 16,
    "GREEN" : 17,
    "BLUE" : 18,
    "WHITE" : 19,
}

BUTTON_PIN = 0


led_colours = [
    "FF000000",
    "00FF0000",
    "0000FF00",
    "000000FF",
    "FFFFFFFF",
    "80FFFF00",
    "00000000",
    "05050505",
]


led_driver = LED_control.Direct_LED_driver(pin_array)

led_driver.light_with_RGB("FFFFFFFF")



button_pin = machine.Pin(BUTTON_PIN, machine.Pin.IN, machine.Pin.PULL_UP)

this_colour_idx = 3

while True:
    if button_pin.value() == 0:
        print("Button pressed")
        this_colour_idx = (this_colour_idx + 1) % len(led_colours)
        led_driver.light_with_RGB(led_colours[this_colour_idx])
        time.sleep(0.3)
        while button_pin.value() == 0:
            time.sleep(0.02)
    time.sleep(0.02)

