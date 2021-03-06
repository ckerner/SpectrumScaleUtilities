INCL = -I/usr/lpp/mmfs/include
LIBS = -lpthread -lrt -lgpfs

CFLAGS = -O -DGPFS_LINUX -DFILE_OFFSET_BITS=64

CC = cc
CC_R = cc
CXX = c++
GPFS_TYPE = GPFS_LINUX

GPFSDIR=$(shell dirname $(shell which mmlscluster))
CURDIR=$(shell pwd)
LOCLDIR=/usr/local/bin


install: gpfs_paths mmfslist mmshowpool misc_utils


gpfs_paths:	.FORCE
	cp -p $(CURDIR)/gpfs_paths.sh /etc/profile.d/gpfs_paths.sh

misc_utils:	.FORCE
	ln -s $(CURDIR)/gpfs_core_servers.sh $(LOCLDIR)/gpfs_core_servers.sh
	ln -s $(CURDIR)/merge_gpfs_logs.sh $(LOCLDIR)/merge_gpfs_logs.sh

mmfslist:	.FORCE
	ln -s $(CURDIR)/mmfslist $(LOCLDIR)/mmfslist

mmshowpool:	.FORCE
	$(CC) -o mmshowpool $(CFLAGS) $(LIBS) $(INCL) $(OTHERINCL) $(OTHERLIB) mmshowpool.c
	ln -s $(CURDIR)/mmshowpool $(LOCLDIR)/mmshowpool

clean:
	rm -f /etc/profile.d/gpfs_paths.sh
	rm -f $(LOCLDIR)/mmfslist
	rm -f $(LOCLDIR)/mmshowpool
	rm -f $(LOCLDIR)/gpfs_core_servers.sh
	rm -f $(LOCLDIR)/merge_gpfs_logs.sh


.FORCE:

