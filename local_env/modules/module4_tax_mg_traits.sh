###############################################################################
### 1. Set env
###############################################################################

set -o pipefail 
source "${HOME}/workspace/repositories/tools/metagenomic_pipelines/mg_traits/conf.sh"

###############################################################################
# 2. Define help
###############################################################################

show_usage(){
  cat <<EOF
Usage: ./module4_tax_mg_traits.sh <options>
--help                          print this help
--confidence NUM                confidence value to run rdp bayes classifier (from 0 to 1; default 0.5)
--evalue NUM                    e-value used to filter rRNA seqs
--input_file CHAR               SortMeRNA output fasta file
--input_smrna CHAR              SortMeRNA blast format file
--min_length NUM                minimum length of sequences to be used for clustering
--nslots NUM                    number of threads used (default 12)
--output_dir CHAR               directory to output generated data (i.e., preprocessed data, plots, tables)
--ref_db CHAR                   refernce database to run NBC (default silva_nr99_v138_train_set.fa.gz) 
--sample_name CHAR              sample name (default metagenomex)
EOF
}

###############################################################################
# 3. Parse input parameters
###############################################################################

while :; do
  case "${1}" in
    --help) # Call a "show_help" function to display a synopsis, then exit.
    show_usage
    exit 1;
    ;;
#############
  --confidence)
  if [[ -n "${2}" ]]; then
    CONFIDENCE="${2}"
    shift
  fi
  ;;
  --confidence=?*)
  CONFIDENCE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --confidence=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;          
#############
  --evalue)
  if [[ -n "${2}" ]]; then
    EVALUE="${2}"
    shift
  fi
  ;;
  --evalue=?*)
  EVALUE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;      
#############
  --input_file)
  if [[ -n "${2}" ]]; then
    INPUT_FILE="${2}"
    shift
  fi
  ;;
  --input_file=?*)
  INPUT_FILE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_file=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  --input_smrna)
  if [[ -n "${2}" ]]; then
    INPUT_SMRNA="${2}"
    shift
  fi
  ;;
  --input_smrna=?*)
  INPUT_SMRNA="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --input_smrna=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --min_length)
  if [[ -n "${2}" ]]; then
    MIN_LENGTH="${2}"
    shift
  fi
  ;;
  --min_length=?*)
  MIN_LENGTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --min_length=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  --nslots)
  if [[ -n "${2}" ]]; then
    NSLOTS="${2}"
    shift
  fi
  ;;
  --nslots=?*)
  NSLOTS="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --nslots=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --output_dir)
  if [[ -n "${2}" ]]; then
    OUTPUT_DIR="${2}"
    shift
  fi
  ;;
  --output_dir=?*)
  OUTPUT_DIR="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --output_dir=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --ref_db)
  if [[ -n "${2}" ]]; then
    REF_DB="${2}"
    shift
  fi
  ;;
  --ref_db=?*)
  REF_DB="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --ref_db=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
#############
  --sample_name)
  if [[ -n "${2}" ]]; then
    SAMPLE_NAME="${2}"
    shift
  fi
  ;;
  --sample_name=?*)
  SAMPLE_NAME="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --sample_name=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;  
############ End of all options.
  --)       
  shift
  break
  ;;
  -?*)
  printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
  ;;
  *) # Default case: If no more options, then break out of the loop.
  break
  esac
  shift
done  

###############################################################################
# 4. Create outpt directory
###############################################################################

mkdir "${OUTPUT_DIR}"
if [[ $? -ne 0 ]]; then
  echo "mkdir ${OUTPUT_DIR}"
  exit 1
fi

###############################################################################
# 5. Get 16S rRNA seq coords
###############################################################################

awk -v OFS="\t" -v eval_thres="${EVALUE}" '{

  seq_id = $1
  seq_start = $7 
  seq_end = $8
  eval = $11
  
  seq_length = seq_end - seq_start +1
  
  if (eval <= eval_thres) { 
    print seq_id, seq_start -1, seq_end
  } 
}' "${INPUT_SMRNA}" > "${OUTPUT_DIR}/${SAMPLE_NAME}.bed" 

