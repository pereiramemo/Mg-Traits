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
Usage: ./module7_caz_mg_traits.sh <options>
--help                          print this help
--caz_subfam_annot t|f          annotate CAZyme subfamilies
--input_file CHAR               input workable fasta file
--evalue_caz_fam NUM            evalue to annotate CAZyme families with hmmsearch
--evalue_caz_subfam NUM         evalue to annotate CAZyme subfamilies with hmmsearch
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
  --caz_subfam_annot)
  if [[ -n "${2}" ]]; then
    CAZ_SUBFAM_ANNOT="${2}"
    shift
  fi
  ;;
  --caz_subfam_annot=?*)
  CAZ_SUBFAM_ANNOT="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --caz_subfam_annot=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --evalue_caz_fam)
  if [[ -n "${2}" ]]; then
    EVALUE_CAZ_FAM="${2}"
    shift
  fi
  ;;
  --evalue_caz_fam=?*)
  EVALUE_CAZ_FAM="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_caz_fam=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;     
#############
  --evalue_caz_subfam)
  if [[ -n "${2}" ]]; then
    EVALUE_CAZ_SUBFAM="${2}"
    shift
  fi
  ;;
  --evalue_caz_subfam=?*)
  EVALUE_CAZ_SUBFAM="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_caz_subfam=) # Handle the empty case
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
# 5. Annotate cazymes: family level
###############################################################################

"${hmmsearch}" \
--domtblout ${OUTPUT_DIR}/"${SAMPLE_NAME}_caz_fam.domtblout" \
--noali \
-E 1 \
--cpu "${NSLOTS}" \
"${CAZ_HMM}" "${INPUT_FILE}" > ${OUTPUT_DIR}/"${SAMPLE_NAME}_caz_fam.hout"

if [[ $? -ne "0" ]]; then
  echo "${hmmsearch} (family level) failed"
  exit 1
fi  

###############################################################################
# 6. Format cazyme annotation: family level
###############################################################################

awk -v s="${SAMPLE_NAME}" -v  e="${EVALUE_CAZ_FAM}" -v OFS="\t" '{ 

  if ($0 !~ /^#/ && $13 <= e) {
    query=gensub(".hmm","","g",$4)
    array_annot[query]++
  }
    
} END {
  for (i in array_annot) { 
    print s,i,array_annot[i]
  }
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam.domtblout" > \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam_annot.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk format cazyme (family level) annotation failed"
  exit 1
fi  
   
# note: the independent evalue is used to select significant domains   
   
###############################################################################
# 7. Compute cazyme diversity: family level
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
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam_annot.tsv" > \
"${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam_stats.tsv"

if [[ $? -ne "0" ]]; then
  echo "awk compute cazyme (family level) diversity failed"
  exit 1
fi  

###############################################################################
# 8. Compute percentage of annotated reads: family level
###############################################################################

awk -v s="${SAMPLE_NAME}" -v FS="\t" -v OFS="\t" -v n="${NUM_GENES}" '{

  total = $3 +total 
  
} END {

  perc_annot = 100*total/n
  print s,"perc_annot", perc_annot
  
}' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam_annot.tsv" >> \
   "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_fam_stats.tsv"
            
if [[ $? -ne "0" ]]; then
  echo "awk compute percentage of annotated reads (family level) failed"
  exit 1
fi  

###############################################################################
# 5. Annotate cazymes: subfamily level
###############################################################################

if [[ "${CAZ_SUBFAM_ANNOT}" == "t" ]]; then

  "${hmmsearch}" \
  --domtblout ${OUTPUT_DIR}/"${SAMPLE_NAME}_caz_sub.domtblout" \
  --noali \
  -E 1 \
  --cpu "${NSLOTS}" \
  "${CAZSUB_HMM}" "${INPUT_FILE}" > ${OUTPUT_DIR}/"${SAMPLE_NAME}_caz_sub.hout"

  if [[ $? -ne "0" ]]; then
    echo "${hmmsearch} (subfamily level) failed"
    exit 1
  fi  

  #############################################################################
  # 6. Format cazyme annotation: subfamily level
  #############################################################################

  awk -v s="${SAMPLE_NAME}" -v  e="${EVALUE_CAZ_SUBFAM}" -v OFS="\t" '{ 

    if ($0 !~ /^#/ && $13 <= e) {
      query=gensub(".hmm","","g",$4)
      array_annot[query]++
    }
    
  } END {
    for (i in array_annot) { 
      print s,i,array_annot[i]
    }
  }' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub.domtblout" > \
     "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub_annot.tsv"

  if [[ $? -ne "0" ]]; then
    echo "awk format cazyme (subfamily level) annotation failed"
    exit 1
  fi  
   
  # note: the independent evalue is used to select significant domains   
   
  #############################################################################
  # 7. Compute cazyme diversity: subfamily level
  #############################################################################

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
  }' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub_annot.tsv" > \
     "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub_stats.tsv"

  if [[ $? -ne "0" ]]; then
    echo "awk compute cazyme (subfamily level) diversity failed"
    exit 1
  fi  

  #############################################################################
  # 8. Compute percentage of annotated reads: subfamily level
  #############################################################################

  awk -v s="${SAMPLE_NAME}" -v FS="\t" -v OFS="\t" -v n="${NUM_GENES}" '{

    total = $3 +total 
  
  } END {

    perc_annot = 100*total/n
    print s,"perc_annot", perc_annot
  
  }' "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub_annot.tsv" >> \
     "${OUTPUT_DIR}/${SAMPLE_NAME}_caz_sub_stats.tsv"
             
  if [[ $? -ne "0" ]]; then
    echo "awk compute percentage of annotated reads (subfamily level) failed"
    exit 1
  fi  

fi