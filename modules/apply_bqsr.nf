process apply_bqsr {
    
    publishDir "${params.apply_bqsr_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(bam), path(bai), path(bqsr_tab)
    path reference
    path refidx

    output:
    tuple val(sid), path("${sid}_rec.bam"), path("${sid}_rec.bai"),  emit: rec_bambai
    
    script:
    """
    gatk ApplyBQSR \
      -I $bam \
      -R $reference \
      --bqsr-recal-file $bqsr_tab \
      -O ${sid}_rec.bam
    """
}
