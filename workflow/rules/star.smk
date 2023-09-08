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
        sj="results/align/{sample}-SJ.out.tab",
        log="results/align/{sample}-Log.out",
        log_progress="results/align/{sample}-Log.progress.out",
        log_final="results/align/{sample}-Log.final.out",
    log:
        "logs/align/{sample}.log",
    params:
        aln_tx=lambda wc: "TranscriptomeSAM" in config["star_align_params"],
        reads_per_gene=lambda wc: "GeneCounts" in config["star_align_params"],
        chim_junc=lambda wc: "--chimOutType Junctions" in config["star_align_params"],
        idx=lambda wc, input: input.index,
        extra="{} {}".format(
            SJ_DB_GTF, config["star_align_params"]
        ),
        out_reads_per_gene="results/align/{sample}-ReadsPerGene.out.tab",
        out_chim_junc="results/align/{sample}-Chimeric.out.junction",
        out_aln_tx="results/align/{sample}-Aligned.toTranscriptome.out.bam"
    conda:
        "../envs/star.yaml"
    threads: 24
    script: 
        "../scripts/star-align.py"
