rule index:
    input:
        target=config["genome"],
    output:
        minimap2_index,
    log:
        "logs/index/minimap2.log",
    params:
        extra=config["minimap2_index_params"],
    threads: 20
    wrapper:
        "v3.14.0/bio/minimap2/index"


rule gtf_to_bedgraph:
    input:
        config["annotation"],
    output:
        config["minimap2_bedgraph"],
    log:
        "logs/gtf_to_bedgraph/gtf_to_bedgraph.log",
    threads: 20
    params:
        config["minimap2_gtf2bed_params"],
    conda:
        "../envs/minimap2.yaml"
    shell:
        """
        paftools.js gff2bed {params} {input} > {output}
        """


if config["minimap2_use_annotation"]:

    rule align:
        input:
            target=minimap2_index,
            query=get_input_fastqs,
            bed=config["minimap2_bedgraph"],
        output:
            "results/align/{sample}.bam",
        log:
            "logs/align/minimap2_{sample}.log",
        params:
            extra=MINIMAP2_ALIGN_PARAMS,
            sorting=config["minimap2_sorting"],
            sort_extra=config["minimap2_sorting_params"],
        threads: 20
        wrapper:
            "v3.14.0/bio/minimap2/aligner"

else:

    rule align:
        input:
            target=minimap2_index,
            query=get_input_fastqs,
        output:
            "results/align/{sample}.bam",
        log:
            "logs/align/minimap2_{sample}.log",
        params:
            extra=MINIMAP2_ALIGN_PARAMS,
            sorting=config["minimap2_sorting"],
            sort_extra=config["minimap2_sorting_params"],
        threads: 20
        wrapper:
            "v3.14.0/bio/minimap2/aligner"
