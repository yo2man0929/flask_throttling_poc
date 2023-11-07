#!/bin/bash

check_command() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Pleae use brew to install $cmd"
    else 
        # Check for Linux and use apt-get
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "Please use apt-get to install $cmd"
        fi
    fi
    exit 1
    fi    
}
check_command docker    

# for the init use
docker stop flask-api-throttling && docker rm flask-api-throttling || true

# build a clean image for retest
docker build --no-cache -t flask-api-throttling .

docker run --name flask-api-throttling -d -p 5001:5001 flask-api-throttling

# Wait for the server to start
sleep 5


function burst_requests {
    local user=$1
    local pass=$2
    local responses=()

    # Send 15 requests almost at the same time and store the status codes in an array
    responses=$(seq 15 | xargs -n1 -P15 -I{} curl -su $user:$pass http://127.0.0.1:5001 -o /dev/null -w "%{http_code}\n" -s)

    # Output the status codes
    #echo "$responses"

    # Count and print each status code
    echo "status code count: status code"
    echo "$responses" | sort | uniq -c
}

# Test throttling for user1
echo "Testing user1"
burst_requests user1 password1

# Wait for a second to respect the rate limit
sleep 1

# Test throttling for user2
echo "Testing user2"
burst_requests user2 password2

# Test throttling for user3
echo "Testing user3"
burst_requests user3 password3
