include { run_fastp }         from './modules/fastp.nf'
include { align }             from './modules/align.nf'
include { dedup }             from './modules/dedup.nf'
include { bamqc }             from './modules/bamqc.nf'
include { bqsr }              from './modules/bqsr.nf'
include { apply_bqsr }        from './modules/apply_bqsr.nf'
include { haplotypecaller }   from './modules/haplotypecaller.nf'
include { combine }           from './modules/combine.nf'
include { genotype }          from './modules/genotype.nf'

include { vqsr_snp }          from './modules/vqsr_snp.nf'
include { vqsr_indels }       from './modules/vqsr_indels.nf'
include { apply_vqsr_snp }    from './modules/apply_vqsr_snp.nf'
include { apply_vqsr_indels } from './modules/apply_vqsr_indels.nf'
include { merge_vcf }         from './modules/merge_vcf.nf'
 
include { HARD1 }             from './modules/HARD1.nf'
include { HARD2 }             from './modules/HARD2.nf'
include { HARD3 }             from './modules/HARD3.nf'
include { HARD4 }             from './modules/HARD4.nf'

include { select }            from './modules/select.nf'
include { DIVIDE }            from './modules/DIVIDE.nf'
include { S_VARIANTQC }       from './modules/S_VARIANTQC.nf'
include { VARIANTQC }         from './modules/VARIANTQC.nf'
include { ANNOTATE }          from './modules/annotate.nf'
include { MULTIQC }           from './modules/MULTIQC.nf'



input_fastqs = Channel
    .fromPath("${params.input_dir}/*.{fastq,fq}*")
    .map { file ->
        def sid = file.getBaseName().replaceAll(/\.(fq|fastq)(\.gz)?$/, '')
        tuple(sid, file)
    }

reference = params.reference ? Channel.value( file(params.reference) ): Channel.empty()
refidx    = params.refidx ? Channel.fromPath("${params.refidx}/*.{amb,ann,bwt,pac,sa,fai,dict}", checkIfExists: true).collect(): Channel.empty()

targets = params.targets ? Channel.value( file(params.targets) ): Channel.empty()

dbsnp = params.dbsnp ? Channel.value( file(params.dbsnp) ): Channel.empty()
dbidx = params.dbidx ? Channel.fromPath("${params.dbidx}/*.tbi", checkIfExists: true).collect(): Channel.empty()

groups_ch = params.septable
    ? Channel
        .fromPath(params.septable)
        .splitCsv(header: true, sep: ';')
        .map { row -> tuple(row.sid, row.group) } 
    : Channel.empty()

hapmap   = params.hapmap ? Channel.value( file(params.hapmap) ): Channel.empty()
omni1000 = params.omni1000 ? Channel.value( file(params.omni1000) ): Channel.empty()
g1000    = params.g1000 ? Channel.value( file(params.g1000) ): Channel.empty()
mills    = params.mills ? Channel.value( file(params.mills) ): Channel.empty()

clinvar_gz     = params.vepcache ? Channel.fromPath("${params.vepcache}/clinvar.vcf.gz", checkIfExists: true).collect() : Channel.empty()
clinvar_gz_tbi = params.vepcache ? Channel.fromPath("${params.vepcache}/clinvar.vcf.gz.tbi", checkIfExists: true).collect() : Channel.empty()
vep_cache      = params.vepcache ? Channel.fromPath("${params.vepcache}").collect(): Channel.empty()

multiqc_config = params.multiqc_config ? Channel.value( file(params.multiqc_config) ): Channel.empty()


