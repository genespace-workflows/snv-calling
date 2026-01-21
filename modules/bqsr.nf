process bqsr {
    
    publishDir "${params.bqsr_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(bam), path(bai)
    path reference
    path refidx
    path dbsnp
    path dbidx
    path targets

    output:
    tuple val(sid), path("${sid}_recal_data.table"), emit: bqsr_tab
    
    script:
    """
    gatk BaseRecalibrator \
      -I $bam \
      -R $reference \
      -L $targets \
      --known-sites $dbsnp \
      -O ${sid}_recal_data.table
    """
}
