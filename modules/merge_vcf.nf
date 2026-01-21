process merge_vcf {
    
    publishDir "${params.merge_vcf_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(snp), path(snp_tbi), path(indel), path(indel_tbi)

    output:
    tuple val(cohort), path("${cohort}_merged.vcf.gz"), path("${cohort}_merged.vcf.gz.tbi"), emit: merged_vcf
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options -Xmx${memG}G MergeVcfs \
      I=$snp \
      I=$indel \
      O="${cohort}_merged.vcf.gz" \
      CREATE_INDEX=true
    """
}