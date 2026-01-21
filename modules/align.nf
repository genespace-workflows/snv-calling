process align {

    publishDir "${params.align_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(qc_file)
    path reference
    path refidx

    output:
    tuple val(sid), path("${sid}.sorted.bam"), emit: bam

    script:
    """
    set -euo pipefail
    bwa mem -t ${task.cpus} \
    -R "@RG\\tID:${sid}\\tSM:${sid}\\tPL:ILLUMINA\\tLB:lib1\\tPU:unit1" \
    -M $reference $qc_file | \
    samtools view -b | \
    samtools sort -o ${sid}.sorted.bam
    """
}
