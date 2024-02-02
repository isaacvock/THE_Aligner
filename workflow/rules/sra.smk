if config["PE"]:

    rule download_fastq:
        output:
            "results/download_fastq/{accession}_1.fastq",
            "results/download_fastq/{accession}_2.fastq",
        params:
            extra=config["fasterq_dump_extras"],
        threads: 12
        wrapper:
            "v3.3.6/bio/sra-tools/fasterq-dump"
    

else:

    rule download_fastq:
        output:
            "results/download_fastq/{accession}.fastq",
        params:
            extra=config["fasterq_dump_extras"],
        threads: 12
        wrapper:
            "v3.3.6/bio/sra-tools/fasterq-dump"
        
