# Index
rule index:
    input:
        config["genome"],
    output:
        multiext("{}/genome".format(INDEX_PATH), ".amb", ".ann", ".bwt.2bit.64", ".pac"),
    log:
        "logs/index/bwamem2_index.log",
    wrapper:
        "v3.14.0/bio/bwa-mem2/index"


# Align
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read=READS),
        # Index can be a list of (all) files created by bwa, or one of them
        idx=multiext(
            "{}/genome".format(INDEX_PATH), ".amb", ".ann", ".bwt.2bit.64", ".pac"
        ),
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}_bwamem2.log",
    params:
        extra=config["bwamem2_align_params"],
        sort=config["bwamem2_sort"],  # Can be 'none', 'samtools' or 'picard'.
        sort_order=config["bwamem2_sort_order"],  # Can be 'coordinate' (default) or 'queryname'.
        sort_extra=config["bwamem2_sort_extra"],  # Extra args for samtools/picard.
    threads: 20
    conda:
        "../envs/bwamem2.yaml"
    script:
        "../scripts/bwamem2.py"
