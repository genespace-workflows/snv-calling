process vqsr_snp {
    
    publishDir "${params.vqsr_snp_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(coh_var_vcf), path(coh_var_tbi)
    path reference
    path refidx
    path hapmap
    path omni1000
    path g1000
    path dbsnp
    path dbidx

    output:
    tuple val(cohort),
          path("${cohort}_snp.recal"),
          path("${cohort}_snp.recal.idx"),
          path("${cohort}_snp.tranches"),
          path("${cohort}_snp.plots.R"),
          emit: snp_model
    
    script:

    def memG = task.memory.giga

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" VariantRecalibrator \
      -R $reference \
      -V $coh_var_vcf \
      --trust-all-polymorphic \
      --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmap \
      --resource:omni,known=false,training=true,truth=false,prior=12.0 $omni1000 \
      --resource:1000G,known=false,training=true,truth=false,prior=10.0 $g1000 \
      --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $dbsnp \
      -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
      -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
      -mode SNP \
      --max-gaussians 6 \
      -O ${cohort}_snp.recal \
      --tranches-file ${cohort}_snp.tranches \
      --rscript-file ${cohort}_snp.plots.R \
      --create-output-variant-index true
    """
}