workflow {

    if (!(params.filter in ['vqsr', 'hard'])) {
        log.error "Invalid value for params.filter = '${params.filter}'. Allowed: 'vqsr', 'hard'."
        System.exit(1)
    }
    
    if (!(params.group in ['divided', 'united'])) {
        log.error "Invalid value for params.group = '${params.group}'. Allowed: 'divided', 'united'."
        System.exit(1)
    }
    
    run_fastp(input_fastqs)
    align(run_fastp.out.qc_ch, reference, refidx)
    dedup(align.out.bam)
    bamqc(dedup.out.bambai, targets)
    bqsr(dedup.out.bambai, reference, refidx, dbsnp, dbidx, targets)

      apply_bqsr_in = dedup.out.bambai
       .join(bqsr.out.bqsr_tab)
       .map { sid, bam, bai, tab -> tuple(sid, bam, bai, tab) }

    apply_bqsr(apply_bqsr_in, reference, refidx)
    haplotypecaller(apply_bqsr.out.rec_bambai, reference, refidx)

    if (params.group == 'united') {
    
        def cohort_id = 'cohort'
        
         gvcf_list   = haplotypecaller.out.g_vcf
          .map { sid, g, t -> tuple(cohort_id, g) }
          .groupTuple()
          
         tbi_list = haplotypecaller.out.g_vcf
          .map { sid, g, t -> tuple(cohort_id, t) }
          .groupTuple()
          
        cohort_in = gvcf_list
         .join(tbi_list)
         .map { coh, glist, tlist -> tuple(coh, glist, tlist) }
       
       combine(cohort_in, reference, refidx)
       
     }
     else if (params.group == 'divided') {
     
         gvcf_with_cohort = haplotypecaller.out.g_vcf
          .join(groups_ch)  
          .map { sid, gvcf, tbi, sep_cohort -> tuple(sep_cohort, gvcf, tbi) }
        
         cohorts_in = gvcf_with_cohort.groupTuple(by: 0)
           
         combine(cohorts_in, reference, refidx)
     }

    genotype(combine.out.cohort, reference, refidx)
    
    if (params.filter == 'vqsr') {
    
      vqsr_snp(genotype.out.variants, reference, refidx, hapmap, omni1000, g1000, dbsnp, dbidx)
      vqsr_indels(genotype.out.variants, reference, refidx, mills, dbsnp, dbidx)

        apply_vqsr_snp_in = genotype.out.variants
          .join(vqsr_snp.out.snp_model)
          .map { coh, vcf, tbi, recal, idx, tr, plots -> tuple(coh, vcf, tbi, recal, idx, tr) }
        apply_vqsr_indels_in = genotype.out.variants
          .join(vqsr_indels.out.indels_model)
          .map { coh, vcf, tbi, recal, idx, tr, plots -> tuple(coh, vcf, tbi, recal, idx, tr) }

      apply_vqsr_snp(apply_vqsr_snp_in, reference, refidx)
      apply_vqsr_indels(apply_vqsr_indels_in, reference, refidx)

        merge_in = apply_vqsr_snp.out.vqsr_snp
          .join(apply_vqsr_indels.out.vqsr_indel)
          .map { coh, snp, snp_tbi, indel, indel_tbi -> tuple(coh, snp, snp_tbi, indel, indel_tbi) }

      merge_vcf(merge_in)
      select(merge_vcf.out.merged_vcf, reference, refidx, targets)
      
      DIVIDE(select.out.passed)
      VARIANTQC(select.out.passed, reference, refidx, targets)
      ANNOTATE(select.out.passed, vep_cache, reference, refidx, clinvar_gz, clinvar_gz_tbi)
    } 
    else if (params.filter == 'hard') {
    
      HARD1(genotype.out.variants, reference, refidx)
      HARD2(HARD1.out.hard1, reference, refidx)
      HARD3(HARD2.out.hard2)
      HARD4(HARD3.out.hard3, reference, refidx, targets)
      
      DIVIDE(HARD4.out.hard_passed)
      VARIANTQC(HARD4.out.hard_passed, reference, refidx, targets)
      ANNOTATE(HARD4.out.hard_passed, vep_cache, reference, refidx, clinvar_gz, clinvar_gz_tbi)
    }


     if (params.group == 'united') {
      
      sample_vcfs = DIVIDE.out.divided
         .flatMap { cohort, vcfs, tbis ->
            vcfs.indexed().collect { idx, vcf ->
              def tbi    = tbis[idx]
              def sample = vcf.simpleName
              tuple(sample, vcf, tbi)
              }
          }


    S_VARIANTQC(sample_vcfs, reference, refidx, targets)

      all_qc = run_fastp.out.fastp_html
              .mix(run_fastp.out.fastp_json)
              .mix(bamqc.out.bamqc)
              .mix(S_VARIANTQC.out.s_vcf_stats)
              .mix(VARIANTQC.out.vcf_stats)
              .mix(ANNOTATE.out.html)
              .collect()
              
   }
   else if (params.group == 'divided') {
   
      all_qc = run_fastp.out.fastp_html
              .mix(run_fastp.out.fastp_json)
              .mix(bamqc.out.bamqc)
              .mix(VARIANTQC.out.vcf_stats)
              .mix(ANNOTATE.out.html)
              .collect()
   }

    MULTIQC(all_qc, multiqc_config)
}