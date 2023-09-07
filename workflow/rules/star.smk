rule index:
    input:
        fasta=config["genome"],
        annotation=config["annotation"],
    output:
        directory(config['index']),
    threads: 12
    params:
        extra="--sjdbGTFfile {} --sjdbOverhang 100".format(str(config["annotation"])),
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
        extra="--outSAMtype BAM SortedByCoordinate --outSAMattributes NH HI AS NM MD --quantMode TranscriptomeSAM GeneCounts --sjdbGTFfile {} {}".format(
            str(config["annotation"]), config["star_extra"]
        ),
    conda:
        "../envs/star.yaml"
    threads: 24
    script: 
        "../scripts/star-align.py"
