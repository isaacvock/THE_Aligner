rule make_transcriptome_fasta:
    input:
        fasta=config["genome"],
        annotation=config["annotation"],
        # ids=config["gffread_ids"],
        # nids=config["gffread_nids"],
        # seq_info=config["gffread_seq_info"],
        # sort_by=config["gffread_sort_by"],
        # attr=config["gffread_attr"],
        # chr_replace=config["gffread_chr_replace"]
    output:
        records=config["transcriptome"],
        #dupinfo=config["gffread_dupinfo"]
    threads: 1
    log:
        "logs/gffread.log",
    params:
        extra=config["gffread_extra"]
    wrapper:
        "v2.6.0/bio/gffread"