if config["annotation"]:

    rule get_exons:
        input:
            annotation=config["annotation"],
        output:
            "results/get_exons/exons.exon",
        log:
            "logs/get_exons/exons.log",
        conda:
            "../envs/hisat2.yaml"
        threads: 1
        shell:
            "hisat2_extract_exons.py {input.annotation} 1> {output} 2> {log}"

    rule get_ss:
        input:
            annotation=config["annotation"],
        output:
            "results/get_ss/splice_sites.ss",
        log:
            "logs/get_ss/ss.log",
        conda:
            "../envs/hisat2.yaml"
        threads: 1
        shell:
            "hisat2_extract_splice_sites.py {input.annotation} 1> {output} 2> {log}"

    rule index:
        input:
            fasta=config["genome"],
            annotation=config["annotation"],
            ss="results/get_ss/splice_sites.ss",
            exons="results/get_exons/exons.exon",
        output:
            directory(config["indices"]),
        params:
            prefix=HISAT2_BASE,
            extra="{} {}".format(
                "--ss results/get_ss/splice_sites.ss --exon results/get_exons/exons.exon",
                config["hisat2_index_params"],
            ),
        log:
            "logs/index/hisat2_index.log",
        threads: 20
        wrapper:
            "v2.6.0/bio/hisat2/index"

else:

    # Build hisat2 index
    rule index:
        input:
            fasta=config["genome"],
            annotation=config["annotation"],
            ss="results/get_ss/splice_sites.ss",
            exons="results/get_exon/exons.exon",
        output:
            directory(config["indices"]),
        params:
            prefix=HISAT2_BASE,
            extra=config["hisat2_index_params"],
        log:
            "logs/index/hisat2_index.log",
        threads: 20
        wrapper:
            "v2.6.0/bio/hisat2/index"


# Running hisat2 with Snakemake wrapper
rule align:
    input:
        reads=expand("results/trimmed/{{sample}}.{read}.fastq", read=READS),
        idx=config["indices"],
    output:
        "results/align/{sample}.bam",
    log:
        "logs/align/{sample}_hisat2.log",
    params:
        extra="{} {}".format(HISAT2_STRANDEDNESS, config["hisat2_align_params"]),
    threads: 20
    wrapper:
        "v2.6.0/bio/hisat2/align"
