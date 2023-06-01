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
Usage: ./module2_orf_mg_traits.sh <options>
--help                          print this help
--input_file CHAR               input workable fasta file
--nslots NUM                    number of threads used (default 12)
--output_dir CHAR               directory to output generated data (i.e., preprocessed data, plots, tables)
--sample_name CHAR              sample name (default metagenomex)
--train_file_name               train file name to run FragGeneScan, see FragGeneScan help for options (default illumina_1)
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
#############
  --train_file_name)
  if [[ -n "${2}" ]]; then
    TRAIN_FILE_NAME="${2}"
    shift
  fi
  ;;
  --train_file_name=?*)
  TRAIN_FILE_NAME="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --train_file_name=) # Handle the empty case
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
  echo "mkdir ${OUTPUT_DIR} failed"
  exit 1
fi  

###############################################################################
# 5 Predict ORFs
###############################################################################

"${fraggenescan}" \
-s "${INPUT_FILE}" \
-a "${OUTPUT_DIR}/${SAMPLE_NAME}.faa" \
-n "${OUTPUT_DIR}/${SAMPLE_NAME}.ffn" \
-w 0 \
--unordered \
-p "${NSLOTS}" \
-t "${TRAIN_FILE_NAME}" \
-r "${FRAGGENESCAN_TRAIN_FILE_DIR}" 

if [[ $? -ne 0 ]]; then
  echo "${fraggenescan} failed"
  exit 1
fi  

###############################################################################
# 6. Run cusp
###############################################################################

"${cusp}" \
-sequence "${OUTPUT_DIR}/${SAMPLE_NAME}.ffn" \
-outfile "${OUTPUT_DIR}/${SAMPLE_NAME}.cusp" \
-sbegin1 1

if [[ $? -ne "0" ]]; then
  echo "${cusp} failed"
  exit 1
fi  

###############################################################################
# 7. Create codon freq table
###############################################################################

awk -v s="${SAMPLE_NAME}" '{
  if ($0 !~ /\#/ && $0 !~ "*" && $0 !~ /^$/){ 
    array[$1]=$5
    total = $5 + total
  }
} END { 

  for (c in array) { 
    prop = array[c]/total
    printf "%s\t%s\t%.10f\n", s,c,prop
  }

}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.cusp" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_codon_comp.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk formatting cusp file to codon comp failed"
  exit 1
fi  

###############################################################################
# 8. Create aa freq table
###############################################################################

awk -v s="${SAMPLE_NAME}" '{
  if ($0 !~ /\#/ && $0 !~ "*" && $0 !~ /^$/){ 
    array[$2] = $5 + array[$2]
    total = $5 + total
  }
} END { 

  for (c in array) { 
    prop = array[c]/total
    printf "%s\t%s\t%.10f\n", s,c,prop
  }

}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.cusp" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_aa_comp.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk formatting cusp file to aa comp failed"
  exit 1
fi  

###############################################################################
# 9. Compute acidic to basic ratio
###############################################################################

awk -v s="${SAMPLE_NAME}" '{
  if ($0 !~ /\#/ && $0 !~ "*" && $0 !~ /^$/){
  
    if ($2 == "D" || $2 == "E") {
      a = $3 + a
    }

    if ($2 == "H" || $2 == "R" || $2 == "K") {
      b = $3 + b
    }
  }
} END { 

 ratio_ab = a/b  
 printf "%s\t%s\t%.10f\n", s,"ratio_AB",ratio_ab 

}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}_aa_comp.tsv" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_orf_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk AB ratio computation failed"
  exit 1
fi  

###############################################################################
# 10. Compute ORF ratio
###############################################################################

NSEQ=$(egrep -c ">" "${INPUT_FILE}")
if [[ $? -ne "0" ]]; then
  echo "egrep nseq computation failed"
  exit 1
fi  

NORFS=$(egrep -c ">" "${OUTPUT_DIR}/${SAMPLE_NAME}.ffn")
if [[ $? -ne "0" ]]; then
  echo "egrep nORFs computation failed"
  exit 1
fi  

RATIO_ORFS=$(echo "${NORFS}/${NSEQ}" | bc -l)
if [[ $? -ne "0" ]]; then
  echo "egrep ORFs ratio computation failed"
  exit 1
fi  

echo -e "\
${SAMPLE_NAME}\tnseq\t${NSEQ}\n\
${SAMPLE_NAME}\tnORFs\t${NORFS}\n\
${SAMPLE_NAME}\tratio_ORFs\t${RATIO_ORFS}" >> \
"${OUTPUT_DIR}/${SAMPLE_NAME}_orf_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "writing ORFs stat output failed"
  exit 1
fi  
