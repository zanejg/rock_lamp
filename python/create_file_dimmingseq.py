import math
import pdb



def create_full_dimming_sequence():
        """
        Create a sequence of 2048 coefficients to use for dimming a light in logarithmic seq.
        For creating apparent linear dimming for human eye.
        Returns a sequence of coeficients between zero and one that progresses downward 
        logarithmically where the steps become smaller as it approaches 0
        To get a curve that seems appropriate I have used nat logs between 1 and 100
        """
        
        # get a sequnece of 2048 floats bet 1 and 128
        max_val = 129
        mx = math.log(max_val)

        # to minimise mem usage we will be doing the full calcs on the one
        # copy of the array
        def get_seq_val(val):
            nat_val=math.log(val)

            return 1 - (nat_val/mx)

        x = []
        for i in range(1,129):
            xf = float(i)
            x.append(get_seq_val(xf))
            for j in range(1,17):
                jf = j/16.0
                x.append(get_seq_val(xf+jf))

        # then get their nat logs
        # y=[math.log(i) for i in x]
        #y = [2**i for i in x]
        
        # need the max val
        # mx = y[-1]
        # then divide all the vals by the max val for a sequence bet 0-1
        # coeffs = [1-c/mx for c in y]
        # now reverse it for convenience
        x.reverse()
        
        return x 


with open("full_seq.py", "w") as opfile:
    the_seq = create_full_dimming_sequence()

    opfile.write("log_seq = [\n")
    for this_val in the_seq:
        opfile.write(f"{this_val},\n")

    opfile.write("]\n")


