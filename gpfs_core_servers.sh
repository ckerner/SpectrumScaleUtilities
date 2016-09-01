#!/bin/bash

MYPROG=$0
SRCFILE=`readlink ${MYPROG}`
SRCDIR=`dirname ${SRCFILE}`

source ${SRCDIR}/gpfs_common_functions
TEMPFILE=/tmp/.server.list.$$

/usr/lpp/mmfs/bin/mmlscluster | \
   ${GREP} -E "quorum|manager" | \
   ${AWK} '{print($2)}' > ${TEMPFILE}

/usr/lpp/mmfs/bin/mmlsnsd | \
  ${SED} -e 's/free disk/free_disk/g' | \
  ${GREP} -vE "^ File system|^----|^$" | \
  ${AWK} '{print($3)}' | \
  ${TR} ',' '\n' >> ${TEMPFILE}

${CAT} ${TEMPFILE} | \
  ${SORT} | \
  ${UNIQ}

${RM} -f ${TEMPFILE} &>/dev/null
