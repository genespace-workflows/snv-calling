process haplotypecaller {
    
    publishDir "${params.haplotypecaller_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(rec_bam), path(rec_bai)
    path reference
    path refidx

    output:
    tuple val(sid), path("${sid}.g.vcf.gz"), path("${sid}.g.vcf.gz.tbi"), emit: g_vcf
    
    script:

    def memG = task.memory.giga
    def threads = task.cpus

    """
    set -euo pipefail
    gatk --java-options "-Xmx${memG}G" HaplotypeCaller \
      -R $reference \
      -I $rec_bam \
      -O ${sid}.g.vcf.gz \
      --native-pair-hmm-threads ${threads} \
      -ERC GVCF
    """
}