process HARD4 {
    
    publishDir "${params.hard4_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(vcf), path(tbi)
    path ref
    path refidx
    path targets

    output:
    tuple val(cohort), path("${cohort}_hard_passed.vcf.gz"), path("${cohort}_hard_passed.vcf.gz.tbi"), emit: hard_passed
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" SelectVariants \
      -R $ref \
      -V $vcf \
      --exclude-filtered \
      --intervals $targets \
      -O "${cohort}_hard_passed.vcf.gz"
    """
}