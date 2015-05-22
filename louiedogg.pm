#! /usr/bin/perl
#
#
# cron tab needs to parse output of bash to input password
# set owner is still screwy
#
#
#

# Copyright 2015 LouieDogg LLC
my $author = "admin\@louiedogg.com";
# ####################################################################
# Description: The louiedogg Perl Module
#
# Version: 0.01
#
# License:GPLv2
#
# ####################################################################
use strict;
use warnings;

#######################################################################
# Package
###########################
package louiedogg;

#######################################################################
# Subroutines

###########################

#########################################
#Error Handling
#Takes 3 arguments 
sub error
{	
	print "There is a problem File: $_[0]\n";
	print "Line: $_[1]\n";
	print "Contact: $author for support.\n";
	print "Subject: $_[2] \n";
	# Would like to add email to this.
	#print "Would you like to send the author an email (y or n)?";	
	#my $answer = <STDIN>;
}


#########################################
# Check if the Viewtouch User exsists if not create it and set permissions	

sub add_user
{						
	#my $password_set = 0;
	#my $password;
	#my ($password1, $password2);
	#my $p_min = 5;	# Min length for password
	#my $p_max = 10; 	# Max length for password
	#my $p_min_ok = 0;
	#my $p_max_ok = 0;
	#my $p_match = 0;
	
	chdir "/";
	
	if(!-e "home\/$_[0]")
	{
		system("useradd -m $_[0]");
		system("passwd $_[0]}");
		chdir "/";
		
		if(-e "/home/$_[0]/")
		{
			print "$_[0] has been added added\n";	
			return 1;
		}
		else
		{
			error(__FILE__, __LINE__ , "The user cannot be added\n");
		}
		
		#while($password_set == 0)
		#{
			#print "Please enter a password for the user:";
			#$password1 = <STDIN>;
			
			#print "Please re-enter the password for the user:";
			#$password2 = <STDIN>;
			
			#chomp($password1, $password2);
						
			#if($password1 eq $password2)
			#{
			#	$p_match = 1;
			#	$a = length($password1);
			#	print "$a\n";
			#	
			#	if($a >= $p_min)
			#	{
			#		$p_min_ok = 1;
			#	}
			#	else
			#	{
			#		print "Password is not long enough\n";
			#		print "Must be longer than: $p_min characters.\n";
			#	}
			#	
			#	if($a < $p_max)
			#	{
			#		$p_max_ok = 1;
			#	}
			#	else
			#	{
			#		print "Password is to long.\n";
			#		print "Password needs to be less than: $p_max characters.\n";
			#	}
			#}
			#else
			#{
			#	print "The passwords do not match!\n";
			#	print "Please Try again\n";
			#}
			#
		#	if(($p_min_ok == 1)	and
			#		($p_max_ok == 1) and
			#		($p_match == 1))
			#{
			#	$password = $password1;
			#	$password_set = 1;

			#}			
		#}
	}
	else
	{
		print "The user already exists\n";
		return 1;
	}
} # end add user

############################################################################
# Check permissions and apply sudo privledges if they do not exists
# This function take one argument - The user name
sub sudo_permission
{
	my $sudo_file = "/etc/sudoers";
	my $permission_file = "/etc/sudoers.d/viewtouch";
	
	#Permissions Hash
	my %perm;
	
	$perm{root} = "root	ALL=(ALL:ALL) ALL";		
	$perm{$_[0]} = "$_[0]	ALL=(ALL:ALL) ALL";

	chdir "/";				
	
	open(FILE, "$sudo_file") or die $!;
	my @sudo = <FILE>;
	close(FILE);
	chomp(@sudo);
	
	if($perm{root} ~~ @sudo)
	{
		if($perm{$_[0]} ~~ @sudo)
		{
			print "$_[0] is already a sudo user.\n";
			return 1;
		}
		# We can use a better check here but this should work for now
		elsif(-e $permission_file)
		{
			print "$_[0] is already a sudo user.\n";
			return 1;
		}
		else
		{
			# Note:
			# We are going to write to the /etc/sudoers.d/viewtouch
			# file instead of messing with the /etc/sudoers file
			
			#while(my( $key, $value ) = each @sudo )
			#{			
			#	chomp($value);
			#
			#	if($value eq $perm{root})
			#	{											
			#		splice @sudo, ++$key, 0, $perm{$_[0]};
			#	}		
			#}
			#foreach my $line (@sudo)
			#{
			#	$line = $line."\n";
			#}
			
			my $write = louiedogg::write_file_string($permission_file, $perm{$_[0]});
		
			if($write)
			{
				print "File was written to $permission_file\n";
				return 1;
			}
			else
			{
				louiedogg::error(__FILE__, __LINE__, "Error with writing permissions")
			}
		}
	}
	else
	{
		louiedogg::error(__FILE__, __LINE__, "Error accessing $sudo_file.\n");		
	}

}# End sudo_permissions

