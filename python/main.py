import machine
from machine import Pin, PWM

import _thread as th
import socket
import json
import ure


import time
#from e32LEDdriver import eld.parse_command
import e32LEDdriver as eld

# # To run the LEDs for testing
# import e32LEDrun as run

upy_img = """
    <br/>
    <a title="Micropython.org, MIT &lt;http://opensource.org/licenses/mit-license.php&gt;, via Wikimedia Commons" 
        href="https://commons.wikimedia.org/wiki/File:MicroPython_new_logo.svg">
        <img width="50" alt="MicroPython new logo" 
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/MicroPython_new_logo.svg/256px-MicroPython_new_logo.svg.png">       
    </a>
    """



#######################################################################
#### WEB BASED EVENT LOOP 
#######################################################################
the_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
the_socket.bind(('', 80))
the_socket.listen(2)

parm_rex = ure.compile(".*LAMP_COMMAND\=\|\|\|(.*)\|\|\|")
path_rex = ure.compile(".*GET \/(.*) HTTP.*")


print("About to start event loop")

while True:
   

    conn, addr = the_socket.accept()
    print('Got a connection from %s' % str(addr))
    request = conn.recv(512)
    #request = str(request)
    request = request.decode('utf-8')
    reqlist= request.split("\n")
    pathsearch = path_rex.search(reqlist[0])
    if pathsearch:
        path = pathsearch.group(1)
    else:
        path = "No path"
    print("PATH = {}".format(path))

    print('Content = @@@@@@@@@@@@@@###########@@@@@@@@@@\n %s @@@@@@@@@@@@@@###########@@@@@@@@@@\n' % request)
    
    if(request[0:4] == 'POST'):
        """
        Receive commands from the page's Javascript
        """
        res = parm_rex.search(reqlist[-1])
        if res:
            passed_cmd = res.group(1)
            cmd = json.loads(passed_cmd)
            print("PASSED COMMAND = #{}#".format(cmd))
            # SEND THE COMMAND TO THE LED DRIVER
            eld.parse_command(cmd)
            
    elif(request[0:3] == 'GET'):
        """
        Serve the control page
        
        """
        if len(path.strip()) == 0:
            # response = web_page()
            page_text = str(open("lamp_page.html").read(-1))
            response = page_text.replace("## MICROPYTHON IMAGE ##",upy_img)
            conn.send('HTTP/1.1 200 OK\n')
            conn.send('Content-Type: text/html\n')
            #conn.send('Connection: close\n\n')
            #conn.sendall(response)
            datalen = len(response)
            print("writing:||| {}... |||".format(response[:100]))
            sent_num = conn.write(response)
            while sent_num < datalen:
                print("sending another lump from {}".format(sent_num))
                sent_num += conn.write(response[sent_num:])

            
        elif path == "GETLEVEL":
            the_levels = eld.parse_command({'command':"GETLEVEL"})
            response = "\n{}\n".format(json.dumps(the_levels))
            responsebytes = bytes(response,'utf8')
            print("*** Sending back:{}  ***".format(responsebytes))
            conn.send('HTTP/1.1 200 OK\r\n')
            conn.send('Content-Type: application/json\r\n')
            #conn.sendall(response)
            conn.write(responsebytes)

        elif path == "favicon.ico":
            with open('favicon.ico','rb') as fvfile:
                favicon = fvfile.read()

                print("*** Sending back: Favicon  ***")
                conn.send('HTTP/1.1 200 OK\r\n')
                conn.send('Content-Type: image/x-icon\r\n')
                #conn.sendall(response)
                conn.write(favicon)

    
    conn.close()
    
