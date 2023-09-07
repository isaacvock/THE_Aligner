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
        fq1 = get_fastq_r1,
        fq2 = get_fastq_r2,
        index = config['STAR_index'],
    output:
        aln="results/align/{sample}.bam",
        reads_per_gene=get_reads_per_gene,
        chim_junc=get_chim_junc,
        sj="results/align/{sample}-SJ.out.tab",
        log="results/align/{sample}-Log.out",
        log_progress="results/align/{sample}-Log.progress.out",
        log_final="results/align/{sample}-Log.final.out",
        aln_tx=get_aln_tx
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
