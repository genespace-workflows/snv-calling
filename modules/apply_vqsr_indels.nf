process apply_vqsr_indels {
   
    publishDir "${params.apply_vqsr_indels_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_var_vcf), path(coh_var_tbi), path(ind_recal), path(ind_recal_idx), path(ind_tranches)
    path reference
    path refidx

    output:
    tuple val(cohort), path("${cohort}_vqsr_indel.vcf.gz"), path("${cohort}_vqsr_indel.vcf.gz.tbi"), emit: vqsr_indel
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" ApplyVQSR \
      -R $reference \
      -V $coh_var_vcf \
      -O "${cohort}_vqsr_indel.vcf.gz" \
      --truth-sensitivity-filter-level 99.0 \
      --tranches-file $ind_tranches \
      --recal-file $ind_recal \
      -mode INDEL \
      --create-output-variant-index true
    """
}