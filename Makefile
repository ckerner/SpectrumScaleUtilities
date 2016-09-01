
GPFSDIR=$(shell dirname $(shell which mmlscluster))
CURDIR=$(shell pwd)
LOCLDIR=/usr/local/bin


install: gpfs_paths mmfslist


gpfs_paths:	.FORCE
	cp -p $(CURDIR)/gpfs_paths.sh /etc/profile.d/gpfs_paths.sh


mmfslist:	.FORCE
	ln -s $(CURDIR)/mmfslist ${LOCLDIR}/mmfslist


clean:
	rm -f /etc/profile.d/gpfs_paths.sh


.FORCE:

