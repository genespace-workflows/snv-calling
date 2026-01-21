process HARD2 {
    
    publishDir "${params.hard2_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(snp_vcf), path(snp_tbi), path(indel_vcf), path(indel_tbi)
    path ref
    path refidx

    output:
    tuple val(cohort), path("${cohort}.snps.filt.vcf.gz"), path("${cohort}.snps.filt.vcf.gz.tbi"), path("${cohort}.indels.filt.vcf.gz"), path("${cohort}.indels.filt.vcf.gz.tbi"), emit: hard2
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" VariantFiltration \
      -R $ref \
      -V $snp_vcf \
      --filter-expression "QD < 2.0" --filter-name "QD_lt_2" \
      --filter-expression "FS > 60.0" --filter-name "FS_gt_60" \
      --filter-expression "MQ < 40.0" --filter-name "MQ_lt_40" \
      --filter-expression "MQRankSum < -12.5" --filter-name "MQRS_lt_n12.5" \
      --filter-expression "ReadPosRankSum < -8.0" --filter-name "RPRS_lt_n8" \
      --filter-expression "SOR > 3.0" --filter-name "SOR_gt_3" \
      -O ${cohort}.snps.filt.vcf.gz

    gatk --java-options "-Xmx${memG}G" VariantFiltration \
      -R $ref \
      -V $indel_vcf \
      --filter-expression "QD < 2.0" --filter-name "QD_lt_2" \
      --filter-expression "FS > 200.0" --filter-name "FS_gt_200" \
      --filter-expression "ReadPosRankSum < -20.0" --filter-name "RPRS_lt_n20" \
      --filter-expression "SOR > 10.0" --filter-name "SOR_gt_10" \
      -O ${cohort}.indels.filt.vcf.gz
    """
}