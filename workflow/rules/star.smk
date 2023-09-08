rule index:
    input:
        fasta=config["genome"],
        gtf=config["annotation"],
    output:
        directory(config['indices']),
    threads: 12
    params:
        extra=config["star_index_params"],
    log:
        "logs/star_index_genome.log",
    wrapper:
        "v2.6.0/bio/star/index"


rule align:
    input:
        fq1 = get_fastq_r1,
        fq2 = get_fastq_r2,
        index = config['indices'],
    output:
        aln="results/align/{sample}.bam",
        reads_per_gene=READS_PER_GENE,
        chim_junc=CHIM_JUNC,
        sj="results/align/{sample}-SJ.out.tab",
        log="results/align/{sample}-Log.out",
        log_progress="results/align/{sample}-Log.progress.out",
        log_final="results/align/{sample}-Log.final.out",
        aln_tx=ALN_TX
    log:
        "logs/bams/{sample}.log",
    params:
        idx=lambda wc, input: input.index,
        extra="{} {}".format(
            SJ_DB_GTF, config["star_align_params"]
        ),
    conda:
        "../envs/star.yaml"
    threads: 24
    script: 
        "../scripts/star-align.py"
