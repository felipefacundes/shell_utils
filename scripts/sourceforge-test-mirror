#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to test the speed of various SourceForge mirrors to determine which one is the fastest for downloading 
a specific file. Its strengths and capabilities include:

1. Mirror List: The script contains a comprehensive list of SourceForge mirrors for testing.
2. Speed Testing: It implements a function that measures the response time of each mirror using the 'curl' command.
3. Concurrent Execution: It performs speed tests in parallel, optimizing the overall execution time.
4. Ordered Results: It collects and sorts the results to quickly identify the fastest mirror.
5. Variable Export: The fastest mirror is exported as an environment variable, making it easy to use in other scripts or commands.

Overall, the script serves as a useful tool for users looking to optimize downloads from SourceForge, ensuring a more efficient experience.
DOCUMENTATION

# List of SourceForge mirrors to test
# https://sourceforge.net/p/forge/documentation/Mirrors/
MIRRORS=(
    "https://astuteinternet.dl.sourceforge.net"
    "https://cfhcable.dl.sourceforge.net"
    "https://cytranet.dl.sourceforge.net"
    "https://datapacket.dl.sourceforge.net"
    "https://excellmedia.dl.sourceforge.net"
    "https://freefr.dl.sourceforge.net"
    "https://gigenet.dl.sourceforge.net"
    "https://gox.dl.sourceforge.net"
    "https://iweb.dl.sourceforge.net"
    "https://jaist.dl.sourceforge.net"
    "https://kent.dl.sourceforge.net"
    "https://downloads.sourceforge.net"
    "https://nchc.dl.sourceforge.net"
    "https://master.dl.sourceforge.net"
    "https://razaoinfo.dl.sourceforge.net"
    "https://ufpr.dl.sourceforge.net"
    "https://sinalbr.dl.sourceforge.net"
    "https://sonik.dl.sourceforge.net"
    "https://udomain.dl.sourceforge.net"
    "https://yer.dl.sourceforge.net"
    "https://netix.dl.sourceforge.net"
    "https://netcologne.dl.sourceforge.net"
    "https://tenet.dl.sourceforge.net"
    )

# Function to test the speed of a mirror
test_mirror() {
    local mirror=$1
    local start=$(date +%s.%N)
    timeout 2 curl -s "$mirror/project/keepass/KeePass%202.x/2.48.1/KeePass-2.48.1.zip" -o /dev/null
    local end=$(date +%s.%N)
    local runtime=$(echo "$end - $start" | bc)
    echo "$mirror $runtime"
}

# Simultaneously test all mirrors
results=()
i=0
echo -e "List of mirrors:\n"
for mirror in "${MIRRORS[@]}"; do
    result=$(test_mirror "$mirror" &)
    ((i+=1))
    echo "$i - $result" | sed 's|\s\.\([0-9]\)| 0.\1|g'
    results+=("$result")
done

# Wait for all tests to finish
wait
echo -e "\nResult:\n"

# Choose the fastest mirror
fastest_mirror=$(printf "%s\n" "${results[@]}" | sed 's|\s\.\([0-9]\)| 0.\1|g' | sort -k2 -n | head -n1 | cut -d' ' -f1)

# sed 's|\s\.\([0-9]\)| 0.\1|g'  # when using the regular expression, you must use "s" instead of "^" to indicate that the 
# pattern to be replaced can appear anywhere on the line, not just at the beginning.
# Unlike echo .43 | sed 's|^\.\([0-9]\)|0.\1|g' which only changes matches starting with "." 

# sort -k2 -n  # is used to order the data numerically based on the second field (or column). In the example you shared, 
# the command echo -e "line 2\nline 3\nline 1" generates a list of strings with three lines, each starting with the word 
# “line” followed by a number.

# Export the mirror variable
export mirror=$fastest_mirror

echo "The fastest mirror is: $mirror"
