# Index
rule index:
    input:
        ref=config["genome"],
    output:
        multiext(
            "{}/genome".format(INDEX_PATH), 
            expand(".1.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".2.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".3.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".4.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
        ),
    log:
        "logs/index/bowtie2_index.log",
    params:
        extra=config["bowtie2_build_params"],  # optional parameters
    threads: 10
    wrapper:
        "v2.5.0/bio/bowtie2/build"


# Align
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
        idx=multiext(
            "{}/genome".format(INDEX_PATH), 
            expand(".1.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".2.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".3.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".4.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
            expand(".rev.1.bt{suffix}", suffix = INDEX_SUFFIX),
        ),
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}_bowtie2.log",
    params:
        extra=config["bowtie2_align_params"],
    threads: 20
    wrapper:
        "v2.2.1/bio/bwa-mem2/mem"