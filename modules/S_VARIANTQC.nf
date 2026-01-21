process S_VARIANTQC {
    
    publishDir "${params.s_var_qc_output_dir}", mode: 'link'
    tag "$sample"

    input:
    tuple val(sample), path(vcf), path(tbi)
    path ref
    path refidx
    path targets

    output:
    path("${sample}.vcf.stats"), emit: s_vcf_stats

    script:
    """
    bcftools stats -F $ref -R $targets -s - --threads ${task.cpus} $vcf > ${sample}.vcf.stats
    """
}
