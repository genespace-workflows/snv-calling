process genotype {
    
    publishDir "${params.genotype_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_gvcf), path(coh_tbi)
    path reference
    path refidx

    output:
    tuple val(cohort), path("${cohort}_var.vcf.gz"), path("${cohort}_var.vcf.gz.tbi"), emit: variants
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" GenotypeGVCFs \
      -R $reference \
      -V $coh_gvcf \
      -O ${cohort}_var.vcf.gz
    """
}