#! /usr/bin/perl

use strict;
use warnings;
use louiedogg;
use File::Fetch;

#Viewtouch User Name
my $username = "viewtouch";

# Viewtouch Directory
my $viewtouch_dir = "/usr/viewtouch";

#FTP Host for non github files
my $ftp_host = "http://revenuerivertechnologies.com/$username/";

# Database File - This needs to be a demo database
my $database_file = "dat.tar";

# Fonts File
my $fonts_file = "fonts.tar";

# Set Fonts command
my $set_fonts = "xset +fp /usr/viewtouch/fonts";

# Github Source Jack
my $source_jack = "https://github.com/jackdigitalinsight/viewtouch.git";

# Viewtouch Make Array
my @viewtouch_make_cmds = ("cmake .",
							"make",
							"make install"
							);
#########################################							
# Make Viewtouch
sub make_viewtouch
{
	chdir("$viewtouch_dir");
	foreach my $m (@viewtouch_make_cmds)
	{
		system("$m");
	}
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
		if($make_go == 2) 
		{
			make_viewtouch();
							
		}
		else
		{
			print "make_go\n";
			louiedogg::error(__FILE__, __LINE__, "There was a problem unzipping the files.");
		}
			
	}

}

#install_viewtouch($source_jack) or die $!;

