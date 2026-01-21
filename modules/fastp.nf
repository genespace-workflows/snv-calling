process run_fastp {

    publishDir "${params.fastp_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(read)

    output:
    tuple val(sid), path("qc_${sid}.fq.gz"), emit: qc_ch
    path ("report_${sid}.html"), emit: fastp_html
    path ("report_${sid}.json"), emit: fastp_json

    script:
    """
    fastp \
      --stdout \
      -i $read \
      --html report_${sid}.html \
      --json report_${sid}.json \
    | gzip -c > qc_${sid}.fq.gz
    """
}
