# Setup

There are 4 steps required to get up and running with THE_Aligner

1. [Install conda (or mamba) on your system](#conda). This is the package manager that THE_Aligner uses to make setting up the necessary dependencies a breeze.
1. [Deploy workflow](#deploy) with [Snakedeploy](https://snakedeploy.readthedocs.io/en/latest/index.html)
1. [Edit the config file](#config) (located in config/ directory of deployed/cloned repo) to your liking
1. [Run it!](#run)

The remaining documentation on this page will describe each of these steps in greater detail and point you to additional documentation that might be useful.

## Quickstart

All of the steps necessary to deploy the pipeline are discussed in great detail below. Here, I will present a super succinct description of what needs to be done, with all necessary code included:

``` bash
### 
# PREREQUISITES: INSTALL MAMBA AND GIT (only need to do once)
###

# CREATE ENVIRONMENT (only need to do once)
mamba create -c conda-forge -c bioconda --name deploy_snakemake snakemake snakedeploy

# CREATE AND NAVIGATE TO WORKING DIRECTORY (only need to do once)
mkdir path/to/working/directory
cd path/to/working/directory

# DEPLOY PIPELINE TO YOUR WORKING DIRECTORY (only need to do once)
conda activate deploy_snakemake
snakedeploy deploy-workflow https://github.com/isaacvock/THE_Aligner.git . --branch main

# RUN PIPELINE

# See [here](https://snakemake.readthedocs.io/en/stable/executing/cli.html) for details on all of the configurable parameters
snakemake --cores all --use-conda 
```

### Install conda (or mamba)<a name="conda"></a>
[Conda](https://docs.conda.io/projects/conda/en/latest/index.html) is a package/environment management system. [Mamba](https://mamba.readthedocs.io/en/latest/) is a newer, faster, C++ reimplementation of conda. While often associated with Python package management, lots of software, including all of the THE_Aligner pipeline dependencies, can be installed with these package managers. They have pretty much the same syntax and can do the same things, so I highly suggest using Mamba in place of Conda whenever possible. 

One way to install Mamba is to first install Conda following the instructions at [this link](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html). Then you can call:

``` bash
conda install -n base -c conda-forge mamba
```
to install Mamba.

A second strategy would be to install Mambaforge, which is similar to something called Miniconda but uses Mamba instead of Conda. I will reproduce the instructions to install Mambaforge below, as this is probably the easiest way to get started with the necessary installation of Mamba. These instructions come from the [Snakemake Getting Started tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/setup.html), so go to that link if you'd like to see the full original details:

* For Linux users with a 64-bit system, run these two lines of code from the terminal:

``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o Mambaforge-Linux-x86_64.sh
bash Mambaforge-Linux-x86_64.sh
```
* For Mac users with x86_64 architecture: 
``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-x86_64.sh -o Mambaforge-MacOSX-x86_64.sh
bash Mambaforge-MacOSX-x86_64.sh
```
* And for Mac users with ARM/M1 architecture:
``` bash
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-MacOSX-arm64.sh -o Mambaforge-MacOSX-arm64.sh
bash Mambaforge-MacOSX-arm64.sh
```

When asked this question:
``` bash
Do you wish the installer to preprend the install location to PATH ...? [yes|no]
```
answer with `yes`. Prepending to PATH means that after closing your current terminal and opening a new one, you can call the `mamba` (or `conda`) command to install software packages and create isolated environments. We'll be using this in the next step.

### Deploy workflow<a name="deploy"></a>

THE_Aligner can be deployed using the tool [Snakedeploy](https://snakedeploy.readthedocs.io/en/latest/index.html). This is often more convenient than cloning the full repository locally. To get started with Snakedeploy, you first need to create a simple conda environment with Snakemake and Snakedeploy:


``` bash
mamba create -c conda-forge -c bioconda --name deploy_snakemake snakemake snakedeploy
```

Next, create a directory that you want to run THE_Aligner in (I'll refer to it as `workdir`) and move into it:
``` bash
mkdir workdir
cd workdir
```

Now, activate the `deploy_snakemake` environment and deploy the workflow as follows:

``` bash
conda activate deploy_snakemake
snakedeploy deploy-workflow https://github.com/isaacvock/THE_Aligner.git . --branch main
```

`snakedeploy deploy-workflow https://github.com/isaacvock/THE_Aligner.git` copies the content of the `config` directory in the THE_Aligner Github repo into the directoy specified (`.`, which means current directory, i.e., `workdir` in this example). It also creates a directory called `workflow` that contains a singular Snakefile that instructs Snakemake to use the workflow hosted on the main branch (that is what `--branch main` determines) of the THE_Aligner Github repo. `--branch main` can be replaced with any other existing branch.

### Edit the config file<a name="config"></a>

In the `config/` directory you will find a file named `config.yaml`. If you open it in a text editor, you will see several parameters which you can alter to your heart's content. The first parameter that you have to set is at the top of the file:

``` yaml
samples:
  WT_1: data/fastq/WT_1
  WT_2: data/fastq/WT_2
  WT_ctl: data/fastq/WT_ctl
  KO_1: data/fastq/KO_1
  KO_2: data/fastq/KO_2
  KO_ctl: data/fastq/KO_ctl
```
`samples` is the list of sample IDs and paths to .bam files that you want to process. Delete the existing sample names and paths and add yours. The sample names in this example are `WT_1`, `WT_2`, `WT_ctl`, `KO_1`, `KO_2`, and `KO_ctl`. These are the sample names that will append many of the files output by THE_Aligner. The `:` is necessary to distinguish the sample name from what follows, the path to the relevant bam file. Note, the path can be absolute (e.g., ~/path/to/fastqs/) or relative to the directory that you deployed to (i.e., `workdir` in this example). In the example config, the paths specified are relative. Thus, in this example, the bam files are located in a directory called `samples` that is inside of a directory called `data` located in `workdir`. Your data can be wherever you want it to be, but it might be easiest if you put it in a `data` directory inside the THE_Aligner directory as in this example. 

As another example, imagine that the `data` directory was in the directory that contains `workdir`, and that there was no `samples` subdirectory inside of `data`. In that case, the relative paths would look something like this:

``` yaml
samples:
  WT_1: ../data/WT_1
  WT_2: ../data/WT_2
  WT_ctl: ../data/WT_ctl
  KO_1: ../data/KO_1
  KO_2: ../data/KO_2
  KO_ctl: ../data/KO_ctl
```
where `../` means navigate up one directory. 

The remaining required parameters are:

* `PE`: True if fastqs are paired-end. False if they are single-end.
* `genome`: Path to genome fasta file to align to.
* `annotation`: Path to annotation gtf file. Used to generate splice-aware alignment indices or to quantify with respect to if using a pseudoaligner.
* `transcriptome`: Path to transcriptome fastq file. Only relevant for pseudoaligners, and will get created automatically at the specified path if it does not already exist.
* `aligner`: Determines which aligner will be used (options are `"bwa-mem2"`, `"bowtie2"`, `"star"`, `"hisat2"`,`"kallisto"`, `"salmon"`).
* `indices`: Path to aligner indices. These will be created at this path if not already present.
* `strandedness`: Parameter specifying library strandedness. Options are "reverse", "yes", or "no". Naming convention comes from HTSeq, but the parameter is used in THE_Aligner by Salmon and Hisat2.
* `directionality`: Whether the reads face inwards, outwards, or in the same direction. Only used by Salmon.

 The remaining optional parmeters allow you to tune and alter the functionality of all tools used by THE_Aligner. The top of this set includes one parameter that is probably best to check before running the pipeline; the adapters to trim. See config comments and linked documentation for details. The remaining are purely optional but can allow you to modify default settings of any tool used. **NOTE: You never have to set parameters specifying output files or number of threads to be used**; THE_Aligner will handle these automatically.

### Run it!<a name="run"></a>

Once steps 1-3 are complete, THE_Aligner can be run from the directory you deployed the workflow to as follows:

``` bash
snakemake --cores all --use-conda
```
There are **A LOT** of adjustable parameters that you can play with when running a Snakemake pipeline. I would point you to the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executing/cli.html) 
for the details on everything you can change when running the pipeline.

