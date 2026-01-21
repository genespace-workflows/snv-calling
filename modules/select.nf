process select {
    
    publishDir "${params.select_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(vcf), path(tbi)
    path ref
    path refidx
    path targets

    output:
    tuple val(cohort), path("${cohort}_passed.vcf.gz"), path("${cohort}_passed.vcf.gz.tbi"), emit: passed
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" SelectVariants \
      -R $ref \
      -V $vcf \
      --exclude-filtered \
      --exclude-non-variants \
      --remove-unused-alternates \
      --intervals $targets \
      -O "${cohort}_passed.vcf.gz"
    """
}