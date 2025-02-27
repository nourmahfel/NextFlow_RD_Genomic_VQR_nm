/*
 * Run Trimmomatic on the read fastq files
 */
process TRIMMOMATIC {
    tag "$sample_id"
    label 'process_medium'

    conda "bioconda::trimmomatic=0.39"
    container "quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_1.fastq.gz"), emit: trimmed_reads_R1
    tuple val(sample_id), path("${sample_id}_2.fastq.gz"), emit: trimmed_reads_R2
    tuple val(sample_id), path("${sample_id}_1_unpaired.fastq.gz"), emit: unpaired_reads_R1, optional: true
    tuple val(sample_id), path("${sample_id}_2_unpaired.fastq.gz"), emit: unpaired_reads_R2, optional: true
    path "versions.yml", emit: versions

    publishDir "results/trimmomatic", mode: "copy"

    script:
    """
    trimmomatic PE -threads $task.cpus -phred33 \
        ${reads[0]} ${reads[1]} \
        ${sample_id}_1.fastq.gz ${sample_id}_2.fastq.gz \
        ${sample_id}_1_unpaired.fastq.gz ${sample_id}_2_unpaired.fastq.gz \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$(echo \$(trimmomatic -version 2>&1) | sed 's/^.*://' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*\$//')
    END_VERSIONS
    """
}
