
# Build hisat2 index
rule index:
    input:
        fasta=conifg["genome"],
    output:
        directory

# Running hisat2 with Snakemake wrapper
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
        idx=config["index"],
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}.log",
    params:
        extra=config["hisat2_align_params"],
    threads: 20
    wrapper:
        "v2.6.0/bio/hisat2/align"