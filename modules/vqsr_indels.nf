process vqsr_indels {
    
    publishDir "${params.vqsr_indels_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_var_vcf), path(coh_var_tbi)
    path reference
    path refidx
    path mills
    path dbsnp
    path dbidx

    output:
    tuple val(cohort),
          path("${cohort}_indels.recal"),
          path("${cohort}_indels.recal.idx"),
          path("${cohort}_indels.tranches"),
          path("${cohort}_indels.plots.R"),
          emit: indels_model
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" VariantRecalibrator \
      -R $reference \
      -V $coh_var_vcf \
      --trust-all-polymorphic \
      --resource:mills,known=false,training=true,truth=true,prior=12.0 $mills \
      --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $dbsnp \
      -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
      -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
      -mode INDEL \
      --max-gaussians 4 \
      -O ${cohort}_indels.recal \
      --tranches-file ${cohort}_indels.tranches \
      --rscript-file ${cohort}_indels.plots.R \
      --create-output-variant-index true
    """
}