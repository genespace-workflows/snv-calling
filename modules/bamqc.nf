process bamqc {
    
    publishDir "${params.bamqc_output_dir}", mode: 'link'
    tag "$sid"

    input:
    tuple val(sid), path(bam), path(bai)
    path(targets)

    output:
    path("${sid}"), emit: bamqc
    
    script:
    """
    qualimap bamqc -bam $bam \
    -outdir ${sid} \
    -gff $targets \
    -outformat HTML \
    -nt ${task.cpus} \
    --java-mem-size=8G
    """
}
