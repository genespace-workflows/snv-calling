process MULTIQC {
    
    publishDir "${params.multiqc_output_dir}", mode: 'copy'

    input:
    path all_qc
    path config

    output:
    path '*.html', emit: html

    script:
    """
    multiqc $all_qc -c $config
    """
}