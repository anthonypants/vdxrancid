# What is vdxrancid?
This project was initially forked from buraglio/vdxrancid, thanks to nick@buraglio.com, but I didn't end up using his scripts.

That code doesn't seem to work on my VDX switches, despite it accurately pulling the running-config, and produces the following error:
`loadtype: loading vdxrancid failed: vdxrancid.pm did not return a true value at /usr/share/perl5/vendor_perl/rancid/rancid.pm line 228.`

It's possible that this script is working in RANCID 2.3.6, but it doesn't seem to be working on RANCID 3.2. Or, I fucked up somewhere.

(There's also a ton of crap in those scripts related to Cisco IOS appliances, and I wanted to remove everything that isn't needed. This script doesn't need to be 68KB!)

So, I modified clogin and foundry.pm from the stock RANCID package (version 3.2, available in the CentOS 7 EPEL repo) to suit my needs.

# How do I set up vdxrancid?
First, download the files and move them into the RANCID folders. If you're using CentOS 7 like me, you can enter the following commands to install the scripts:
```
wget https://github.com/anthonypants/vdxrancid/raw/master/vdx.pm && sudo cp vdx.pm /usr/share/perl5/vendor_perl/rancid/vdx.pm && sudo chcon -R -u system_u /usr/share/perl5/vendor_perl/rancid/vdx.pm
wget https://github.com/anthonypants/vdxrancid/raw/master/vdxlogin && sudo cp vdxlogin /usr/libexec/rancid/vdxlogin && sudo chcon -R -u system_u /usr/libexec/rancid/vdxlogin
```

Second, edit your `/etc/rancid/rancid.types.conf` file to point to these scripts. I have the following block in mine:
```
brocade-vdx;script;rancid -t vdx
brocade-vdx;login;vdxlogin
brocade-vdx;module;vdx
brocade-vdx;inloop;vdx::inloop
brocade-vdx;command;vdx::ShowVersion;show version
brocade-vdx;command;vdx::ShowChassis;show chassis
brocade-vdx;command;vdx::ShowConfig;show running-config
```

Third, edit your 'router.db' file to include the 'brocade-vdx' type. It should look something like this, where '10.0.0.8' belongs to your VDX appliance:
```
10.0.0.8;brocade-vdx;up
```

That should be it. To test, you can try the following as the rancid user:
```
$ export PATH=$PATH:/usr/libexec/rancid && export NOPIPE=YES
$ rancid -d -t brocade-vdx 10.0.0.8 2>&1
```


# Caveats
I'm not worried about backwards compatibility; if you're on an earlier version of RANCID, it's possible that the earlier version of this script will work for you. I also only have a pair of BR-VDX6740T switches, so this script will lean heavily on that specific platform, and while I'm not able to guarantee that this switch will apply to different hardware, I'm hopeful that NOS will remain consistent.

Feel free to poke holes in the mess I made with these scripts, 
