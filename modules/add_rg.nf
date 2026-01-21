process add_rg {
    container = 'broadinstitute/picard:latest'
    publishDir "${params.add_rg_output_dir}"

    input:
    tuple val(sid), path(bam)

    output:
    tuple val(sid), path("${sid}.rg.bam"), emit: rgbam

    script:
    """
    set -euo pipefail
    java -jar /usr/picard/picard.jar AddOrReplaceReadGroups \
    I=${bam} \
    O=${sid}.rg.bam \
    RGID=${sid} \
    RGLB=lib1 \
    RGPL=ILLUMINA \
    RGPU=unit1 \
    RGSM=${sid} \
    TMP_DIR="${PWD}"
    """
}
