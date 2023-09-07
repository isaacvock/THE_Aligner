rule index:
    input:
        fasta=config["genome"],
        annotation=config["annotation"],
    output:
        directory(config['index']),
    threads: 12
    params:
        extra="--sjdbGTFfile {gtf} {extra}".format(gtf = str(config["annotation"]), extra = config["star_index_params"]),
    log:
        "logs/star_index_genome.log",
    wrapper:
        "v1.25.0/bio/star/index"


rule align:
    input:
        fq1 = FASTQ_R1,
        fq2 = FASTQ_R2,
        index = config['STAR_index'],
    output:
        aln="results/bams/{sample}Aligned.out.bam",
        reads_per_gene="results/bams/{sample}-ReadsPerGene.out.tab",
        aln_tx="results/bams/{sample}-Aligned.toTranscriptome.out.bam",
    log:
        "logs/bams/{sample}.log",
    params:
        idx=lambda wc, input: input.index,
        extra="--sjdbGTFfile {} {}".format(
            str(config["annotation"]), config["star_align_params"]
        ),
    conda:
        "../envs/star.yaml"
    threads: 24
    script: 
        "../scripts/star-align.py"
