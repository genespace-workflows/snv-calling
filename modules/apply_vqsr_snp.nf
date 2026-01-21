process apply_vqsr_snp {
    
    publishDir "${params.apply_vqsr_snp_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_var_vcf), path(coh_var_tbi), path(snp_recal), path(snp_recal_idx), path(snp_tranches)
    path reference
    path refidx

    output:
    tuple val(cohort), path("${cohort}_vqsr_snp.vcf.gz"), path("${cohort}_vqsr_snp.vcf.gz.tbi"), emit: vqsr_snp
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" ApplyVQSR \
      -R $reference \
      -V $coh_var_vcf \
      -O ${cohort}_vqsr_snp.vcf.gz \
      --truth-sensitivity-filter-level 99.0 \
      --tranches-file $snp_tranches \
      --recal-file $snp_recal \
      -mode SNP \
      --create-output-variant-index true
    """
}