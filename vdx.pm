package vdx;
##
## rancid 3.2
## Copyright (c) 1997-2015 by Terrapin Communications, Inc.
## All rights reserved.
##
## This code is derived from software contributed to and maintained by
## Terrapin Communications, Inc. by Henry Kilmer, John Heasley, Andrew Partan,
## Pete Whiting, Austin Schutz, and Andrew Fort.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. All advertising materials mentioning features or use of this software
##    must display the following acknowledgement:
##        This product includes software developed by Terrapin Communications,
##        Inc. and its contributors for RANCID.
## 4. Neither the name of Terrapin Communications, Inc. nor the names of its
##    contributors may be used to endorse or promote products derived from
##    this software without specific prior written permission.
## 5. It is requested that non-binding fixes and modifications be contributed
##    back to Terrapin Communications, Inc.
##
## THIS SOFTWARE IS PROVIDED BY Terrapin Communications, INC. AND CONTRIBUTORS
## ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
## TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COMPANY OR CONTRIBUTORS
## BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
#
#  RANCID - Really Awesome New Cisco confIg Differ
#
#  vdx.pm - RANCID script for use with Brocade VDX/NOS appliances
#  github.com/anthonypants/vdxrancid

use 5.010;
use strict 'vars';
use warnings;
no warnings 'uninitialized';
require(Exporter);
our @ISA = qw(Exporter);

use rancid 3.2;

@ISA = qw(Exporter rancid main);
#XXX @Exporter::EXPORT = qw($VERSION @commandtable %commands @commands);

# load-time initialization
sub import {
    0;
}

# post-open(collection file) initialization
sub init {
    # add content lines and separators
    ProcessHistory("","","","!RANCID-CONTENT-TYPE: $devtype\n!\n");

    0;
}

# main loop of input of device output
sub inloop {
    my($INPUT, $OUTPUT) = @_;
    my($cmd, $rval);

	TOP: while(<$INPUT>) {
		tr/\015//d;
		if (/\#(exit|quit)$/) {
			# It doesn't look like this gets called
			last;
		}
		if (/Connection to $host closed\.$/) {
			# Without this I keep getting "End of run not found" errors
			# Possibly because I connect as root and don't have to exit
			# twice -- once to get out of enable, and once to leave ssh
			print STDERR ("Connection to $host closed.\n") if ($debug);
			# I don't know why setting both of these works, but it does
			# If only one is set, the script will fail. It is a mystery
			$found_end = 1;
			$clean_run = 1;
			last;
		}
		if (/^Error:/) {
			print STDOUT ("$host flogin error: $_");
			print STDERR ("$host flogin error: $_") if ($debug);
			$clean_run = 0;
			last;
		}
		while (/[>#]\s*($cmds_regexp)\s*$/) {
			$cmd = $1;
			if (!defined($prompt)) {
				$prompt = ($_ =~ /^([^#]+#)/)[0];
				$prompt =~ s/([][}{)(\\])/\\$1/g;
				print STDERR ("PROMPT MATCH: $prompt\n") if ($debug);
			}
			print STDERR ("HIT COMMAND:$_") if ($debug);
			if (! defined($commands{$cmd})) {
				print STDERR "$host: found unexpected command - \"$cmd\"\n";
				$clean_run = 0;
				last TOP;
			}
			$rval = &{$commands{$cmd}}($INPUT, $OUTPUT, $cmd);
			delete($commands{$cmd});
			if ($rval == -1) {
				$clean_run = 0;
			last TOP;
			}
		}
    }
}

# This routine parses "show version"
sub ShowVersion {
    my($INPUT, $OUTPUT) = @_;
    my($slot);

    print STDERR "    In ShowVersion: $_" if ($debug);

    while (<$INPUT>) {
    	tr/\015//d;
	    next if /^\s*$/;
    	last if (/$prompt/);

    	ProcessHistory("VERSION","","","!$_");
    }
    ProcessHistory("VERSION","","","!\n");
    return(0);
}

# This routine parses "show chassis"
sub ShowChassis {
    my($INPUT, $OUTPUT) = @_;
    my($skip) = 0;

    print STDERR "    In ShowChassis: $_" if ($debug);

    while (<$INPUT>) {
		tr/\015//d;
		tr/\015//d;
		last if (/^$prompt/);

    	ProcessHistory("CHASSIS","","","! $_");
    }
    ProcessHistory("CHASSIS","","","!\n");

    return(0);
}

# This routine parses "show running-config"
sub ShowConfig {
    my($INPUT, $OUTPUT) = @_;
    my($skip) = 0;

    print STDERR "    In ShowRun: $_" if ($debug);

    while (<$INPUT>) {
        tr/\015//d;
        last if (/^$prompt/);

        ProcessHistory("CONFIG","","","! $_");
    }
    ProcessHistory("CONFIG","","","!\n");

    return(0);
}
1;
