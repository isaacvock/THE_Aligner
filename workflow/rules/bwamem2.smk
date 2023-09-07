# Index
rule index:
    input:
        config["genome"],
    output:
        multiext(
            "{}/genome".format(INDEX_PATH), 
            ".amb", 
            ".ann", 
            ".bwt.2bit.64", 
            ".pac"),
    log:
        "logs/index/index.log",
    wrapper:
        "v2.2.1/bio/bwa-mem2/index"

# Align
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
        # Index can be a list of (all) files created by bwa, or one of them
        idx=multiext(
            "{}/genome".format(INDEX_PATH), 
            ".amb", 
            ".ann", 
            ".bwt.2bit.64", 
            ".pac"),
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}.log",
    params:
        extra=config["bwamem2_align_params"],
        sort=config["bwamem2_sort"],  # Can be 'none', 'samtools' or 'picard'.
        sort_order=config["bwamem2_sort_order"],  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra=config["bwamem2_sort_extra"],  # Extra args for samtools/picard.
    threads: 20
    wrapper:
        "v2.2.1/bio/bwa-mem2/mem"
