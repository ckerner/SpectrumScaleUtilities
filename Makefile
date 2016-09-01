
GPFSDIR=$(shell dirname $(shell which mmlscluster))
CURDIR=$(shell pwd)
LOCLDIR=/usr/local/bin


install: gpfs_paths 


gpfs_paths:	.FORCE
	cp -p $(CURDIR)/gpfs_paths.sh /etc/profile.d/gpfs_paths.sh


clean:
	rm -f /etc/profile.d/gpfs_paths.sh


.FORCE:

