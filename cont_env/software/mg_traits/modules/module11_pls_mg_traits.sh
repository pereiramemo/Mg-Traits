###############################################################################
### 1. Set env
###############################################################################

set -o pipefail 
source "/bioinfo/software/mg_traits/conf.sh"

###############################################################################
# 2. Define help
###############################################################################

show_usage(){
  cat <<EOF
Usage: ./module11_pls_mg_traits.sh <options>
--help                          print this help
--input_file CHAR               input workable fasta file
--evalue NUM                    sequences e-value in hmmsearch
--num_genes NUM                 total number of orf ffn (or faa) sequences
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
# 5. Annotate Plastic DB
###############################################################################

"${diamond}" blastp \
--query "${INPUT_FILE}" \
--db "${PLASTIC_DB}" \
--evalue 1 \
--mid-sensitive \
--threads "${NSLOTS}" \
--outfmt 6 \
--out ${OUTPUT_DIR}/"${SAMPLE_NAME}.blout"

if [[ $? -ne "0" ]]; then
  echo "${diamond} failed"
  exit 1
fi  

###############################################################################
# 6. Format pls annotation
###############################################################################

awk -v s="${SAMPLE_NAME}" -v  e="${EVALUE}" -v OFS="\t" '{ 

  if ($13 <= e) {
    split($2,seq_id,"|")
    array_annot[seq_id[3]]++
  }
    
} END {
  for (i in array_annot) { 
    print s,i,array_annot[i]
  }
}' "${OUTPUT_DIR}/${SAMPLE_NAME}.blout" > \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_pls_annot.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk format pls annotation failed"
  exit 1
fi  

# note: the independent evalue is used to select significant domains   
   
###############################################################################
# 7. Compute pls diversity
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
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_pls_annot.tsv" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_pls_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk compute pls diversity failed"
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
  
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_pls_annot.tsv" >> \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_pls_stats.tsv"
            
if [[ $? -ne "0" ]]; then
  echo "awk compute percentage of annotated reads failed"
  exit 1
fi  
