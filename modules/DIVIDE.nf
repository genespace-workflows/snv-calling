process DIVIDE {
    
    publishDir "${params.divide_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(vcf), path(tbi)

    output:
    tuple val(cohort), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: divided
    
    script:
    """
    set -euo pipefail
    bcftools query -l "$vcf" | while read -r SAMPLE; do

       bcftools view \
        -s "\${SAMPLE}" \
        -Oz \
        -o "\${SAMPLE}.vcf.gz" \
        "$vcf"

       tabix -p vcf "\${SAMPLE}.vcf.gz"
    done
    """
}