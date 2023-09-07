rule index:
    input:
        sequences=config["transcriptome"]
    output:
        multiext(
            config["index"],
            "complete_ref_lens.bin",
            "ctable.bin",
            "ctg_offsets.bin",
            "duplicate_clusters.tsv",
            "info.json",
            "mphf.bin",
            "pos.bin",
            "pre_indexing.log",
            "rank.bin",
            "refAccumLengths.bin",
            "ref_indexing.log",
            "reflengths.bin",
            "refseq.bin",
            "seq.bin",
            "versionInfo.json",
        ),
    log:
        "logs/index/salmon_index.log"
    threads: 10
    params:
        extra=config["salmon_index_params"]
    wrapper:
        "v2.6.0/bio/salmon/index"



if config["PE"]:

    rule quant:
        input:
            r1=get_input_r1,
            r2=get_input_r2,
            index=config["index"]
        output:
            quant="results/quant/{sample}/quant.sf",
            lib="results/quant/{sample}/lib_format_counts.json"
        log:
            "logs/quant/{sample}.log"
        params:
            libtype=LIBTYPE
            extra=config["salmon_quant_params"]
        threads: 10
        wrapper:
            "v2.6.0/bio/salmon/quant"

else:

    rule quant:
        input:
            r=get_input_r,
            index=config["index"]
        output:
            quant="results/quant/{sample}/quant.sf",
            lib="results/quant/{sample}/lib_format_counts.json"
        log:
            "logs/quant/{sample}.log"
        params:
            libtype=LIBTYPE
            extra=config["salmon_quant_params"]
        threads: 10
        wrapper:
            "v2.6.0/bio/salmon/quant"

