# Url-Checker-TrafficGen
URL Traffic Generator as a service.  Linux Ubuntu/Centos
What does this do?
#######################################################################

- This script installs a URL Checker Service on your system.
- The service periodically checks the availability of various URLs.
- It then provides feedback about their status and classification.
- The user will be asked on which interface they want to run this service.
- They user will be also asked how often to run this service in seconds.
- You can also run it indpendently as root /usr/bin/url-checker.sh

How do I install Url-Checker
#######################################################################

1. Login to your linux system as root
2. From your linux Ubuntu/Centos system do a "git clone https://github.com/stevevoto/Url-Checker-TrafficGen.git"
3. cd Url-Checker-TrafficGen
4. chmod +x URL-CHECKER-V1.sh
5. run ./URL-CHECKER-V1.sh
6. select the interface you want to use to run your test service on
7. enter the interval value (seconds) you want to run your tests
8. Hit enter and you should be able to check for traffic on that interface tcpdump -i <interface name>
9. Check to validate service is active "systemctl status url-checker"
