import glob
import os


### GENERAL HELPER FUNCTIONS/VARIABLES USED IN ALL CASES

# Sample names to help expanding lists of all bam files
# and to aid in defining wildcards
if config["download_fastqs"]:
    SAMP_NAMES = config["sra_accessions"]
else:
    SAMP_NAMES = list(config["samples"].keys())

# Directory containing index; used in case of certain aligners
INDEX_DIR = config["indices"]

# Determine how many fastqs to look for
if config["PE"]:
    READS = [1, 2]
    READ_NAMES = ["r1", "r2"]
else:
    READS = [1]
    READ_NAMES = ["r1"]


# Get input fastq files for first step
def get_input_fastqs(wildcards):
    if config["download_fastqs"]:
        if config["PE"]:
            SRA_READS = ["_1.fastq", "_2.fastq"]

        else:
            SRA_READS = [".fastq"]

        return expand(
            "results/download_fastq/{SAMPLE}{READ}",
            SAMPLE=wildcards.sample,
            READ=SRA_READS,
        )

    else:
        fastq_path = config["samples"][wildcards.sample]
        fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
        return fastq_files


if not config["download_fastqs"]:
    # Check if fastq files are gzipped
    fastq_paths = config["samples"]

    is_gz = False

    for p in fastq_paths.values():
        fastqs = sorted(glob.glob(f"{p}/*.fastq*"))
        test_gz = any(path.endswith(".fastq.gz") for path in fastqs)
        is_gz = any([is_gz, test_gz])


### FASTQC HELPERS


def get_fastqc_read(wildcards):
    if config["skip_trimming"]:
        if is_gz:
            return expand(
                "results/unzipped/{SID}.{READ}.fastq",
                SID=wildcards.sample,
                READ=wildcards.read,
            )

        else:
            fastq_path = config["samples"][wildcards.sample]
            fastq_files = sorted(glob.glob(f"{fastq_path}/*.fastq*"))
            readID = int(wildcards.read)
            return fastq_files[readID]

    else:
        return expand(
            "results/trimmed/{SID}.{READ}.fastq",
            SID=wildcards.sample,
            READ=wildcards.read,
        )


### KALLISTO HELPERS

# Path to index for kallisto
INDEX_KALLISTO = os.path.join(INDEX_DIR, "transcriptome.idx")


### STAR AND SALMON HELPERS

# Trimmed fastq file paths, used as input for aligners


def get_fastq_r1(wildcards):
    return expand("results/trimmed/{SID}.1.fastq", SID=wildcards.sample)


def get_fastq_r2(wildcards):
    if config["PE"]:
        return expand("results/trimmed/{SID}.2.fastq", SID=wildcards.sample)

    else:
        return ""


### BOWTIE2 HELPERS

# Bowtie2 has two different alignment index suffixes, so gotta figure out which will apply
if config["aligner"] == "bowtie2":
    if "large-index" in config["bowtie2_build_params"]:
        INDEX_SUFFIX = "21"
    else:
        INDEX_SUFFIX = "2"


### BOWTIE AND BWA-MEM2 HELPERS

# Make life easier for users and catch if they add a '/' at the end of their path
# to alignment indices. If so, remove it to avoid double '/'
if config["indices"].endswith("/"):
    INDEX_PATH = str(config["indices"])
    INDEX_PATH = INDEX_PATH[:-1]
else:
    INDEX_PATH = str(config["indices"])


### SALMON HELPERS

# Libtype string if using salmon
if config["PE"]:
    if config["strandedness"] == "reverse":
        LIBTYPE = config["directionality"] + "SR"

    if config["strandedness"] == "yes":
        LIBTYPE = config["directionality"] + "SF"

    if config["strandedness"] == "no":
        LIBTYPE = config["directionality"] + "U"

else:
    if config["strandedness"] == "reverse":
        LIBTYPE = "SR"

    if config["strandedness"] == "yes":
        LIBTYPE = "SF"

    if config["strandedness"] == "no":
        LIBTYPE = "U"

# Check whether or not decoys will be created
# SALMON_DECOYS and SALMON_TRANSCRIPTOME are used as
# input for Salmon index. Their values will determine
# whether or not generateDecoyTranscriptome.sh will need
# to be run.
if config["decoy_settings"]["make_decoy"]:
    SALMON_DECOYS = "results/salmon_decoys/decoys.txt"
    SALMON_TRANSCRIPTOME = "results/salmon_decoys/gentrome.fa"

else:
    SALMON_DECOYS = ""
    SALMON_TRANSCRIPTOME = config["transcriptome"]


### STAR HELPERS

# Use GTF for indexing to identify splice junctions
if config["annotation"]:
    SJ_DB_GTF = "--sjdbGTFfile {}".format(str(config["annotation"]))

else:
    SJ_DB_GTF = ""


### HISAT2 HELPERS

# Figure out what to pass to --rna-strandedness
if config["strandedness"] == "no":
    HISAT2_STRANDEDNESS = ""

elif config["strandedness"] == "reverse":
    if config["PE"]:
        HISAT2_STRANDEDNESS = "--rna-strandness RF"

    else:
        HISAT2_STRANDEDNESS = "--rna-strandness R"


else:
    if config["PE"]:
        HISAT2_STRANDEDNESS = "--rna-strandness FR"

    else:
        HISAT2_STRANDEDNESS = "--rna-strandness F"


# Index base name
if config["hisat2_index_base"]:
    HISAT2_BASE = "{}/{}".format(INDEX_PATH, config["hisat2_index_base"])

else:
    HISAT2_BASE = "{}/{}".format(INDEX_PATH, "hisat2_index")


### MINIMAP2 HELPERS

minimap2_index = "{}/{}.mmi".format(INDEX_PATH, config["minimap2_index_name"])


if config["minimap2_use_annotation"]:
    MINIMAP2_ALIGN_PARAMS = "{} {} {}".format(
        config["minimap2_align_params"], "--juncbed", config["minimap2_bedgraph"]
    )

else:
    MINIMAP2_ALIGN_PARAMS = config["minimap2_align_params"]
