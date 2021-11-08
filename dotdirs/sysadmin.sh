

# https://twitter.com/liamosaur/status/506975850596536320
alias fuck='sudo $(history -p \!\!)'
# But better one here
# https://github.com/nvbn/thefuck



rtfm() { $@ --help 2> /dev/null || man $@ 2> /dev/null || open "http://www.google.com/search?q=$@"; } 
# This handy little function tries command --help, 
# then man command, if that doesn't bring anything back. 
# Finally, it tries a google search for the command as a fallback. Fantastic.


# Just print the lines in a config file that actually do stuff:
alias nocomment='egrep -v "^\s*(#|$)"'


alias topo='top -n 1 -b | less'


# To display the total used and free memory of the system:
alias mem="free -h"
# To display the CPU architecture, number of CPUs, threads, etc. of the system:
alias cpu="lscpu"
# To display the total disk size of the system:
alias disk="df -h"


# View only mounted drives
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
