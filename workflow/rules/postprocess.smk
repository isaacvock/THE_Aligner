# Sort bam files
rule sort:
    input:
        "results/align/{sample}.bam",
    output:
        "results/sorted_bam/{sample}.bam",
    log:
        "logs/sort/{sample}.log",
    params:
        extra=config["samtools_params"],
    threads: 8
    wrapper:
        "v2.6.0/bio/samtools/sort"


# Get alignment stats
rule alignment_stats:
    input:
        "results/align/{sample}.bam",
    output:
        "results/alignment_stats/{sample}.bamstats",
    log:
        "logs/alignment_stats/{sample}.log",
    params:
        extra=config["bamtools_params"],  # optional params string
    threads: 1
    wrapper:
        "v2.6.0/bio/bamtools/stats"
