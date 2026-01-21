process HARD3 {
    
    publishDir "${params.hard3_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(filt_snp_vcf), path(filt_snp_tbi), path(filt_indel_vcf), path(filt_indel_tbi)

    output:
    tuple val(cohort), path("${cohort}_hard_merged.vcf.gz"), path("${cohort}_hard_merged.vcf.gz.tbi"), emit: hard3
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options -Xmx${memG}G MergeVcfs \
      I=$filt_snp_vcf \
      I=$filt_indel_vcf \
      O="${cohort}_hard_merged.vcf.gz" \
      CREATE_INDEX=true
    """
}