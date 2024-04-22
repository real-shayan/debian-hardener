# Debian Hardener (BETA)

This Script will automatically secure Debian 12 (Bookworm)   
Note: This is currently in Work-in-Stage, Only Basic things can be apply. 

```bash
 ./main.sh --help
Welcome to Debian Hardener. With this script, you can secure your debian destribution.

Usage:
    -b | --basic         - Secure the Basic things
    -a | --advanced      - Secure the higher level
    -r | --rollback      - Rollback Previous Changes
    -h | --help          - Show Available Options
    -v | --version       - Show Version Information
```

Installation:

1. Clone This Repo:

```
$ git clone https://github.com/real-shayan/irancell-hardener
```

2. Run the script:

```
$ ./main.sh
```

3. After doing changes, Restart the openssh service: 

```
# systemctl restart sshd
```

That's it!


