#!/usr/bin/env python
import os
import sys
from usb.core import find as finddev
id = ""
vendor = ""
try:
        if len(sys.argv) == 3:
                vendor = sys.argv[1]
		id = sys.argv[2]
                
        elif len(sys.argv) == 2:
                args = sys.argv[1]
                args.replace(":", " ")
                vendor = args.split()[0]
		id = args.split()[1]
                
	dev = finddev(idVendor=int("0x"+ vendor, 16), idProduct=int("0x" + id, 16))
	dev.reset()
        print("Should have reset " + vendor+ ":" + id)

except Exception, msg:
    print "failed to reset device:", msg3
    
    



