#! /usr/bin/perl -w

# Copyright 2015 LouieDogg LLC 
my $author = "admin\@louiedogg.com";
# ####################################################################
# Version: 0.01
#
# Description: This installation file was written to help users 
# install and use viewtouch.  This script calls initial configuration 
# variable for the scipt than defines arrays, hashes, and few scripts 
# ran by cron jobs if wanted, than subroutines and finally the main 
# loop.  
# The supported version for this script is Debian Wheezy and Jessie, 
# you may be able to jun this on versions of Ubuntu if you run the 
# command "sudo su" from a terminal.  This will take away the need 
# to use the sudo prefix in the terminal setting, currently this
# is not supported in this script version.
#
#
# Directions:  Save this script to a desired directory, cd to that 
# directory using a terminal and run "./install_viewtouch.pl" this 
# will run this script and install the ViewTouch client application
# to the directory defined below.
# 
# To modify the packages that are installed you can modify the 
# @package array.
#
# This script takes arguments when called
#
#	--help					Will display this menu
#	--install-developer		This installs viewtouch with source code
#	--install-client	   	Install client application
#	--update-louiedogg		Update source with louiedogg code
#	--update-viewtouch		Update source viewtouch-master
#	--update-jack			Update source with Jack's code
#
#
# 
# The latest version of this file can be found at
# https://github.com/louiedogg/develop_viewtouch
# 
#
#
# http://www.kossboss.com/linux---debian---create
# This is for the adding desktop icons
# apt-get install gnome-panel
# gnome-desktop-item-edit /root/Desktop/ --create-new
#
# need to add all icons 
#
# License:GPLv2
#
# ####################################################################


#######################################################################
# Modules
###########################

#strict
use strict;
#warnings

use warnings;

# file fetch for fetching database files 
use File::Fetch;

# Louiedogg
use louiedogg;



#######################################################################
# Configuration Variables
###########################

#Viewtouch User Name
my $username = "viewtouch";

#Create Directory for support files
my $support_dir = "home/viewtouch/Desktop/support_files";

# Viewtouch Directory
my $viewtouch_dir = "/usr/viewtouch";

# Disable Screen Resume Lock Command - Not used yet
my $scrn_resume = "gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'";

# Name of Ftp Script location file name
my $viewtouch_ftp_backup = "/usr/viewtouch/scripts/ftp_backup.pl";

# Cron file
my $crontab = "/usr/viewtouch/cron/viewtouch_cron";

# Auto login file
my $auto_login_file = "/etc/lightdm/lightdm.conf";

# Sudo User File
my $sudo_file = "/etc/sudoers";

# Github Source Viewtouch
my $source_viewtouch = "https://github.com/viewtouch.git";

# Github Source Jack
my $source_jack = "https://github.com/jackdigitalinsight/viewtouch.git";

# Github Source Lou
my $source_louiedogg = "https://github.com/louiedogg/viewtouch.git";

#FTP Host for non github files
my $ftp_host = "http://revenuerivertechnologies.com/$username/";

# Database File - This needs to be a demo database
my $database_file = "dat.tar";

# Fonts File
my $fonts_file = "fonts.tar";

# Set Fonts command
my $set_fonts = "xset +fp /usr/viewtouch/fonts";

# Ffp Backup Script stored as a string
my $ftp_script = "/scripts/cloud_backup.pl";





#######################################################################
# Arrays
###########################

#Supported OS
my @supported = ("Debian Wheezy", 
					"Debian Jessie",

					"Ubuntu 12.04",
					"Ubuntu 14.04");
	
# Viewtouch Dependency array
# Note: libxm4 is only available for sid/jessie we will use 
# This is for debian 7.7 lesstif2-dev
# We will use libmotif-dev instead for wheezy
my @packages	 =  qw(g++
						cmake 
						cmake-curses-gui 
						build-essential 
						zlib1g-dev 
						libmotif-dev 
						libxt-dev 
						libxm4
						libxmu-dev 
						libxpm-dev 
						libxft-dev
						xwit
						geany 
						wput
						gddrescue
						gparted
						gnome-schedule	
						git 
						gnome-panel
						);
						
# Viewtouch Make Array
my @viewtouch_make_cmds = ("cmake .",
							"make",
							"make install"
							);


# Help menu array
my @help = (
			"--help			Will display this menu",
			"--install-developer	This installs viewtouch with source code",
			"--install-client 	Install client application",
			"--update-louiedogg 	Update developer with louiedogg code",
			"--update-viewtouch 	Update developer viewtouch-master",
			"--update-jack Update 	developer with Jack's code",
			);
							
#######################################################################
# Hashes
####################

# This has not yet been implemented
# Hash that stores all the cron strings to append to the bottom of the file
my %cron;

$cron{viewtouch_ftp_backup} = "30 4 * * * $viewtouch_ftp_backup;"; #Cron to backup viewtouch
$cron{weekly_reboot} = "15 5 * * 1 root /sbin/shutdown -r now;"; #Cron to reboot weekly
$cron{start_viewtouch} = "\@reboot /usr/viewtouch/bin/runonce;"; #Start Viewtouch on Startup

