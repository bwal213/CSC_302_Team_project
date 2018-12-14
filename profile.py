
"""An experimental profile to allow the usage of features and software from SEED Labs on CloudLab, specifically the web attacks for CSRF.

Instructions:
Wait for the profile instance to start, then obtain the address/URL from the ssh command in "List View" below.
(Only copy from the command on the line with the ID of "node".)

This can be done by highlighting from outside the dark box at the end of the command towards the front, up till the "@" symbol before your username/ID.

Paste this address into your URL bar and wait for the setup to finish. Once Apache is configured, you will see the lab directories here.

To access the jupyter server add ":8888" to the end of that same URL in a second tab or window. This access port 8888 where jupyter is running.

The jupyter server may take a while to load, as it is one of the last things that is done. 

Following it being available, a few more things will still be happening in the background, but you can click the "New" tab on the top right of the page and select terminal for an easy access to the command line.

Once fully set up you should be able to go back to the main web page (the main URL), and navigate to the directory/web page for the lab you wish to work on. Some are a few layers down.

DO NOT INSTATIATE AS YOU ARE WALKING INTO CLASS, BE SURE TO PLAN AHEAD!
This whole process may take upwards of a half hour (15-30 minutes during testing) or even longer if things are running slow or instantiation fails.

Enjoy learning as we have, but in a much more resource freindly environment. 
Have a great semester!
"""

import geni.portal as portal
import geni.rspec.pg as rspec

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()
# Create a XenVM
node = request.XenVM("node")
node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD"
node.routable_control_ip = "true"

node.addService(rspec.Execute(shell="/bin/sh",
                              command="sudo bash /local/repository/setup_files/setup.sh"))

portal.context.printRequestRSpec()
