#!/usr/bin/env python
import logging
import logging.handlers
from subprocess import check_output, CalledProcessError

LOG_FILENAME = '/var/log/pysyslog/load.log'


def log_load(logger):
    try:
        results = check_output(["sar", "-q", "1", "1"]).splitlines()
    except CalledProcessError:
        pass
    else:
        runq_sz = results[3].split()[2]     # number of kernel threads in memory that are waiting for a CPU to run. Typically, this value should be less than 2
        plist_sz = results[3].split()[3]    # number of processes
        ldavg_1 = results[3].split()[4]     # load avg 1 minute
        ldavg_5 = results[3].split()[5]     # load avg 5 minutes
        ldavg_15 = results[3].split()[6]    # load avg 15 minutes
        blocked = results[3].split()[7]
        log_line = '{0}\t{1}\t{2}\t{3}\t{4}\t{5}'.format(runq_sz, plist_sz, ldavg_1, ldavg_5, ldavg_15, blocked)
        logger.debug(log_line)


def main():
    log_file = open(LOG_FILENAME, 'a+')
    log_file.close()
    logger = logging.getLogger('LoadMonitor')
    log_formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
    logger.setLevel(logging.DEBUG)
    log_handler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME, when='h', interval=1, backupCount=0)
    log_handler.setFormatter(log_formatter)
    logger.addHandler(log_handler)
    log_load(logger)


if __name__ == "__main__":
    main()


