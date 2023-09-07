rule index:
    input:
        fasta=config["transcriptome"],
    output:
        index=INDEX_KALLISTO,
    params:
        extra=config["kallisto_index_params"]
    log:
        "logs/kallisto_index/kallisto_index.log"
    threads: 8
    wrapper:
        "v2.6.0/bio/kallisto/index"

rule quant:
    input:
        fastq=expand("results/trimmed/{{sample}}.{read}.fastq", read = READS),
        index=config["index"]
    output:
        directory("results/kallisto_quant/{sample}")
    params:
        extra=config["kallisto_quant_params"],
    log:
        "logs/kallisto_quant/{sample}.log"
    threads: 12
    wrapper:
        "v2.6.0/bio/kallisto/quant"
    