#Hash for Desktop Shortcuts - Not sure if I want to implement this in this version
my %desktop_shortcuts;

$desktop_shortcuts{viewtouch} = "viewtouch.desktop";
$desktop_shortcuts{restauratuer} = "restaurateur.desktop";
$desktop_shortcuts{supplies} = "supplies.desktop";
$desktop_shortcuts{support} = "support.desktop";


#######################################################################
# Subroutines
####################

#########################################
# Function to check for installation and 
sub install_packages()
{
	foreach my $package (@packages)
	{
		my $cmd = "find / -name $package -print";    
		my @output = `$cmd`;    
		chomp @output;
	
		print "Searching for $package please wait...\n";
		
		unless(@output)
		{
			system("apt-get --force-yes install $package");
		}
		else
		{
			print "$package is already installed\n";
		}
	}
	return 1;
}

#########################################							
# Make Viewtouch
sub make_viewtouch
{
	chdir("$viewtouch_dir");
	foreach my $m (@viewtouch_make_cmds)
	{
		system("$m");
	}
}

#########################################							
# Set Fonts
sub set_fonts
{
	if(-e "/bin/runonce")
	{
		system("$set_fonts") or print "Could not set fonts\n";
	}
}
#########################################
# Clone, Make, Copy Db, Install Viewtouch, and Set Fonts

sub install_viewtouch
{
		
	# Git Clone Command 
	my $clone_vt = "git clone $source_jack";#.$_[0];	
	my $make_go = 0;
	my $data = substr($database_file, 0, -4);
	my $fonts = substr($fonts_file, 0, -4);
	my $uc_database = "tar -xvf $database_file";
	my $uc_fonts = "tar -xvf $fonts_file";
	
	
	chdir ("/");
	
	if(!-e "/usr/viewtouch/")
	{		
		chdir ("/usr/");
		system("$clone_vt") or print "Error cloning viewtouch: $!\n"; # Clone the viewtouch stabe repository
		
	}

	#If the viewtouch directory does not exsist		
	if(-e "/usr/viewtouch/bin/runonce")
	{		
		print "Viewtouch is already installed\n";
	}
	
	elsif(-e "/usr/viewtouch/main/")
	{
			
		print "Viewtouch has been cloned\n";
		
		if(-e "/usr/viewtouch/dat")
		{	
			print "dat folder has been copied\n";
			$make_go++;
		}
		
		elsif(-e "/usr/viewtouch/$database_file")
		{
			chdir("$viewtouch_dir");
			die $! unless(system($uc_database));
			
			unlink("$database_file");
			
			$make_go++;
		}
		else
		{			
			chdir ("/usr/viewtouch/") or die $!;
			
			#Fetch database file
			my $ff = File::Fetch->new(uri => "$ftp_host"."$database_file");
			my $where = $ff->fetch( to => "$viewtouch_dir" );

			$ff->uri;
			$ff->scheme;
			$ff->host;
			$ff->path;
			$ff->file;	
			
			print "data.tar file has been copied\n";
			

			
			die $! unless(system("$uc_database"));
			
			
			if(-e "$data")
			{
				print "Dat File is alive and well.\n";
				$make_go++;
			}
			else
			{
				print "There was trouble with the dat file.\n";
			}
						
		}
		if(-e "/usr/viewtouch/fonts")
		{
			print "Fonts have been copied and installed\n";
			$make_go++;
		}
		elsif(-e "/usr/viewtouch/$fonts_file")
		{
			chdir("$viewtouch_dir");
			die $! unless(system("$uc_fonts"));
			
			unlink("$fonts_file");
			
			$make_go++;
		}
		else
		{		
			my $ff = File::Fetch->new(uri => "$ftp_host"."$fonts_file");
			my $where = $ff->fetch( to => "$viewtouch_dir" );

			$ff->uri;
			$ff->scheme;
			$ff->host;
			$ff->path;
			$ff->file;	
			
			print "data.tar file has been copied\n";
						

			
			die $! unless(system("$uc_fonts"));
		
			
			if(-e "$fonts")
			{
				print "Fonts File is alive and well.\n";
				$make_go++;
			}
			else
			{
				print "There was trouble with the Fonts file.\n";
			}
		}						
		if($make_go == 2) {
			
			if(make_viewtouch()) 
			{
				unless(set_fonts()) 
				{
					print "Could not set fonts";
				} 
				
			} 
			else
			{
				print "Could not make viewtouch."
			}	
					
		}
		else
		{
			print "$make_go\n";
			louiedogg::error(__FILE__, __LINE__, "There was a problem with \$make_go.");
		}
			
	}

}
#########################################
# Start Viewtouch
sub start_viewtouch()
{
	chdir"/";
	system("usr/viewtouch/bin/runonce");
}
#########################################
# Update Source Code
sub update_source
{

	if(-e "/usr/viewtouch/")
	{
		chdir "/";
			
		my $time = localtime(time);
		$time =~ tr/ /_/;
		$time =~ tr/:/_/;
		my $install_go = 0;
			
		if(-e "/usr/vt_source_backup")
		{
			$install_go++;
		
		}
		else
		{
			mkdir "/usr/vt_source_backup";
			$install_go++;
		}
		
		system("tar xcf /usr/vt_source_backup/viewtouch_$time.tar /usr/viewtouch") or die $!;			
		rmdir("usr/viewtouch") or die $!;
			
		unless(-e "usr/viewtouch")
		{
				install_viewtouch($_[0]);
		}	

	}
	else
	{
		print "ViewTouch does not exists, please install it."
	}
	

}

