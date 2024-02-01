rule make_transcriptome_fasta:
    input:
        fasta=config["genome"],
        annotation=config["annotation"],
    output:
        records=config["transcriptome"],
    threads: 1
    log:
        "logs/make_transcriptome_fasta/gffread.log",
    params:
        extra=config["gffread_extra"],
    conda:
        "../envs/gffread.yaml"
    script:
        "../scripts/gffread.py"
