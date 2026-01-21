process dedup {
    
    publishDir "${params.dedup_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(bam)

    output:
    tuple val(sid), path("${sid}.deduped.bam"), path("${sid}.deduped.bai"), emit: bambai
    path("${sid}_dedup_metrics.txt")

    script:
    """
    java -jar /usr/picard/picard.jar MarkDuplicates \
    I=${bam} \
    O=${sid}.deduped.bam \
    M=${sid}_dedup_metrics.txt \
    REMOVE_DUPLICATES=true \
    CREATE_INDEX=true
    """
}
