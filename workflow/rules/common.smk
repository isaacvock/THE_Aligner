import glob

# Sample names to help expanding lists of all bam files
# and to aid in defining wildcards
SAMP_NAMES = list(config['samples'].keys())

# Directory containing index; used in case of certain aligners
INDEX_DIR = config["index"]

# Determine how many fastqs to look for
if config["PE"]:
    READS = [1, 2]
    READ_NAMES = ['r1', 'r2']
else:
    READS = [1]
    READ_NAMES = ['r1']


# Bowtie2 has two different alignment index suffixes, so gotta figure out which will apply
if config["aligner"] == "bowtie2":

    if config["bowtie2_build_params"].str.contains("large-index"):
        INDEX_SUFFIX = "21"
    else:
        INDEX_SUFFIX = "2"

# Make life easier for users and catch if they add a '/' at the end of their path
# to alignment indices. If so, remove it to avoid double '/' 
if config["indices"].endswith('/'):
    INDEX_PATH = str(config["indices"])
    INDEX_PATH = INDEX_PATH[:-1]
else:
    INDEX_PATH = str(config["indices"])

# Get input fastq files for first step
def get_input_fastqs(wildcards):
    fastq_path = config["samples"][wildcards.sample]
    fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
    return fastq_files

## Get reads individually
if config["PE"]:

    def get_input_r1(wildcards):
        fastq_path = config["samples"][wildcards.sample]
        fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
        return fastq_files[1]

    def get_input_r2(wildcards):
        fastq_path = config["samples"][wildcards.sample]
        fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
        return fastq_files[2]

else:

    def get_input_r(wildcards):
        fastq_path = config["samples"][wildcards.sample]
        fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
        return fastq_files

# Figure out which samples are each enrichment's input sample
def get_control_sample(wildcards):
    control_label = config["controls"][wildcards.treatment]
    return expand("results/sorted_bam/{control}.bam", control = control_label)

# Check if fastq files are gzipped
fastq_paths = config["samples"]

is_gz = False

for p in fastq_paths.values():

    fastqs = sorted(glob.glob(f"{p}/*.fastq*"))
    test_gz = any(path.endswith('.fastq.gz') for path in fastqs)
    is_gz = any([is_gz, test_gz])

# Libtype string if using salmon
if config["PE"]:

    if config["strandedness"] == "reverse":

        LIBTYPE = config["directionality"] + "SR"
    
    if config["strandedness"] == "yes":

        LIBTYPE = config["directionality"] + "SF"
    
    if config["strandedness"] == "no"

        LIBTYPE = config["directionality"] + "U"

else:

    if config["strandedness"] == "reverse":

        LIBTYPE = "SR"
    
    if config["strandedness"] == "yes":

        LIBTYPE = "SF"
    
    if config["strandedness"] == "no"

        LIBTYPE = "U"

# Check whether or not decoys will be created
    # SALMON_DECOYS and SALMON_TRANSCRIPTOME are used as
    # input for Salmon index. Their values will determine
    # whether or not generateDecoyTranscriptome.sh will need
    # to be run.
if config["make_decoy_aware"]:

    SALMON_DECOYS="results/salmon_decoys/decoys.txt"
    SALMON_TRANSCRIPTOME="results/salmon_decoys/gentrome.fa"

else:

    SALMON_DECOYS=""
    SALMON_TRANSCRIPTOME=config["transcriptome"]