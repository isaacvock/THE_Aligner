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
        index=INDEX_KALLISTO
    output:
        dir=directory("results/kallisto_quant/{sample}"),
        run_info="results/kallisto_quant/{sample}/run_info.json"
    params:
        extra=config["kallisto_quant_params"],
    log:
        "logs/kallisto_quant/{sample}.log"
    conda:
        "../envs/kallisto.yaml"
    threads: 12
    script:
        "../scripts/kallisto-quant.py"
    