sub switch_user
{
	print "Switching to $_[0] now!\n";
	system("su ".$_[0]);
}

#########################################
# Enable auto-login

sub gnome_auto_login
{	
	my $arg = "$_[1]";
	my $auto_login_file = "/etc/gdm3/daemon.conf";		
	my @enable = ( 	"AutomaticLoginEnable = true", 
					"AutomaticLogin = $_[0]"
					);					
	my @disable;
	my $i = 0;
	
	foreach my $str (@enable)
	{
		$disable[$i++] = "# ".$str;
	}
						
	chdir "/";
				
	open(FILE, "$auto_login_file") or die $!;
	my @a = <FILE>;
	close(FILE);
									
	if(@a)
	{
		my $arr_set = 0;
		
		while(my( $key, $value ) = each @a )
		{			
			chomp($value);
			
			if($arg eq "--enable")
			{			
				if($value eq "$enable[0]")
				{															
					print "Auto login is already enabled\n";
					return 0;
				}
				elsif($value eq "$disable[0]")
				{
					splice @a, $key, 2, @enable;
					$arr_set = 1;
				}				
			}
			elsif($arg eq "--disable")
			{							
				if($value eq "$enable[0]")
				{															
					splice @a, $key, 2, @disable;
					$arr_set = 1;
				}
				elsif($value eq "$disable[0]")
				{					
					print "Auto login is already disabled\n";
					return 0;
				}

			}
			else
			{
				print "The subroutine gnome_auto_login takes two variables:\n";
				print 'The username and --enable and --disable';		
				print 'Example gnome_auto_login("$username", "--enable")'."\n";
			}			
		} # end while

		if($arr_set == 1)
		{
			chomp(@a);

			foreach my $line (@a)
			{
				$line = $line."\n";
			}
						
			my $set_login = louiedogg::write_file_array($auto_login_file, \@a);
			
			if($set_login)
			{
				print "$auto_login_file has been written\n";
			}
			else
			{
				louiedogg::error(__FILE__, __LINE__, $!);
			}
		}
		else
		{
			louiedogg::error(__FILE__, __LINE__, "Error reading $auto_login_file");
		}
	
	}
	else
	{
		louiedogg::error(__FILE__, __LINE__, "Error reading $auto_login_file");
	}						

}

#########################################
# Set the owner of a directory
# Takes two arugments - First one is permission and the second is directory
sub set_owner
{
	my $user = $_[0];
	my $dir = $_[1];
	my $uid = `id -u $user`;
	my $gid = `id -g $user`;
	
	
	if (-e "/home/$user/")
	{
		chdir"/";	
		chown $uid, $gid, $dir or die $!;
		return 1; 
	}
	else
	{
		die "User does not exist.";
	}
}

#########################################
# Write array to file 
# Takes two arguments first is the file and the second is what to write to it
sub write_file_array
{
	my @body = @{$_[1]};
	open(FILE, ">$_[0]") 	or die $!;
	flock(FILE, 2)			or die $!;
	print FILE @body 	or die $!;
	close(FILE) 			or die $!;
		
	return 1;	
} # end write file

#########################################
# Write sting to file
# Takes two arguments first is the file and the second is what to write to it
sub write_file_string
{
	open(FILE, ">$_[0]") 	or die $!;
	flock(FILE, 2)			or die $!;
	print FILE "$_[1]" 		or die $!;
	close(FILE) 			or die $!;	

	return 1;	
} # end write file

#########################################
# Append to end of file 
# Takes two arguments first is the file and the second is what to write to it
sub append_file
{
	open(FILE, ">>$_[0]");
	flock(FILE, 2);
	print FILE "$_[1]";
	close(FILE);
	
	return 1;	
} # end write file


#########################################
# Append to End of a cron
# This take one argument which is the actual cron line
sub append_cron
{
	system("su $_[0]") or die $!;
	open my $fh, "| crontab -" || die "can't open crontab: $!";
	my $crontab = qx(crontab -l);
	print $fh "$crontab\n$_[1]\n";
	close $fh;
	return 1;
}

#########################################
# Reboot system
# This take one argument
sub reboot
{
	system("shutdown -r -t $_[0] ")
}

