#!/bin/ksh

# Initialize for execution
{
   DEFAULT_NODE_LIST=`/usr/local/bin/gpfs_core_servers.sh`
   VALID_MONTHS="Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"

   AUTHOR='Chad Kerner'
   AUTHOR_EMAIL='ckerner@illinois.edu'

   PRGNAME=`basename $0`

   WORKFILE="/tmp/logs.merged"
   DEFAULT_OUTPUT_FILE="/tmp/logs.sorted"
}

function print_usage {
   cat <<EOHELP

   Usage: ${PRGNAME} OPTIONS

   This script generate a combined GPFS log file from every node specified
   for a specific month or month/day combination.  The options for it are 
   listed below.

   Option            Usage
   -d|--day XX       The day of the month you wish to scan for. Example: 1 - 31
   -m|--month MMM    The month you wish to scan for from the log file. Example: Mar 
                     Valid Months: ${VALID_MONTHS}
   -n|--nodes FILE   A file containing the list of nodes that you would like to collect
                     the logs on.  If you do not specify a node file, the script will
                     use the variable: DEFAULT_NODE_LIST for the list of nodes.  You
                     can modify this variable in the script to configure a default list
                     of nodes in the cluster.
   -o|--output FILE  The name of the file you would like the output written to.  The 
                     default output file is: ${DEFAULT_OUTPUT_FILE}

   -D|--debug        Turn on debugging for the script. This is very detailed(set -x).

   -h|--help         This help screen
   -v|--version      Print the program version.


EOHELP

   exit 0
}

function print_version {
   cat <<EOVERSION

   ${PRGNAME} ${VERSION} - ${AUTHOR} (${AUTHOR_EMAIL})
EOVERSION
}

function invalid_option {
   OPT=$1

   printf "\n\tError: An invalid options was specified: %s\n\n" ${OPT}
   exit 1
}

function process_options {
   if [ $# -eq 0 ] ; then
      print_usage
      exit 0
   fi

   while [ $# -gt 0 ]
      do case $1 in
         -D|--debug)         DEBUG=1 ;;
         -d|--day)           INDAY=$2; shift ;;
         -m|--month)         MONTH=$2; shift ;;
         -n|--nodes)         NODE_FILE=$2; shift ;;
         -o|--output)        OPTOUTFILE=$2; shift ;;
         -h|--help)          print_usage; exit 0 ;;
         -v|--version)       print_version; exit 0 ;;
         *)                  invalid_option $1; exit 1 ;;
      esac
      shift
   done
}

function validate_options {
   [[ ${DEBUG:=0} ]]

   # Check the month to make sure its valid.
   if [ "x${MONTH}" != "x" ] ; then
      MONTHRC=`echo ${VALID_MONTHS} | grep ${MONTH} | wc -l`
      if [ ${MONTHRC} -eq 0 ] ; then
         printf "\n\tError: Invalid Month: %s was specified.\n\t" ${MONTH}
         echo "Valid values are: ${VALID_MONTHS}" 
         exit 1
      fi
   fi

   # Add a leading space to the day if necessary.
   if [ "x${INDAY}" == "x" ] ; then
      DAY=""
   else
      DAY=`printf "%2s" ${INDAY}`
   fi

   if [ "x${NODE_FILE}" == "x" ] ; then
      NODE_LIST=${DEFAULT_NODE_LIST}
   else
      if [ -s ${NODE_FILE} ] ; then
         NODE_LIST=`cat ${NODE_FILE}`
      else
         printf "\n\tError: Node List: %s was not found.\n\n" ${NODE_FILE}
         exit 2
      fi
   fi

   if [ "x${OPTOUTFILE}" == "x" ] ; then
      OUTFILE=${DEFAULT_OUTPUT_FILE}
   else
      OUTFILE=${OPTOUTFILE}
   fi
}

function purge_work_files {
   rm -f ${WORKFILE} >/dev/null 2>&1
}

# Main Code Block
{
   # Process the command line options
   process_options $*

   # Perform some sanity checks
   validate_options

   # Turn on debugging if specified
   if [ ${DEBUG} -eq 1 ] ; then
      set -x
   fi
 
   purge_work_files

   rm -f ${OUTFILE} >/dev/null 2>&1
   for NODE in ${NODE_LIST}
       do echo "Gathering logs from: ${NODE}"
       SNODE=`echo ${NODE} | sed -e 's/\./ /g' | awk '{print($1)}'`
       if [ "x${MONTH}" == "x" ] ; then
          ssh ${NODE} "cat /var/adm/ras/mmfs.log*" > /tmp/${SNODE}.output
       else
          ssh ${NODE} "grep -h \"${MONTH} ${DAY}\" /var/adm/ras/mmfs.log*" > /tmp/${SNODE}.output
       fi

       if [ -s /tmp/${SNODE}.output ] ; then
          PNODE=`printf "%-12s" ${SNODE}`
          cat /tmp/${SNODE}.output | \
              while read LINE
                 do echo "${PNODE} ${LINE}" >> ${WORKFILE}
              done
       fi 
       rm -f /tmp/${SNODE}.output >/dev/null 2>&1
   done

   if [ -s ${WORKFILE} ] ; then
      sort -k 4,5 ${WORKFILE} > ${OUTFILE}
      RC=$?
      if [ ${RC} -ne 0 ] ; then
         printf "\n\tError: ${RC} on sort of ${WORKFILE}\n\n"
         exit 3
      fi
   fi

   purge_work_files

   if [ -s ${OUTFILE} ] ; then
      less ${OUTFILE}
   else
      printf "\n\tError: No Log Data For: %s %s.\n\n" ${MONTH} ${DAY}
   fi

   exit 0
}
