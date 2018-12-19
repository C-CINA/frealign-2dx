#!/bin/bash -l
#
##SBATCH -o stack2scratch.log
##SBATCH -e stack2scratch.log
##SBATCH --job-name=stack2scratch_n
##SBATCH --mem-per-cpu=1G
##SBATCH --ntasks=1
##SBATCH --ntasks-per-node=1
##SBATCH --cpus-per-task=16
##SBATCH --qos=emcpu
##SBATCH --partition=emcpu
##SBATCH --time=04:00:00
##SBATCH --mail-user=ricardo.righetto@unibas.ch
##SBATCH --mail-type=ALL

echo "Copying stack ${1} to ${2} at `hostname` on `date`..."
mkdir -p ${2}
rsync -auP ${1} ${2}
# echo `hostname` `date` >> ${2}/test.txt
echo "Finished rsync at `hostname` on `date`."