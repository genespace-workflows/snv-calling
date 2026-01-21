process VARIANTQC {
    
    publishDir "${params.var_qc_output_dir}", mode: 'link'
    tag "$cohort"

    input:
    tuple val(cohort), path(vcf), path(tbi)
    path ref
    path refidx
    path targets

    output:
    path("${cohort}.vcf.stats"), emit: vcf_stats

    script:
    """
    bcftools stats -F $ref -R $targets -s - --threads ${task.cpus} $vcf > ${cohort}.vcf.stats
    """
}