#########################################################
# Main 													#
#######			

# Still need to set cron to start viewtouch when user logins in
# for now the system will enable autologin set a cron to start
# Viewtouch on reboot than do a reboot.
# This still needs to be configured. 

my $installed = 0;
my $arg = $ARGV[0];
my $find_os = "$^O";
my @os = $find_os;
chomp (@os);

# Give the argument a value if it is empty.
if($arg)
{
	chomp($arg);
}
else
{
	$arg = 0;
}

if($os[0] eq "linux")
{
	my $linux_distro = "null";
	my $cmd = "cat /etc/os-release";
	my @linux_d = `$cmd`;
		
	chomp(@linux_d);

	foreach my $line (@linux_d)
	{	
		if ($line eq "PRETTY_NAME=\"Debian GNU/Linux 7 (wheezy)\"")
		{
			$linux_distro = "Debian Wheezy";
			print "You are using $linux_distro.\n";
		}
		elsif ($line eq "PRETTY_NAME=\"Debian GNU/Linux 8 (jessie)\"")
		{
			$linux_distro = "Debian Jessie";
			print "You are using $linux_distro.\n";
		}
		elsif ($line eq "NAME=\"UBUNTU\"")
		{
			$linux_distro = "Ubuntu";
			print "You are using $linux_distro.\n";
			system("sudo su") or die $!;
		}
	}
	
	unless($linux_distro eq "null")
	{		
		
		if($arg eq "--install-developer")
		{		
			if(install_packages()) { $installed++; } else { die $!; }
			
			if(louiedogg::add_user($username)) { $installed++; } else { print $!; }
						
			if(install_viewtouch($source_jack)) { $installed++; } else { die $!; }

			if(louiedogg::sudo_permission($username)) { $installed++; } else { die $!; }
		
			if(louiedogg::set_owner("$username", $viewtouch_dir)) { $installed++; } else { die $!; }
					
			if(louiedogg::append_cron($cron{start_viewtouch})) { $installed++; } else { die $!; }

			if($installed == 5)
			{
				print "The system is going to reboot.\n";
				print "Please login into the $username user when\n";
				print "The system comes back up\n";
				louiedogg::reboot("10");
			}
			else
			{
				print "$installed\n";
			}
						
		}
		elsif($arg eq "--install-client")
		{
			install_packages();
			
			unless(louiedogg::add_user($username))
			{
				louiedogg::error(__FILE__, __LINE__, "Could not add $username.");
			}
				
			unless(install_viewtouch($source_jack))
			{
				louiedogg::error(__FILE__, __LINE__, "Could not install viewtouch.");
			}
				
			unless(louiedogg::sudo_permissions($username))
			{
				louiedogg::error(__FILE__, __LINE__, "Could not set permissions.");
			}
			
			unless(louiedogg::set_owner("$username", $viewtouch_dir))
			{
				louiedogg::error(__FILE__, __LINE__, "Could not change ownership.");
			}
			
			unless(louiedogg::gnome_auto_login("viewtouch", "--enable"))
			{
				louiedogg::error(__FILE__, __LINE__, "Can not enable auto login.");
			}
			
			unless(louiedogg::append_cron($cron{$username, start_viewtouch}))
			{
				louiedogg::error(__FILE__, __LINE__, "Could append vt cron.") 
			}
			else
			{
				print "The system is going to reboot.\n";
				#louiedogg::reboot("10");			
			}

		}
		elsif($arg eq "--update-viewtouch")
		{
			update_source($source_viewtouch);
		}
		elsif($arg eq "--update-jack")
		{
			update_source($source_jack);
		}
		elsif($arg eq "--update-louiedogg")
		{
			update_source($source_louiedogg);
		}
		elsif($arg eq "--help")
		{
			print "\n";
			print "Please use the option that best fits your needs\n";
			while(my($key, $value) = each @help )
			{
				print "$value\n";
			}
			print "\n";
		}
		else
		{	
			print "You need to enter a valid argument.\n";
			print "Please select from the following options\n";
			while(my($key, $value) = each @help )
			{
				print "$value\n";
			}
		}		
	
	
	}
	else
	{

		print "This Distro is not yet supported.\n";
		print "Please use:";
		foreach my $distro (@supported)
		{
			print "$distro\n";
		}		
	}	
}
elsif(@os eq "MSWin32")
{

	print "you have a windows system";
}
else
{
	print "This system is not supported\n";
}

#########################################################
1
