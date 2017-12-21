#!/usr/bin/env python
import psutil
import logging
import logging.handlers
from multiprocessing import Pool
from subprocess import check_output, CalledProcessError

LOG_FILENAME = '/var/log/pysyslog/process.log'


def count_processes(process_name, logger):
    try:
        results = len(check_output(["ps", "-o", "pid", "-C", process_name]).splitlines())
    except CalledProcessError:
        pass
    else:
        log_line = '{0}\t{1}'.format(process_name, str(results))
        logger.debug(log_line)


def main():
    log_file = open(LOG_FILENAME, 'a+')
    log_file.close()
    logger = logging.getLogger('ProcessMonitor')
    log_formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
    logger.setLevel(logging.DEBUG)
    log_handler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME, when='h', interval=1, backupCount=0)
    log_handler.setFormatter(log_formatter)
    logger.addHandler(log_handler)
    prog_list = ["java"]
    pool = Pool(processes=4)
    pool.apply_async(count_processes("convert", logger))
    pool.apply_async(count_processes("gs", logger))
    pool.apply_async(count_processes("XMPFilesProcess", logger))
    pool.apply_async(count_processes("aws", logger))

    for proc in psutil.process_iter():
        if proc.name() in prog_list:
            faults = check_output(["ps", "-o", "pid,min_flt,maj_flt", "-C", proc.name()])
            for line in faults.splitlines()[1:2]:
                pid = line.split()[0]
                if int(pid) == proc.pid:
                    min_fault = line.split()[1]
                    maj_fault = line.split()[2]
            mem_info = proc.memory_full_info()
            io_counters = proc.io_counters()
            log_line = '{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}\t{8}\t{9}\t{10}\t' \
                       '{11}\t{12}\t{13}\t{14}\t{15}\t{16}\t{17}\t{18}\t{19}\t{20}' \
                .format(proc.name(), str(proc.pid), str(proc.cpu_percent(interval=1.0)), str(proc.memory_percent()),
                        min_fault, maj_fault, mem_info.rss, mem_info.vms,
                        mem_info.shared, mem_info.text, mem_info.lib, mem_info.data,
                        mem_info.dirty, mem_info.uss, mem_info.pss, mem_info.swap,
                        io_counters.read_count, io_counters.write_count, io_counters.read_bytes,
                        io_counters.write_bytes, proc.num_threads())
            logger.debug(log_line)
            exit()

if __name__ == "__main__":
    main()
