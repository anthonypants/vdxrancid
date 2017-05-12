# vdxrancid
forked from buraglio/vdxrancid, thanks to nick@buraglio.com

This code doesn't seem to work on my VDX switches, despite it accurately pulling the running-config, and produces the following error:
`loadtype: loading vdxrancid failed: vdxrancid.pm did not return a true value at /usr/share/perl5/vendor_perl/rancid/rancid.pm line 228.`

It's possible that this script is working in RANCID 2.3.6, but it doesn't seem to be working on RANCID 3.2, which I'm running.

There's also a ton of crap in this script related to Cisco IOS appliances, and I'd like to remove everything that isn't needed. This script doesn't need to be 68KB!

I'm not worried about backwards compatibility; if you're on an earlier version of RANCID, it's possible that the earlier version of this script will work for you. I also only have a pair of BR-VDX6740T switches, so this script will lean heavily on that specific platform, and while I'm not able to guarantee that this switch will apply to different hardware, I'm hopeful that NOS will remain consistent.
