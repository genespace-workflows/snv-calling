process ANNOTATE {
    
    publishDir "${params.annotate_output_dir}", pattern: "*.vcf.gz", mode: 'copy'
    publishDir "${params.annotate_output_dir}", pattern: "*.html", mode: 'link'
    tag "$coh"

    input:
    tuple val(coh), path(vcf), path(tbi)
    path vep_cache
    path reference
    path refidx
    path clinvar_gz
    path clinvar_tbi

    output:
    path "${coh}_vep.vcf.gz", emit: vep
    path "${coh}_vep.html", emit: html

    script:
    """
    vep \
    --vcf \
    -i $vcf \
    -o ${coh}_vep.vcf.gz \
    --compress_output bgzip \
    --stats_file ${coh}_vep.html \
    --fork ${task.cpus} \
    --cache \
    --dir_cache ${vep_cache} \
    --everything \
    --species homo_sapiens \
    --custom file=${clinvar_gz},short_name=ClinVar,format=vcf,type=exact,coords=0,fields=CLNSIG%CLNREVSTAT%CLNDN \
    --offline \
    --assembly GRCh38
    """
}