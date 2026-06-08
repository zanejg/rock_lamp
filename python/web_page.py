
upy_img = """
    <br/>
    <a title="Micropython.org, MIT &lt;http://opensource.org/licenses/mit-license.php&gt;, via Wikimedia Commons" 
        href="https://commons.wikimedia.org/wiki/File:MicroPython_new_logo.svg">
        <img width="50" alt="MicroPython new logo" 
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/MicroPython_new_logo.svg/256px-MicroPython_new_logo.svg.png">       
    </a>
    """


def web_page():
    
    


    html = """
<html>
    <head> 
        <title>ESP Web Server</title> 
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="icon" href="data:,"> 
        <style>
            html{font-family: Helvetica; display:inline-block; margin: 0px auto; text-align: center;}
            h1{color: #0F3376; padding: 2vh;}
            p{font-size: 1.0rem;}
            .button{display: inline-block; 
                    background-color: #e7bd3b; 
                    border: none; 
                    border-radius: 6px; 
                    color: white; 
                    padding: 10px 25px; 
                    text-decoration: none; 
                    font-size: 20px; 
                    margin: 2px; 
                    cursor: pointer;}
            .redbutton{background-color: red;}
            .bluebutton{background-color: blue;}
            .greenbutton{background-color: green;}
            
            input[type="range"][orient="vertical"] {
                writing-mode: bt-lr;
                appearance: slider-vertical;
                min:"0";
                max:"255";
                }

            .brightness_slider{
                        min:"0";
                        max:"255";
                    }

        </style>
        

    </head>
    <body > 
        <script>
            var cmd_array = {
                "ALLHIGH":{'command':"ALLHIGH"},
                /* rotating */
                "OFF":{'command':"OFF"},
            };
            

            function send_command(the_cmd){
                var xhttp = new XMLHttpRequest();
                ret  = cmd_array[the_cmd];

                retstr = JSON.stringify(ret)
                // alert(retstr)
                
                xhttp.open("POST", "/", true);
                xhttp.send("LAMP_COMMAND=|||"+retstr+"|||");
                
            }
            function change_brightness(){
                var all_slider = document.getElementById("all_slider");
                
                var the_val = all_slider.value
                var xhttp = new XMLHttpRequest();

                ret = {
                    "command":"SETBRIGHTNESS",
                    "value":the_val
                }

                //alert("command="+ret['command']+ " val="+the_val)

                xhttp.open("POST", "/", true);
                xhttp.send("LAMP_COMMAND=|||"+retstr+"|||");
                    
            }

        </script>
        <h1>Zane's ESP Lamp Web Server</h1> 

        
        <p><button onclick="send_command('ALLHIGH')" class="button greenbutton">ON</button></p>
        <p><button onclick="send_command('OFF')" class="button redbutton">OFF</button></p>
        
        <input type="range" orient="vertical" id="all_slider" onchange="change_brightness()" min="0" max="65" />

        ## MICROPYTHON IMAGE ##
    </body>
</html>
    """
    return html.replace("## MICROPYTHON IMAGE ##",upy_img)
