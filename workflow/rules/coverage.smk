# Generate coverage bedGraph file
rule genomecov:
    input:
        "results/sorted_bam/{sample}.bam",
    output:
        "results/genomecov/{sample}.bg",
    log:
        "logs/genomecov/{sample}.log",
    params:
        "-bg {}".format(str(config["genomecov_params"])),
    threads: 1
    wrapper:
        "v2.2.1/bio/bedtools/genomecov"


# Get chromosome sizes for bigWig creation
rule chrom_sizes:
    input:
        expand("results/sorted_bam/{sample_one}.bam", sample_one=SAMP_NAMES[1]),
    output:
        "results/genomecov/genome.chrom.sizes",
    log:
        "logs/chrom_sizes/chrom_sizes.log",
    conda:
        "../envs/chrom.yaml"
    params:
        shellscript=workflow.source_path("../scripts/chrom.sh"),
    threads: 1
    shell:
        """
        chmod +x {params.shellscript}
        {params.shellscript} {input} {output} 1> {log} 2>&1
        """


# Sort bedGraph for bigWig creation
rule sort_bg:
    input:
        "results/genomecov/{sample}.bg",
    output:
        "results/sort_bg/{sample}.bg",
    log:
        "logs/sort_bg/{sample}.log",
    threads: 1
    shell:
        "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output} 2> {log}"


# Make bigWig's from bedGraphs (compressed bedGraph)
rule bg2bw:
    input:
        bedGraph="results/sort_bg/{sample}.bg",
        chromsizes="results/genomecov/genome.chrom.sizes",
    output:
        "results/bigwig/{sample}.bw",
    params:
        config["bg2bw_params"],
    log:
        "logs/bg2bw/{sample}.log",
    threads: 1
    wrapper:
        "v2.2.1/bio/ucsc/bedGraphToBigWig"
