# Url-Checker-TrafficGen
URL Traffic Generator as a service.  Linux Ubuntu

######################################################################################################
This script installs a URL Checker Service on your system.

The service periodically checks the availability of various URLs.

It then provides feedback about their status and classification.

The user will be asked on which interface they want to run this service.

They user will be also asked how often to run this service in seconds.
######################################################################################################

1. Step 1: From your linux Ubuntu/Centos do a "git clone https://github.com/stevevoto/Url-Checker-TrafficGen.git"
2. Step 2: cd Url-Checker-TrafficGen
3. Step 3: chmod +x URL-CHECKER-V1.sh
4. Step 4: run ./URL-CHECKER-V1.sh
5. Step 5: select the interface you want to use to run your test service on
6. Step 6: enter the interval value (seconds) you want to run your tests
7. Step 7: Hit enter and you should be able to check for traffic on that interface tcpdump -i <interface name>
8. Step 8: Check to validate service is active "systemctl status url-checker"
