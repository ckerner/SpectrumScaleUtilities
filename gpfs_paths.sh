# Path for GPFS Commands
if [ "${USER}" == "root" ] ; then
   export LINUX_DISTRIBUTION=REDHAT_AS_LINUX
   export PATH=/usr/lpp/mmfs/bin:$PATH
fi

