process HARD1 {
    
    publishDir "${params.hard1_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_var_vcf), path(coh_var_tbi)
    path ref
    path refidx

    output:
    tuple val(cohort), path("${cohort}.snps.vcf.gz"), path("${cohort}.snps.vcf.gz.tbi"), path("${cohort}.indels.vcf.gz"), path("${cohort}.indels.vcf.gz.tbi"), emit: hard1
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" SelectVariants \
      -R $ref \
      -V $coh_var_vcf \
      -select-type SNP \
      -O ${cohort}.snps.vcf.gz

    gatk --java-options "-Xmx${memG}G" SelectVariants \
      -R $ref \
      -V $coh_var_vcf \
      -select-type INDEL \
      -O ${cohort}.indels.vcf.gz
    """
}
    