class light_driver(object):
    def __init__(self):
        
    
    def one(self,sent_colour,intensity = int(MAX16/2)):
        for colour,conf in self.config.items():
            if colour == sent_colour:
                self.pwms[colour].duty_u16 ( intensity )
            else:
                self.pwms[colour].duty_u16 ( 0)
    
    def hex_to_level(self,hex):
        if(len(hex) != 2):
            raise ValueError("Hex value not 2 digits")
        the_int = int(hex,16)
        return int((the_int/255) * MAX16)
    
    def rgb(self,rgb):
        
        levels = {
        "red" :  self.hex_to_level(rgb[0:2]),
        "green": self.hex_to_level(rgb[2:4]),
        "blue" : self.hex_to_level(rgb[4:6]),
        }
        
        
        for colour,conf in self.config.items():
            self.pwms[colour].duty_u16 ( levels[colour] )
        
    
    def rgbw(self,rgb ,w="00"):
        self.rgb(rgb)
        if w != "00":
            self.wht_pwm.duty_u16 ( self.hex_to_level(w) )
        else:
            self.wht_pwm.duty_u16 (0)
    
    
    def cycle(self):
        ctr = 0
        while(True):
            for thiscol,pwm in self.pwms.items():
                pwm.duty_u16(self.cycles[thiscol][ctr%self.config[thiscol]['steps']])
            
            sleep(self.sleep_time)
            ctr+=1