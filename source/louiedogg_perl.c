/*
 * untitled.c
 * 
 * Copyright 2015 Louiedogg <admin@louiedogg.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>


#ifdef __unix
  //Define Linux parameters 
#elif _WIN32
	// Define Windows Parmaters
#else
  // This is not supported
#endif

char file[35] = "/usr/share/perl5/louiedogg.pm";
char louiedogg[15] = "louiedogg.pm";

int exist(char *name)
{
  struct stat   buffer;
  return (stat (name, &buffer) == 0);
}
 
int copy()
{
   char ch;
   
   FILE *source, *target;
 
   source = fopen(louiedogg, "r");
 
   if( source == NULL )
   {
      printf("Press any key to exit...\n");
      exit(EXIT_FAILURE);
   }
 
   target = fopen(file, "w");
 
   if( target == NULL )
   {
      fclose(source);
      printf("Press any key to exit...\n");
      exit(EXIT_FAILURE);
   }
   
   while( ( ch = fgetc(source) ) != EOF )
      fputc(ch, target);
 
   printf("%s copied successfully.\n", louiedogg);
 
   fclose(source);
   fclose(target);
 
   return 0;   

}

int chmod (const char *filename, mode_t mode);

int main(int argc, char **argv)
{
	
	if(exist(file))
	{	
		printf("The file exists.\n");
	}
	else if(exist(louiedogg))
	{
		copy();
		chdir("/usr/share/perl5/");
				
		if(exist(louiedogg))
		{
			system("chmod 0755 louiedogg.pm");
		}
		else
		{
			printf("Directory did not change.");
		}

	}
	else
	{
		printf("%s cannot be copied\n", louiedogg);
	}

	return 0;
}

