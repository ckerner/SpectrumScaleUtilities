# SpectrumScaleUtilities
IBM Spectrum Scale Utilities

This repo contains several helper scripts and utilities that we put on our clusters.

mmfslist  --  This utility uses mmlsnsd and parses the output to return a list of all
              of the file systems in the cluster.

mmshowpool  --  This utility will return what storage pool the specified file resides on.

gpfs_paths.sh  --  This sets the path to the GPFS commands at login.

Makefile  --  These utilities use the standard 'make install' and 'make clean' commands.

gpfs_core_servers.sh  --  This utility will return a list of servers that are in the core I/O list(quorum, manager).
