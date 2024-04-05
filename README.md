# Url-Checker-TrafficGen
URL Traffic Generator as a service.  Linux Ubuntu/Centos
What does this do?
#######################################################################
  1. This script installs a URL Checker Service on your system.
  2. The service periodically checks the availability of various URLs.
  3. It then provides feedback about their status and classification.
  4. The user will be asked on which interface they want to run this service.
  5. They user will be also asked how often to run this service in seconds.
#######################################################################

   A. Step 1: From your linux Ubuntu/Centos do a "git clone https://github.com/stevevoto/Url-Checker-TrafficGen.git"
   B. Step 2: cd Url-Checker-TrafficGen
   C. Step 3: chmod +x URL-CHECKER-V1.sh
   D. Step 4: run ./URL-CHECKER-V1.sh
   E. Step 5: select the interface you want to use to run your test service on
   F. Step 6: enter the interval value (seconds) you want to run your tests
   G. Step 7: Hit enter and you should be able to check for traffic on that interface tcpdump -i <interface name>
   H. Step 8: Check to validate service is active "systemctl status url-checker"
