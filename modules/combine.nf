process combine {
    
    publishDir "${params.combine_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(gvcfs), path(tbis)
    path reference
    path refidx

    output:
    tuple val(cohort), path("${cohort}.g.vcf.gz"), path("${cohort}.g.vcf.gz.tbi"), emit: cohort
    
    script:

    def memG = task.memory.giga

    def variants = gvcfs.collect { f -> "-V ${f}" }.join(' ')

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" CombineGVCFs \
    -R $reference \
    $variants \
    -O ${cohort}.g.vcf.gz
    """
}
