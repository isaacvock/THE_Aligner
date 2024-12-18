# Generate coverage bedGraph file
rule genomecov:
    input:
        "results/sorted_bam/{sample}.bam",
    output:
        "results/genomecov/{sample}.bedGraph",
    log:
        "logs/genomecov/{sample}.log",
    params:
        "-bga {}".format(str(config["genomecov_params"])),
    threads: 1
    wrapper:
        "v2.2.1/bio/bedtools/genomecov"


# Get chromosome sizes for bigWig creation
rule chrom_sizes:
    input:
        expand("results/sorted_bam/{sample_one}.bam", sample_one=SAMP_NAMES[0]),
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


# Create tdf files
rule make_tdf:
    input:
        bg="results/genomecov/{sample}.bedGraph",
        cs="results/genomecov/genome.chrom.sizes",
    output:
        "results/TDFs/{sample}.tdf",
    conda:
        "../envs/igv.yaml"
    log:
        "logs/make_tdf/{sample}.log",
    shell:
        """
        igvtools toTDF -f mean,max {input.bg} {output} {input.cs} 1> {log} 2>&1
        """


# # Sort bedGraph for bigWig creation
# rule sort_bg:
#     input:
#         "results/genomecov/{sample}.bedGraph",
#     output:
#         "results/sort_bg/{sample}.bedGraph",
#     log:
#         "logs/sort_bg/{sample}.log",
#     threads: 1
#     shell:
#         "LC_COLLATE=C sort -k1,1 -k2,2n {input} > {output} 2> {log}"


# # Make bigWig's from bedGraphs (compressed bedGraph)
# rule bg2bw:
#     input:
#         bedGraph="results/sort_bg/{sample}.bedGraph",
#         chromsizes="results/genomecov/genome.chrom.sizes",
#     output:
#         "results/bigwig/{sample}.bw",
#     params:
#         extra=config["bg2bw_params"],
#     log:
#         "logs/bg2bw/{sample}.log",
#     threads: 1
#     wrapper:
#         "v2.2.1/bio/ucsc/bedGraphToBigWig"


# Index bam files for deeptools
rule index_bam:
    input:
        "results/sorted_bam/{sample}.bam",
    output:
        "results/sorted_bam/{sample}.bam.bai",
    log:
        "logs/index_bam/{sample}.log",
    params:
        extra=config["samtools_index_params"],
    threads: 8
    wrapper:
        "v3.3.6/bio/samtools/index"


# Make bigWig using deeptools
rule deeptools_bamcoverage:
    input:
        bam="results/sorted_bam/{sample}.bam",
        bai="results/sorted_bam/{sample}.bam.bai",
    output:
        "results/bigwig/{sample}.bw",
    params:
        extra=config["deeptools_bamcoverage_params"],
    log:
        "logs/deeptools_bamcoverage/{sample}.log",
    threads: 8
    conda:
        "../envs/deeptools.yaml"
    script:
        "../scripts/deeptools.py"
