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
Usage: ./module1_nuc_mg_traits.sh <options>
--help                          print this help
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
  echo "mkdir ${OUTPUT_DIR} failed"
  exit 1
fi  

###############################################################################
# 5. Compute GC content
###############################################################################

"${infoseq}" \
-sequence "${INPUT_FILE}" \
-outfile "${OUTPUT_DIR}/${SAMPLE_NAME}.info"

if [[ $? -ne "0" ]]; then
  echo "${infoseq} failed"
  exit 1
fi  

###############################################################################
# 6. Compute GC mean
###############################################################################

awk -v s="${SAMPLE_NAME}" 'BEGIN {n=0} {
  if (NR >1) {
    gc_total = $7 + gc_total;
    n++
  }
} END {
  mean_gc =  gc_total/n
  printf "%s\t%s\t%.3f\n", s,"mean_GC", mean_gc
}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.info" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_gc_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk gc mean computation failed"
  exit 1
fi  

###############################################################################
# 7. Compute GC variance
###############################################################################

GC_MEAN=$(cut -f3 "${OUTPUT_DIR}/${SAMPLE_NAME}_gc_stats.tsv")

awk -v s="${SAMPLE_NAME}" -v gc_mean="${GC_MEAN}" 'BEGIN {n=1} {
  if (NR >1) {
    sqrt_sum_gc=($7 - gc_mean)^2 + sqrt_sum_gc
    n++
  }  
} END { 
  variance_gc = sqrt_sum_gc/n
  printf "%s\t%s\t%.3f\n", s,"variance_GC", variance_gc
}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.info" >> \
"${OUTPUT_DIR}/${SAMPLE_NAME}_gc_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk gc variance computation failed"
  exit 1
fi  

###############################################################################
# 8. Run compseq
###############################################################################

"${compseq}" \
-sequence "${INPUT_FILE}" \
-outfile "${OUTPUT_DIR}/${SAMPLE_NAME}.compseq" \
-word 4

if [[ $? -ne "0" ]]; then
  echo "${compseq} failed"
  exit 1
fi  

###############################################################################
# 9. Create tetra nuc freq table
###############################################################################

awk -v s="${SAMPLE_NAME}" '{
  if ($0 ~ /^[A,C,T,G]{4}\t/){ 
    array[$1]=$2
    total = $2 + total
  }
} END { 

  for (c in array) { 
    prop = array[c]/total
    printf "%s\t%s\t%.10f\n", s,c,prop
  }

}' \
"${OUTPUT_DIR}/${SAMPLE_NAME}.compseq" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_nuc_comp"

if [[ $? -ne "0" ]]; then
  echo "awk formatting compseq file to nuc comp failed"
  exit 1
fi  
