#!/bin/bash
###### Linux Ubuntu URL-Checker generates web traffic for users as a service ~Steve V #######
echo "
            _         ___ _               _             
  /\ /\ _ __| |       / __\ |__   ___  ___| | _____ _ __ 
 / / \ \ '__| |_____ / /  | '_ \ / _ \/ __| |/ / _ \ '__|
 \ \_/ / |  | |_____/ /___| | | |  __/ (__|   <  __/ |   
  \___/|_|  |_|     \____/|_| |_|\___|\___|_|\_\___|_|   
                                                        
"
# Display information about the script
echo "###########################################################################"
echo "This script installs a URL Checker Service on your system."
echo "The service periodically checks the availability of various URLs."
echo "It then provides feedback about their status and classification."
echo "The user will be asked on which interface they want to run this service."
echo "They user will be also asked how often to run this service in seconds."
echo "###########################################################################"
echo ""
echo ""

# List available network interfaces
echo "Available network interfaces:"
interfaces=($(ip -o link show | awk -F': ' '{print $2}'))
for i in "${!interfaces[@]}"; do
    echo "$((i+1)). ${interfaces[i]}"
done

# Ask the user to select the network interface
while true; do
    read -p "Please enter the number corresponding to the network interface you want to use for URL checks: " interface_num
    if [[ $interface_num =~ ^[0-9]+$ && $interface_num -ge 1 && $interface_num -le ${#interfaces[@]} ]]; then
        selected_interface=${interfaces[interface_num-1]}
        echo "Selected interface: $selected_interface"
        break
    else
        echo "Invalid selection. Please enter a valid number corresponding to the network interface."
    fi
done

# Ask the user to confirm the selected interface
while true; do
    read -p "Is '$selected_interface' the correct interface you want to use for URL checks? (y/n): " confirm_interface
    case $confirm_interface in
        [Yy]* ) break;;
        [Nn]* ) echo "Interface selection aborted."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Ask the user for the interval between checks
while true; do
    read -p "Please enter the interval (in seconds) between URL checks (minimum 300 seconds 5 min recommended): " interval
    if [[ $interval =~ ^[1-9][0-9]*$ && $interval -ge 15 ]]; then
        echo "Interval set to $interval seconds."
        break
    else
        echo "Invalid input. Please enter a valid interval (minimum 15 seconds)."
    fi
done

# Stop the service if it's running
systemctl stop url-checker.service

# Remove existing script and service files
rm -f /usr/bin/url-checker.sh
rm -f /etc/systemd/system/url-checker.service

# Reload systemd daemon
systemctl daemon-reload

# Create Service File
cat >/etc/systemd/system/url-checker.service <<'EOF'
[Unit]
Description=URL Checker Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/url-checker.sh
Restart=always
RestartSec=20s
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Set permissions for Service File
chmod 644 /etc/systemd/system/url-checker.service

# Create Shell Script
cat >/usr/bin/url-checker.sh <<EOF
#!/bin/bash

# Default interface variable
INTERFACE="$selected_interface"

# Function to run URL checks and display progress gauge
runChecks() {
    local interval=\$1

    # Define the list of URLs to check
    websites=(        #"http://8kun.top" "\033[33mPreviously known as 8chan, controversial for hosting extremist content."
        "http://forums.somethingawful.com" "\033[33mCan contain mature content."
        #"http://topix.com" "\033[33mContains user-generated news discussions which may vary in safety."
        #"http://www.reddit.com/r/AskReddit" "\033[33mGenerally safe but content can vary based on user submissions."
        #"http://www.reddit.com" "\033[33mSocial Media and Community Forum"
        "http://www.quora.com" "\033[33mQuestion-and-answer website, generally safe."
        #"http://www.wikipedia.org" "\033[33mInformation and Reference"
        #"http://www.weather.com" "\033[33mInformation and Weather"
        #"http://www.cnn.com" "\033[33mNews and Current Affairs"
        #"http://www.nytimes.com" "\033[33mNews and Current Affairs"
        #"http://www.nationalgeographic.com" "\033[33mInformation and Exploration"
        #"http://www.netflix.com" "\033[33mEntertainment and Streaming"
        #"http://www.spotify.com" "\033[33mEntertainment and Music Streaming"
        #"http://www.hulu.com" "\033[33mEntertainment and Streaming"
        #"http://www.apple.com" "\033[33mTechnology and Consumer Electronics"
        "http://microsoft.com/en-us/microsoft-365/outlook/" "\033[33mTechnology and Software"
        "http://www.amazon.com" "\033[33mE-commerce and Online Shopping"
        "http://www.ebay.com" "\033[33mE-commerce and Online Shopping"
        #"http://www.target.com" "\033[33mE-commerce and Retail"
        #"http://www.walmart.com" "\033[33mE-commerce and Retail"
    	"http://www.yahoo.com" "\033[33mSearch Engine and Information"
        #"http://www.bing.com" "\033[33mSearch Engine and Information"
        #"http://www.duckduckgo.com" "\033[33mSearch Engine and Information"
        "http://www.yelp.com" "\033[33mTravel and Reviews"
        "http://www.zillow.com" "\033[33mReal Estate and Property"
        "http://www.realtor.com" "\033[33mReal Estate and Property"
        "http://www.coursera.org" "\033[33mEducation and Online Learning"
        "http://www.bloomberg.com" "\033[33mBusiness and Finance News"
        #"http://www.forbes.com" "\033[33mBusiness and Finance News"
        #"http://www.businessinsider.com" "\033[33mBusiness and Finance News"
        #"http://www.techcrunch.com" "\033[33mTechnology News and Analysis"
        #"http://www.engadget.com" "\033[33mTechnology News and Gadgets"
        #"http://www.huffpost.com" "\033[33mNews and Opinion"
        #"http://www.theatlantic.com" "\033[33mNews and Opinion"
        #"http://www.npr.org" "\033[33mNews and Radio"
        #"http://www.deviantart.com" "\033[33mArt and Creative Community"
        #"http://www.behance.net" "\033[33mArt and Design Portfolio"
        #"http://www.instructables.com" "\033[33mDIY and Instructional Content"
        #"http://www.lifehacker.com" "\033[33mLife Hacks and Productivity"
        #"http://www.nationalreview.com" "\033[33mNews and Opinion"
        #"http://www.politico.com" "\033[33mPolitical News and Analysis"
        #"http://www.britannica.com" "\033[33mEncyclopedic Reference"
        #"http://www.snopes.com" "\033[33mFact-Checking and Debunking"
        #"http://www.space.com" "\033[33mSpace Exploration and Science"
        "http://www.nasa.gov" "\033[33mSpace Exploration and Science"
        #"http://www.healthline.com" "\033[33mHealth Information and Wellness"
        #"http://www.mayoclinic.org" "\033[33mMedical Information and Research"
        #"http://www.webmd.com" "\033[33mMedical Information and Health Advice"
        "http://www.everydayhealth.com" "\033[33mHealth and Lifestyle Tips"
        "http://www.menshealth.com" "\033[33mMen's Health and Lifestyle"
        "http://www.womenshealthmag.com" "\033[33mWomen's Health and Lifestyle"
        #"http://www.self.com" "\033[33mHealth and Fitness Magazine"
        #"http://www.shape.com" "\033[33mHealth and Fitness Magazine"
        #"http://www.runnersworld.com" "\033[33mRunning and Fitness Magazine"
        #"http://www.cookinglight.com" "\033[33mHealthy Cooking and Recipes"
        #"http://www.foodnetwork.com"
        "http://www.google.com" "\033[33mSearch Engine and Information"
        #"http://www.foodnetwork.com" "\033[33mFood and Cooking Channel"
        #"http://www.allrecipes.com" "\033[33mRecipes and Cooking Community"
        #"http://www.epicurious.com" "\033[33mRecipes and Culinary Magazine"
        #"http://www.thespruceeats.com" "\033[33mRecipes and Cooking Tips"
        #"http://www.architecturaldigest.com" "\033[33mArchitecture and Design Magazine"
        #"http://www.housebeautiful.com" "\033[33mHome and Interior Design"
        "http://www.countryliving.com" "\033[33mCountry Lifestyle and Decor"
        "http://www.travelandleisure.com" "\033[33mTravel and Leisure Magazine"
        "http://www.lonelyplanet.com" "\033[33mTravel Guides and Tips"
        "http://www.booking.com" "\033[33mTravel Booking and Accommodation"
        "http://www.expedia.com" "\033[33mTravel Booking and Accommodation"
        #"http://www.airbnb.com" "\033[33mAccommodation Rental and Travel"
        #"http://www.trip.com" "\033[33mTravel Booking and Information"
        #"http://www.hotels.com" "\033[33mHotel Booking and Accommodation"
        #"http://www.kayak.com" "\033[33mTravel Booking and Comparison"
        #"http://www.skyscanner.com" "\033[33mFlight and Travel Comparison"
        "http://www.vrbo.com" "\033[33mVacation Rentals and Accommodation"
        "http://www.homeaway.com" "\033[33mVacation Rentals and Accommodation"
        "http://www.rei.com" "\033[33mOutdoor Gear and Equipment"
        #"http://www.backpacker.com" "\033[33mBackpacking and Outdoor Magazine"
        #"http://www.teachertube.com" "\033[33mEducational Videos for Teachers"
        #"http://www.khanacademy.org" "\033[33mEducational Videos and Courses"
        #"http://www.udemy.com" "\033[33mOnline Courses and Learning Platform"
        #"http://www.skillshare.com" "\033[33mCreative Classes and Workshops"
        #"http://www.codecademy.com" "\033[33mCoding and Programming Courses"
        #"http://www.freecodecamp.org" "\033[33mCoding Bootcamp and Resources"
        "http://www.womenshealthmag.com/fitness/" "\033[33mWomen's Health and Fitness\033[0m"
        "http://www.self.com/workouts" "\033[33mSelf Fitness\033[0m"
        "http://www.runnersworld.com/training/" "\033[33mRunner's World Training\033[0m"
        "http://www.muscleandfitness.com/workouts/" "\033[33mMuscle & Fitness Workouts\033[0m"
        "http://www.healthline.com/health/fitness-exercise" "\033[33mHealthline Fitness and Exercise\033[0m"
        "http://www.acefitness.org/" "\033[33mACE Fitness\033[0m"
        "https://www.bet365.com" "\033[33mBet365 \033[0m\033[33mGambling\033[0m"
        "https://www.williamhill.com" "\033[33mWilliam Hill \033[0m\033[33mGambling\033[0m" 
        "https://www.paddypower.com" "\033[33mPaddy Power \033[0m\033[33mGambling\033[0m"
        "https://www.betfair.com" "\033[33mBetfair \033[0m\033[33mGambling\033[0m"
         "https://www.888sport.com" "\033[33m888sport \033[0m\033[33mGambling\033[0m"
         "https://www.betway.com" "\033[33mBetway \033[0m\033[33mGambling\033[0m"
         "https://www.ladbrokes.com" "\033[33mLadbrokes \033[0m\033[33mGambling\033[0m"
         "https://www.skybet.com" "\033[33mSky Bet \033[0m\033[33mGambling\033[0m"
         "https://www.coral.co.uk" "\033[33mCoral \033[0m\033[33mGambling\033[0m"
         "https://www.unibet.com" "\033[33mUnibet \033[0m\033[33mGambling\033[0m"
        #"http://www.shape.com" "\033[33mHealth and Fitness Magazine"
         "https://www.imdb.com" "\033[33mIMDb \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.rottentomatoes.com" "\033[33mRotten Tomatoes \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.metacritic.com" "\033[33mMetacritic \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.youtube.com" "\033[33mYouTube \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.netflix.com" "\033[33mNetflix \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.hulu.com" "\033[33mHulu \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.twitch.tv" "\033[33mTwitch \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.deviantart.com" "\033[33mDeviantArt \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.spotify.com" "\033[33mSpotify \033[0m\033[33mArts and Entertainment\033[0m"
         "https://www.last.fm" "\033[33mLast.fm \033[0m\033[33mArts and Entertainment\033[0m"
    )

    # Total number of URLs
    local total=\${#websites[@]}

    while true; do
        for (( i=0; i<\${total}; i+=2 )); do
            # Extract URL and description
            url=\${websites[i]}
            desc=\${websites[i+1]}
            # Check if the URL is owned by google.com
            if [[ \$url != *"google.com"* ]]; then
                # Run curl command with timeout and specify the interface
                (timeout 3 curl -Is --interface "\$INTERFACE" "\$url" > /dev/null 2>&1 && echo "SUCCESS: \$url - \$desc" || echo "FAILURE: \$url - \$desc") &
            fi
        done

        # Sleep for the specified interval
        sleep "\$interval"
    done
}

# Main function
main() {
    local interval=\$1

    # Run URL checks with the specified interval
    while true; do
        runChecks "\$interval"
        # Sleep for the specified interval before restarting checks
        sleep "\$interval"
    done
}

# Call the main function
main "$interval"
EOF

# Set permissions for Shell Script
chmod +x /usr/bin/url-checker.sh

# Reload systemd daemon
systemctl daemon-reload

# Start and enable the service
systemctl start url-checker.service
systemctl enable url-checker.service

# Check the status of the service
systemctl status url-checker.service