if [[ $? -ne "0" ]]; then
  echo "awk get 16S rRNA seq coords failed"
  exit 1
fi  

###############################################################################
# 6. Extract seqs
###############################################################################

"${seqtk}" subseq \
"${INPUT_FILE}" \
"${OUTPUT_DIR}/${SAMPLE_NAME}.bed" > "${OUTPUT_DIR}/${SAMPLE_NAME}_subseq.fasta"

if [[ $? -ne "0" ]]; then
  echo "${seqtk} extract seqs failed"
  exit 1
fi  

###############################################################################
# 7. Cluster 16S rRNA seqs
###############################################################################

"${vsearch}" \
--cluster_fast "${OUTPUT_DIR}/${SAMPLE_NAME}_subseq.fasta" \
--id 0.97 \
--sizeout \
--sizeorder \
--minseqlength "${MIN_LENGTH}" \
--centroids "${OUTPUT_DIR}/${SAMPLE_NAME}_centroids.fasta" \
--uc "${OUTPUT_DIR}/${SAMPLE_NAME}.uclust" \
--threads "${NSLOTS}"  

if [[ $? -ne "0" ]]; then
  echo "${svsearch} clustering seqs failed"
  exit 1
fi  

###############################################################################
# 8. Perform taxonomic annotation
###############################################################################

"${r_script}" --vanilla \
"${taxa_annot}" \
"${OUTPUT_DIR}/${SAMPLE_NAME}_centroids.fasta" \
"${OUTPUT_DIR}/${SAMPLE_NAME}_taxa_annot_tmp.tsv" \
"${REF_DB}" \
"${CONFIDENCE}" \
"${NSLOTS}"

if [[ $? -ne "0" ]]; then
  echo "${taxa_annot} failed"
  exit 1
fi  

###############################################################################
# 9. Format taxa annot output
###############################################################################

awk -v FS="\t" -v OFS="\t" -v s="${SAMPLE_NAME}" '{ 

  if (NR == 1) {
   print "sample","otu_id","abund","domain","phylum","class","order","family","genus"
  } else {  
    sub(";size=","\t",$1)
    print s,$0
  }
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_taxa_annot_tmp.tsv" > \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_sample2otu2abund2taxa.tsv"
 
if [[ $? -ne "0" ]]; then
  echo "awk formatting taxa annot output failed"
  exit 1
fi  

###############################################################################
# 9. Compute diversity
###############################################################################

awk -v s="${SAMPLE_NAME}" -v FS="\t" -v OFS="\t" '{ 
  if ($1 == "C") {
    
    centroid = $9
    abund = $3
    array_abund[centroid] = abund
    total_abund = total_abund + abund
    richness++
    
    if (abund == 1) {
      singletons++
    }
    
    if (abund > 1) {
      total_abund_nosig = total_abund_nosig + abund
      richness_nosig++
    }
    
  }
} END {
  
  for (i in array_abund) {
  
    if (array_abund[i] > 1) {
      p_i = array_abund[i]/total_abund_nosig
      shannon_nosig = -(p_i*log(p_i)) + shannon_nosig
    }
    
    p_i = array_abund[i]/total_abund
    shannon = -(p_i*log(p_i)) + shannon
  }
  
  print s,"shannon", shannon
  print s, "shannon_nosig", shannon_nosig
  print s,"richness", richness
  print s, "richness_nosig", richness_nosig
  
}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.uclust" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_div.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk diversity computation failed"
  exit 1
fi  

###############################################################################
# 10. Clean
###############################################################################

rm "${OUTPUT_DIR}/${SAMPLE_NAME}.bed"
rm "${OUTPUT_DIR}/${SAMPLE_NAME}_taxa_annot_tmp.tsv"
