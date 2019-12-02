Artifact Evaluation - Mitosis: Transparently Self-Replicating Page-Tables for Large-Memory Machines
===================================================================================================

Artifact Evaluation Report. 

`\newpage`{=latex}


Figure 1 - Teaser Figure
------------------------

**Script:** `./run_f1.sh`

**Description:** Percentage of local and remote leaf PTEs as observed from each 
socket on a TLB miss and Bottom Graph: Normalized runtime, for two workloads showing
multi-socket (left) and workload migration (right) scenarios
with their respective improvement using Mitosis.

**Reference**

![Figure 1 - Reference](reference/figure01.png "Figure 1 - Reference"){ width=100% }\

**Reproduction**

![Figure 1 - Reproduction](measured/figure01.png "Figure 1 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 3 - Remote Page-Table Entries
------------------------------------

**Script:** `./run_f3.sh`

**Description:** Analysis of page-table pointers from a page-table dump for a
 multi-socket workload: Memcached.

**Reference**

![Figure 3 - Reference](reference/figure03.png "Figure 3 - Reference"){ width=100% }\

**Reproduction**

![Figure 3 - Reproduction](measured/figure03.png "Figure 3 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 4 - Remote Page-Tables
-----------------------------

**Script:** `./run_f4.sh` 

**Description:** Percentage of remote leaf PTEs as observed from
each socket for our multi-socket workloads.

**Reference**

![Figure 4 - Reference](reference/figure04.png "Figure 4 - Reference"){ width=100% }\

**Reproduction**

![Figure 4 - Reproduction](measured/figure04.png "Figure 4 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 6 - Page-Table Placement Analysis
----------------------------------------

**Script:** `./run_f6.sh`

**Description:**  Normalized runtime of our workloads in workload migration 
scenario with 4KB page size. The lower hashed part of each bar is time spent 
in walking the page-tables. All configurations are shown in Table 2.

**Reference**

![Figure 6 - Reference](reference/figure06.png "Figure 6 - Reference"){ width=100% }\

**Reproduction**

![Figure 6 - Reproduction](measured/figure06.png "Figure 6 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 9a - Multi-Socket Scenario 4kB Pages
-----------------------------------------

**Script:**  `./run_f9.sh`

**Description:** Normalized performance with Mitosis for multi-socket workloads 
with 4KB and 2MB page size. The lower hashed part of each bar is execution time 
spent in walking the page-tables.

**Reference**

![lFigure 9 - Reference](reference/figure09a.png "Figure 9a - Reference"){ width=100% }\

**Reproduction**

![Figure 9 - Reproduction](measured/figure09a.png "Figure 9a - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 9b - Multi-Socket Scenario 2MB Pages
-------------------------------------------

**Script:**  `./run_f9.sh`

**Description:** Normalized performance with Mitosis for multi-socket workloads 
with 4KB and 2MB page size. The lower hashed part of each bar is execution time 
spent in walking the page-tables.

**Reference**

![lFigure 9 - Reference](reference/figure09b.png "Figure 9a - Reference"){ width=100% }\

**Reproduction**

![Figure 9 - Reproduction](measured/figure09b.png "Figure 9a - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 10a - Workload Migration Scenario 4kB Pages
--------------------------------------------------

**Script:** `./run_f10.sh`

**Description:** Normalized performance with Mitosis for workloads in workload 
migration scenario with 4KB and 2MB page size. The lower hashed part of each 
bar is execution time spent in walking the page-tables.

**Reference**

![Figure 10 - Reference](reference/figure10a.png "Figure 10 - Reference"){ width=100% }\\

**Reproduction**

![Figure 10 - Reproduction](measured/figure10a.png "Figure 10 - Reproduction"){ width=100% }\

`\newpage`{=latex}

Figure 10b - Workload Migration Scenario 2MB Pages
--------------------------------------------------

**Script:** `./run_f10.sh`

**Description:** Normalized performance with Mitosis for workloads in workload 
migration scenario with 4KB and 2MB page size. The lower hashed part of each 
bar is execution time spent in walking the page-tables.

**Reference**

![Figure 10 - Reference](reference/figure10b.png "Figure 10 - Reference"){ width=100% }\\

**Reproduction**

![Figure 10 - Reproduction](measured/figure10b.png "Figure 10 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Figure 11 - Memory Fragmentation
--------------------------------

**Script:** `./run_f11.sh`

**Description:** Performance of Mitosis in workload migration scenario with 
2MB pages under heavy memory fragmentation.

**Reference**

![Figure 11 - Reference](reference/figure11.png "Figure 11 - Reference"){ width=100% }\

**Reproduction**

![Figure 11 - Reproduction](measured/figure11.png "Figure 11 - Reproduction"){ width=100% }\

`\newpage`{=latex}


Table 5 - Runtime Overhead VMA Operations
-----------------------------------------

**Script:** `./run_t5.sh`

**Description:** Runtime overhead of Mitosis for virtual memory operation system 
calls using 4-way Replication
NOTE: this is in graph form here, table form in the paper.

**Reference**

![Table 5 - Reference](reference/table5.png "Table 5 - Reference"){ width=100% }\

**Reproduction**

![Table 5 - Reproduction](measured/table5.png "Table 5 - Reproduction"){ width=100% }\

`\newpage`{=latex}


