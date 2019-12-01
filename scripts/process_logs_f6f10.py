#!/usr/bin/python
import sys
import os
import statistics

benchmarks = dict()
curr_bench = ""
curr_config = ""
summary = []
benchmarks = []

#---directories that contain the data
#figures = ["figure6", "figure9", "figure10"]
figures = ["figure6", "figure10"]

#---all workload configurations
configs = ["LPLD", "LPRD", "LPRDI", "RPLD", "RPILD", "RPRD", "RPIRDI", "RPLDM", "RPILDM",
            "TLPLD", "TLPRD", "TLPRDI", "TRPLD", "TRPILD", "TRPRD", "TRPIRDI", "TRPLDM", "TRPILDM"]

pretty_configs = ["LP-LD", "LP-RD", "LP-RDI", "RP-LD", "RPI-LD", "RP-RD", "RPI-RDI", "RP-LDM", "RPI-LD+M",
            "TLP-LD", "TLP-RD", "TLP-RDI", "TRP-LD", "TRPI-LD", "TRP-RD", "TRPI-RDI", "TRP-LD+M", "TRPI-LD+M"]
#---all workloads
workloads = ["gups", "btree", "hashjoin", "redis", "xsbench", "pagerank", "liblinear", "canneal"]
pretty_workloads = ["GUPS", "BTree", "HashJoin", "Redis", "XSBench", "PageRank", "LibLinear", "Canneal"]
#configs = ["LPLD", "LPRD", "RPLD", "LPRDI", "RPILD", "RPRD", "RPIRDI"]

def get_time_from_log(line):
    exec_time = int(line[line.find(":")+2:])
    return exec_time

def print_workload_config(log):
    global curr_bench, curr_config
    for bench in workloads:
        if bench in log:
            curr_bench = bench
            break

    config = ""
    for tmp in configs:
            search_name = "-" + tmp + "-"
            if search_name in log:
                config =tmp
                break

    curr_config = config
    benchmarks.append(curr_bench)

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

def pretty(name):
    if name in configs:
        index = configs.index(name)
        return pretty_configs[index]
    if name in workloads:
        index = workloads.index(name)
        return pretty_workloads[index]

    print ("ERROR converting \"%s\" to pretty" %name)
    sys.exit()

def dump_workload_config_average(output, bench, config, fd, absolute):
    cycles = 0
    pwc = 0
    count = 0
    arr_cycles = []
    for result in output:
        if result["bench"].lower() == bench.lower() and result["config"] == config:
            arr_cycles.append(result["cycles"])
            cycles += result["cycles"]
            pwc += result["pwc"]
            count += 1


    if count == 0:
        #print("Data unavailable for %s %s" %(bench, config))
        return

    if absolute:
            cycles = int(cycles / count)
            pwc = int (pwc / count)
            line = "%s\t%s\t%d\t%d\t%d\n" % (pretty(bench), pretty(config), cycles, pwc, cycles-pwc)
            fd.write(line)
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
        print("Baseline not found for %s %s" %(curr_bench, curr_config))
        print("Unable to normalize.")
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
    #line = "%s\t%s\t%f\t%f\t%f\t%f" % (bench, config, norm_cycles, rest_cycles, stdev, norm_perf)
    line = "%s\t%s\t%f\t%f\t%f" % (pretty(bench), pretty(config), norm_cycles, rest_cycles, norm_perf)
    fd.write(line + "\n")

def process_all_runs(fd, output, absolute):
    global benchmarks, configs, curr_bench
    benchmarks = list(dict.fromkeys(benchmarks))

    if absolute:
        fd.write("Workload\tConfiguration\tRuntime Cycles\tWalk Cycles\tNon-Walk Cycles\n")
    else:
        #fd.write("Workload\tConfiguration\tWalkCycles\tNon-WalkCycles\tStd. Dev.\tNorm. Perf.\n")
        fd.write("Workload\tConfiguration\tWalk Cycles\tNon-Walk Cycles\t Norm. Perf.\n")
    #fd.write("Workload\tConfiguration\tRuntime Cycles\tWalk Cycles\tNon-Walk Cycles\n")
    for bench in workloads:
        curr_bench = bench
        # --- print name only for the first config
        for config in configs:
            printed = dump_workload_config_average(output, bench, config, fd, absolute)

    fd.close()

