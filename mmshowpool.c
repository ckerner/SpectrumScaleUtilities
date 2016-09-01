/*
 * mmshowpool - Given a filename this will return the name of the
 *              storage pool that file resides on in GPFS.
 *
 * Chad Kerner - ckerner@illinois.edu
 * Systems Engineer, Storage Enabling Technologies
 * National Center for Supercomputing Applications
 * University of Illinois, Urbana-Champaign
 *
*/

#define GPFS_64BIT_INODES 1

#ifdef GPFS_LINUX
/* Use 64 bit version of stat, etc. */
#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64
#endif
 
#include <stdlib.h>
#include <stdio.h>
#include <libgen.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <gpfs.h>
#include <gpfs_fcntl.h>


/* print usage message and exit */
void usage( char *argv0 )
{
   fprintf( stderr, "\n\tUsage: %s PATHNAME\n", basename(argv0) );
   fprintf( stderr, "\n\tExample: %s /gpfs/fs0/test\n", basename(argv0) );
   fprintf( stderr, "\tsystem /gpfs/fs0/test\n\n" );
   exit( 1 );
}

void show_pool( const char *filename ) {
   int rc;
   int fd;
   extern int errno;

   /* The GPFS structure for holding the storage pool information. */
   struct {
      gpfsFcntlHeader_t hdr;
      gpfsGetStoragePool_t pool;
   } fcntlArg;

   /* Set up for the call to get the storage pool information. */
   fcntlArg.hdr.totalLength = sizeof(fcntlArg.hdr) + sizeof(fcntlArg.pool);
   fcntlArg.hdr.fcntlVersion = GPFS_FCNTL_CURRENT_VERSION;
   fcntlArg.hdr.fcntlReserved = 0;

   fcntlArg.pool.structLen = sizeof(fcntlArg.pool);
   fcntlArg.pool.structType = GPFS_FCNTL_GET_STORAGEPOOL;

   fd = open( filename, O_RDONLY );
   if( fd < 0 ) {
       fprintf( stderr, "Error: %s - %s\n", strerror( errno ), filename );
       exit( errno );
   }

   /* I have a file, get the information. */
   rc = gpfs_fcntl( fd, &fcntlArg );
   if( rc == 0 ) {
       close( fd );
       printf("%s %s\n", &fcntlArg.pool.buffer, filename );
   }
}

void process_directory( const char *dirname ) {
    DIR *dirp;
    struct dirent *dp;
    char fqpn[1024];

    dirp = opendir( dirname );
    while( ( dp = readdir( dirp ) ) != NULL ) {
      /* Skip the . and .. entries in each directory. */
      if( ( strcmp( dp->d_name, "." ) == 0 ) || ( strcmp( dp->d_name, ".." ) == 0 ) )
          continue;

      sprintf(fqpn, "%s/%s", dirname, dp->d_name );
      if( dp->d_type == DT_REG ) {
          show_pool( fqpn );
      }
      else if( dp->d_type == DT_DIR ) {
          process_directory( fqpn );
      }
    }
    closedir( dirp );
}


/* main */
int main( int argc, char *argv[] )
{
   int rc;
   size_t length;
   char newdir[1024] = "";
   struct stat myStat;

   /* if a pathname was not specified, there is nothing to do */
   if( argc != 2 )
       usage( argv[0] );

   rc = stat( argv[1], &myStat );
   if( myStat.st_mode & S_IFDIR ) {
       /* 
        * If a directory was specified on the command line, strip off 
        * a trailing / if it was specified.                      
       */
       length = strlen( argv[1] );
       if( argv[1][length-1] == '/' ) 
           length = length - 1;

       strncpy( newdir, argv[1], length );

       process_directory( newdir );
   }
   else {
       show_pool( argv[1] );
   }

}


