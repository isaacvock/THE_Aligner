# Index
rule index:
    input:
        ref=config["genome"],
    output:
        multiext(
            "{}/genome".format(INDEX_PATH),
            ".1.bt{}".format(INDEX_SUFFIX),
            ".2.bt{}".format(INDEX_SUFFIX),
            ".3.bt{}".format(INDEX_SUFFIX),
            ".4.bt{}".format(INDEX_SUFFIX),
            ".rev.1.bt{}".format(INDEX_SUFFIX),
            ".rev.2.bt{}".format(INDEX_SUFFIX),
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
        sample=expand("results/trimmed/{{sample}}.{read}.fastq", read=READS),
        idx=multiext(
            "{}/genome".format(INDEX_PATH),
            ".1.bt{}".format(INDEX_SUFFIX),
            ".2.bt{}".format(INDEX_SUFFIX),
            ".3.bt{}".format(INDEX_SUFFIX),
            ".4.bt{}".format(INDEX_SUFFIX),
            ".rev.1.bt{}".format(INDEX_SUFFIX),
            ".rev.2.bt{}".format(INDEX_SUFFIX),
        ),
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}_bowtie2.log",
    params:
        extra=config["bowtie2_align_params"],
    threads: 20
    wrapper:
        "v2.6.0/bio/bowtie2/align"