def gen_figure6_csv(path, absolute):
    # --- put it under evaluation
    root=os.path.dirname(os.getcwd())
    fd6_path = os.path.join(root, "evaluation/measured/figure6/figure6_normalized.csv")
    if absolute:
        fd6_path = os.path.join(root, "evaluation/measured/figure6/figure6_absolute.csv")

    fd6 = open(fd6_path, "w")
    if fd6 is None:
        print("ERROR creating figure6.csv.")
        sys.exit()

    fd = open(path, "r")
    if fd is None:
        print("ERROR unable to open the common csv file")
        sys.exit()

    fig6_configs = ["LP-LD", "LP-RD", "LP-RDI", "RP-LD", "RPI-LD", "RP-RD", "RPI-RDI"]
    # --- copy the first line as it is
    fd6.write(fd.readline())
    line = fd.readline()
    while line:
        columns = line.split()
        valid = False
        if columns[1] in fig6_configs:
            fd6.write(line)

        line = fd.readline()
   
    fd.close() 
    fd6.close()
    print("Location: %s" %fd6_path)

def gen_figure10_csv(path, thp, absolute):
    # --- put it under evaluation
    root = os.path.dirname(os.getcwd())
    out_file = os.path.join(root, "evaluation/measured/figure10")
    fig10_configs = ["LP-LD", "RPI-LD", "RPI-LD+M"]
    path_suffix="_normalized"
    if absolute:
        path_suffix="_absolute"

    if thp == True:
        out_file = os.path.join(out_file, "figure10b" + path_suffix + ".csv")
        fig10_configs = ["TLP-LD", "TRPI-LD", "TRPI-LD+M"]
    else:
        out_file = os.path.join(out_file, "figure10a" + path_suffix + ".csv")

    fd10_path = os.path.join(os.getcwd(), out_file)
    fd10 = open(fd10_path, "w")
    if fd10 is None:
        print("ERROR creating %s." %out_file)
        sys.exit()

    fd = open(path, "r")
    if fd is None:
        print("ERROR unable to open the common csv file")
        sys.exit()

    # --- copy the first line as it is
    fd10.write(fd.readline())
    line = fd.readline()
    curr_bench="XXX"
    while line:
        columns = line.split()
        if columns[1] in fig10_configs:
            fd10.write(line)
        #if columns[0] in workloads:
        #    curr_bench = columns[0]
        #    isNew = 1

        #if columns[0] in fig10_configs or columns[1] in fig10_configs:
        #    if isNew == 1 and thp == True:
        #        line = curr_bench + line
        #        isNew = 0
        #    fd10.write(line)

        line = fd.readline()
   
    fd.close() 
    fd10.close()
    prefix="Normalized"
    if absolute:
        prefix="Absolute"

    print("%s: %s" %(prefix, fd10_path))
    
if __name__=="__main__":
    root = os.path.dirname(os.getcwd())
    out_dir = os.path.join(root, "evaluation/measured")

    print("Reading dumps for Figure-6 and Figure-10")

    for figure in figures:
        exp_dir = os.path.join(out_dir, figure)
        for root,dir,files in os.walk(exp_dir):
            for benchmark in dir:
                path = os.path.join(root, benchmark)
                traverse_benchmark(path)
            break

    norm_src = os.path.join(out_dir, "common_normalized.csv")
    abs_src = os.path.join(out_dir, "common_absolute.csv")
    fd_norm = open(norm_src, "w")
    fd_abs = open(abs_src, "w")
    if fd_norm is None or fd_abs is None:
        print("ERROR creating csv file")
        sys.exit()

    # --- process normalized data
    process_all_runs(fd_norm, summary, False)
    process_all_runs(fd_abs, summary, True)
    print("Generating Figure-6 csv file")
    # --- process absolute and normalized separately
    gen_figure6_csv(norm_src, False)
    gen_figure6_csv(abs_src, True)
    print("Generating Figure-10(a) csv file")
    # --- process absolute and normalized separately
    gen_figure10_csv(norm_src, False, False) # --- Fig-a/Fig-b and absolute/nomalized
    gen_figure10_csv(abs_src, False, True) # --- Fig-a/Fig-b and absolute/nomalized
    print("Generating Figure10(b) csv file")
    gen_figure10_csv(norm_src, True, False) # --- Fig-a/Fig-b and absolute/nomalized
    gen_figure10_csv(abs_src, True, True) # --- Fig-a/Fig-b and absolute/nomalized
    # --- process absolute and normalized separately
    fd_norm.close()
    fd_abs.close()
    #print("Common csv files:")
    #print("Normalized: %s" %norm_src)
    #print("Absolute: %s" %abs_src)