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
Usage: ././module3_fun_mg_traits.sh <options>
--help                          print this help
--num_genes NUM                 total number of orf ffn (or faa) sequences
--input_file CHAR               input workable fasta file
--nslots NUM                    number of threads used (default 12)
--output_dir CHAR               directory to output generated data (i.e., preprocessed data, plots, tables)
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
  --num_genes)
  if [[ -n "${2}" ]]; then
    NUM_GENES="${2}"
    shift
  fi
  ;;
  --num_genes=?*)
  NUM_GENES="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --num_genes=) # Handle the empty case
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
# 5. Annotate pfam
###############################################################################

"${uproc_prot}" \
--output "${OUTPUT_DIR}/${SAMPLE_NAME}.uout" \
--threads "${NSLOTS}" \
--preds \
--pthresh 3 \
"${PFAM_DB}" "${PFAM_MODEL_DIR}" "${INPUT_FILE}"

if [[ $? -ne "0" ]]; then
  echo "${uproc_prot} failed"
  exit 1
fi  

###############################################################################
# 6. Format pfam annotation
###############################################################################

awk -v s="${SAMPLE_NAME}" -v OFS="\t" -v FS="," '{ 

  array_annot[$4] = array_annot[$4] + 1

} END {
  for (i in array_annot) { 
    print s,i,array_annot[i]
  }
}' "${OUTPUT_DIR}/${SAMPLE_NAME}.uout" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_fun_annot.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk format pfam annotation failed"
  exit 1
fi  

###############################################################################
# 7. Compute funtional diversity
###############################################################################

awk -v s="${SAMPLE_NAME}" -v OFS="\t" -v FS="\t" '{ 

  total_abund = total_abund + $3
  array_abund[$2] = $3
  richness++
  
} END {
  for (i in array_abund) {
    p_i = array_abund[i]/total_abund
    shannon = -((p_i)*log(p_i)) + shannon
  }
  print s,"shannon",shannon
  print s,"richness",richness
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_fun_annot.tsv" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_fun_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk compute funtional diversity failed"
  exit 1
fi  

###############################################################################
# 8. Compute percentage of annotated reads
###############################################################################

awk -v s="${SAMPLE_NAME}" -v FS="\t" -v OFS="\t" -v n="${NUM_GENES}" '{
  total = $3 +total 
} END {
  perc_annot = 100*total/n
  print s,"perc_annot", perc_annot
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_fun_annot.tsv" >> \
"${OUTPUT_DIR}/${SAMPLE_NAME}_fun_stats.tsv"
            
if [[ $? -ne "0" ]]; then
  echo "awk compute percentage of annotated reads failed"
  exit 1
fi  

###############################################################################
# 9. Compute percentage of transcription factors
###############################################################################

awk -v s="${SAMPLE_NAME}" -v FS="\t" -v OFS="\t" '{

  if (NR == FNR) {
    array_annot[$2] = $3
    total = total + $3
    next
  }
  
  if (array_annot[$1] != "" ) { 
    tf_count = array_annot[$1] + tf_count
  }
  
} END {
  perc_tf = 100*tf_count/total
  print s,"perc_tf",perc_tf 
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_fun_annot.tsv" \
   "${TRANSFACT_ACC}" >> \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_fun_stats.tsv"
            
if [[ $? -ne "0" ]]; then
  echo "awk compute percentage of transcription factors failed"
  exit 1
fi
