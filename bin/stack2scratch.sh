#!/bin/bash -l
#

jobname="stack2scratch"
mempercpu="3G"
ntasks=1
ntaskspernode=1
cpuspertask=16
qos="emcpu"
partition="emcpu"
duration="06:00:00"
tot_nodes=40

echo "Launching jobs to copy ${1} to ${2} at the nodes on `date`..." | tee ${jobname}-$$.log

i=1
while [ ${i} -le ${tot_nodes} ]
do
	sbatch \
	-o ${jobname}-$$.log \
	-e ${jobname}-$$.log \
	--job-name=${jobname} \
	--mem-per-cpu=${mempercpu} \
	--ntasks=${ntasks} \
	--ntasks-per-node=${ntaskspernode} \
	--cpus-per-task=${cpuspertask} \
	--qos=${qos} \
	--partition=${partition} \
	--time=${duration} \
	stack2scratch_n.sh \
	${1} \
	${2}

	let i+=1
done

echo "Finished launching ${tot_nodes} jobs on `date`..." | tee ${jobname}-$$.log

exit 0