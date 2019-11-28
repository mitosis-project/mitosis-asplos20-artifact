import sys
import os
import statistics

benchmarks = dict()
curr_bench = ""
curr_config = ""
summary = []
benchmarks = []
configs = ["LPLD", "LPRD", "LPRDI", "RPLD", "RPILD", "RPRD", "RPIRDI", "RPM", "RPIM", "T-LPLD",
            "T-LPRD", "T-LPRDI", "T-RPLD", "T-RPILD", "T-RPRD", "T-RPIRDI", "T-RPM", "T-RPIM"]
workloads = ["GUPS", "BTREE", "HASHJOIN", "REDIS", "XSBENCH", "PAGERANK", "LR", "CANNEAL"]
#configs = ["LPLD", "LPRD", "RPLD", "LPRDI", "RPILD", "RPRD", "RPIRDI"]

def get_time_from_log(line):
    exec_time = int(line[line.find(":")+2:])
    return exec_time

def print_workload_config(log):
    global curr_bench, curr_config
    first = log.find("/")
    second = log.find("/", first + 1)
    name = log[first+1:second]
    curr_bench = name.upper()
    benchmarks.append(curr_bench)
    first = log.find("-config")
    first = log.find("-", first + 6)
    second = log.find("-", first + 1)
    config = log[first+1:second]
    current_key = name + "-"
    if "-thp-" in log:
        config = "T-" + config
    curr_config = config.upper()
    #configs.append(curr_config)

def process_perf_log(path):
    fd = open(path, "r")
    if not fd:
        print ('error opening log file')
        sys.exit(1)

    cycles=0
    dtlb_miss_cycles=0
    ept_cycles=0
    exec_time = -1
    while True:
        line = fd.readline()
        if not line:
            break
        if ",cycles," in line:
            cycles=int(line[:line.find(",")])
        elif ",dtlb_load_misses.walk_duration," in  line:
            dtlb_miss_cycles += int(line[:line.find(",")])
        elif ",dtlb_store_misses.walk_duration," in line:
            dtlb_miss_cycles += int(line[:line.find(",")])
        elif "Execution Time (seconds)" in line:
            exec_time = get_time_from_log(line)
        else:
            continue

    # --- log may be from an incomplete run and if so, ignore
    if cycles == 0:
        return

    #pwc_overhead = (dtlb_miss_cycles * 100)/cycles
    fd.close()
    output = {}
    output["bench"] = curr_bench
    output["config"] = curr_config
    output["time"] = exec_time
    output["cycles"] = cycles
    output["pwc"] = dtlb_miss_cycles
    summary.append(output)
 
def traverse_benchmark(path):
    # --- process THP and NON-THP configs separately
    for root,dir,files in os.walk(path):
        for filename in files:
            log = os.path.join(root,filename) 
            print_workload_config(log)
            process_perf_log(log)

def print_average(output, bench, config, printName, fd):
    cycles = 0
    pwc = 0
    count = 0
    arr_cycles = []
    for result in output:
        if result["bench"] == bench and result["config"] == config:
            arr_cycles.append(result["cycles"])
            cycles += result["cycles"]
            pwc += result["pwc"]
            count += 1

    if count == 0:
        print("Data unavailable for %s %s" %(bench, config))
        return

    stdev = 0
    if count > 1:
        stdev = statistics.stdev(arr_cycles)
        
    # --- take the average
    cycles = cycles/count
    pwc = pwc/count
    count = 0
    baseline = 0
    baseline_pwc = 0
    for result in output:
        if result["bench"] == bench and result["config"] == "LPLD":
            baseline += result["cycles"]
            baseline_pwc += result["pwc"]
            count += 1

    # --- incase baseline is not present
    if count == 0:
        return

   # --- take the average
    baseline = baseline / count
    baseline_pwc = baseline_pwc / count
    baseline_pwc_fraction = baseline_pwc / float(baseline)
    norm_perf = cycles / float(baseline)
    norm_cycles = (pwc / float(baseline))
    rest_cycles = norm_perf - norm_cycles #(cycles-pwc)/float(baseline)
    # --- normalize std dev
    stdev = stdev / float(baseline)
 
    if printName == True:
        line = "%s\t%s\t%f\t%f\t%f\t%f" % (bench, config, norm_cycles, rest_cycles, stdev, norm_perf)
    else:
        line = "\t%s\t%f\t%f\t%f\t%f" % (config, norm_cycles, rest_cycles, stdev, norm_perf)

    print(line)
    fd.write(line + "\n")

def process_average(output):
    global benchmarks, configs
    benchmarks = list(dict.fromkeys(benchmarks))
    fd = open("output.csv", "w")
    if fd is None:
        print("Unable to open csv file for writing")
        sys.exit(1)
    fd.write("\t\tPage-walk\tExecution\tStd. Dev.\tNorm. Perf.\n")
    #for bench in benchmarks:
    for bench in workloads:
        # --- print name only for the first config
        printName = True
        for config in configs:
            print_average(output, bench, config, printName, fd)
            printName = False

    fd.close()

if __name__=="__main__":
    for root,dir,files in os.walk("data/"):
        for benchmark in dir:
            traverse_benchmark(os.path.join(root, benchmark))
        break

    #for data in sorted(summary):
    #    print(data["bench"] + "-" + data["config"] + "\t:\t" + str(data["time"]) + " (%d)" %data["pwc"])
    process_average(summary)
