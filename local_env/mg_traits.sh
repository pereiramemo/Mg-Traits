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
Usage: ./mg_traits_lite.sh <options>
--help                          print this help
--clean t|f                     remove all intermediate files
--confidence NUM                confidence value to run rdp bayes classifier (from 0 to 100; default 50)
--evalue_acn NUM                evalue to filter reads for for AGS computaton (default 1e-15)
--evalue_div NUM                evalue to filter reads for diversity estimation (default 1e-15)
--evalue_res NUM                hmmsearch evalue to annotate ResFam hmms (default 1e-15)
--evalue_caz NUM                hmmsearch evalue to annotate CAZyme hmms (default 1e-15)
--input_file CHAR               input workable fasta file
--nslots NUM                    number of threads used (default 12)
--max_length NUM                maximum read length used to trim reads (from the 3' end) for AGS computaton (default 180)
--min_length NUM                minimum read length used to estimate taxonomic diversity (default 100)
--output_dir CHAR               directory to output generated data (i.e., preprocessed data, plots, tables)
--overwrite t|f                 overwrite previous directory (default f)
--ref_db CHAR                   refernce database to run NBC (default silva_nr99_v138_train_set.fa.gz) 
--sample_name CHAR              sample name (default metagenomex)
--train_file_name CHAR          train file name to run FragGeneScan, see FragGeneScan help for options (default illumina_5)  
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
  --clean)
  if [[ -n "${2}" ]]; then
    CLEAN="${2}"
    shift
  fi
  ;;
  --clean=?*)
  CLEAN="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --clean=) # Handle the empty case
  printf 'Using default environment.\n' >&2
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
  --evalue_acn)
  if [[ -n "${2}" ]]; then
    EVALUE_ACN="${2}"
    shift
  fi
  ;;
  --evalue_acn=?*)
  EVALUE_ACN="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_acn=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;    
#############
  --evalue_div)
  if [[ -n "${2}" ]]; then
    EVALUE_DIV="${2}"
    shift
  fi
  ;;
  --evalue_div=?*)
  EVALUE_DIV="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_div=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --evalue_res)
  if [[ -n "${2}" ]]; then
    EVALUE_RES="${2}"
    shift
  fi
  ;;
  --evalue_res=?*)
  EVALUE_RES="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_res=) # Handle the empty case
  printf 'Using default environment.\n' >&2
  ;;
#############
  --evalue_caz)
  if [[ -n "${2}" ]]; then
    EVALUE_CAZ="${2}"
    shift
  fi
  ;;
  --evalue_caz=?*)
  EVALUE_CAZ="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --evalue_caz=) # Handle the empty case
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
  --max_length)
  if [[ -n "${2}" ]]; then
    MAX_LENGTH="${2}"
    shift
  fi
  ;;
  --max_length=?*)
  MAX_LENGTH="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --max_length=) # Handle the empty case
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
  --overwrite)
  if [[ -n "${2}" ]]; then
    OVERWRITE="${2}"
    shift
  fi
  ;;
  --overwrite=?*)
  OVERWRITE="${1#*=}" # Delete everything up to "=" and assign the remainder.
  ;;
  --overwrite=) # Handle the empty case
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
### 4. Check mandatory parameters
###############################################################################

if [[ -z "${OUTPUT_DIR}" ]]; then
  echo "missing output dir"
  exit 1
fi

if [[ ! -a "${INPUT_FILE}"  ]]; then
  echo "missing input file"
  exit 1
fi

###############################################################################
### 5. Define defaults
###############################################################################

if [[ -z "${CLEAN}" ]]; then
  CLEAN="f"
fi

if [[ -z "${CONFIDENCE}" ]]; then
  CONFIDENCE="50"
fi  

if [[ -z "${EVALUE_ACN}" ]]; then
  EVALUE_ACN="1e-15"
fi

if [[ -z "${EVALUE_DIV}" ]]; then
  EVALUE_DIV="1e-15"
fi

if [[ -z "${EVALUE_RES}" ]]; then
  EVALUE_RES="1e-15"
fi

if [[ -z "${EVALUE_CAZ}" ]]; then
  EVALUE_CAZ="1e-15"
fi

if [[ -z "${NSLOTS}" ]]; then
  NSLOTS=12
fi  

if [[ -z "${MAX_LENGTH}" ]]; then
  MAX_LENGTH="180"
fi

if [[ -z "${MIN_LENGTH}" ]]; then
  MIN_LENGTH="100"
fi

if [[ -z "${OVERWRITE}" ]]; then
  OVERWRITE="f"
fi

if [[ -z "${REF_DB}" ]]; then
  REF_DB="${MG_TRAITS_RESOURCES}/silva_nr99_v138_train_set.fa.gz"
fi
  
if [[ -z "${SAMPLE_NAME}" ]]; then
  SAMPLE_NAME="metagenomex"
fi  

if [[ -z "${TRAIN_FILE_NAME}" ]]; then
  TRAIN_FILE_NAME="illumina_5"
fi

###############################################################################
### 6. Create output dir
###############################################################################

if [[ "${OVERWRITE}" == "t" ]]; then

  if [[ -d "${OUTPUT_DIR}" ]]; then
    rm -r "${OUTPUT_DIR}"
  fi
   mkdir -p "${OUTPUT_DIR}"
  
fi

if [[ "${OVERWRITE}" == "f" ]]; then

  if [[ -d "${OUTPUT_DIR}" ]]; then
    echo "${OUTPUT_DIR} already exists"
    exit 1
  else
    mkdir -p "${OUTPUT_DIR}"
  fi
  
fi      

###############################################################################
### 7. Module 1: Compute simple mg_traits
###############################################################################

echo -e "\ncomputing nucleotide mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module1_nuc_mg_traits.sh" \
--input_file "${INPUT_FILE}" \
--output_dir "${OUTPUT_DIR}/nuc" \
--sample_name "${SAMPLE_NAME}"

if [[ $? -ne 0 ]]; then
  echo "module1_nuc_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 8. Module 2: compute ORF mg_traits
###############################################################################

echo -e "\ncomputing orf mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module2_orf_mg_traits.sh" \
--input_file "${INPUT_FILE}" \
--output_dir "${OUTPUT_DIR}/orf" \
--sample_name "${SAMPLE_NAME}" \
--nslots "${NSLOTS}" \
--train_file_name "${TRAIN_FILE_NAME}"

if [[ $? -ne 0 ]]; then
  echo "module2_orf_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 9. Module 3: annotate functional genes mg_traits
###############################################################################

echo -e "\ncomputing function mg_traits ...\n"

NUM_GENES=$(egrep -c ">" "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.ffn")

"${MG_TRAITS_DIR}/modules_mg_traits/module3_fun_mg_traits.sh" \
--input_file "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.faa" \
--output_dir "${OUTPUT_DIR}/fun" \
--sample_name "${SAMPLE_NAME}" \
--num_genes "${NUM_GENES}" \
--nslots "${NSLOTS}"

if [[ $? -ne 0 ]]; then
  echo "module3_fun_mg_traits.sh failed"
  exit 1
fi

###############################################################################
### 10. Compute AGS
###############################################################################

echo -e "\ncomputing ags ...\n"

"${ags}" \
--input_fna "${INPUT_FILE}" \
--sample_name "${SAMPLE_NAME}" \
--outdir "${OUTPUT_DIR}/ags" \
--max_length "${MAX_LENGTH}" \
--nslots "${NSLOTS}" \
--save_complementary_data t \
--verbose t \
--overwrite t

if [[ $? -ne "0" ]]; then
  echo "${ags} failed"
  exit 1
fi  

# clean
rm "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_orfs.faa" 

if [[ $? -ne "0" ]]; then
  echo "cleaning ags orfs output failed"
  exit 1
fi  

###############################################################################
# 11. Compute ACN
###############################################################################

echo -e "\ncomputing acn ...\n"

"${acn}" \
--input_fna "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_FBL.fna" \
--outdir "${OUTPUT_DIR}/acn" \
--input_ags "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_ags.tsv" \
--nslots "${NSLOTS}" \
--evalue "${EVALUE_ACN}" \
--save_complementary_data t \
--output_prefix "${SAMPLE_NAME}" \
--verbose t \
--overwrite t

if [[ $? -ne "0" ]]; then
  echo "${acn} failed"
  exit 1
fi  

# clean
rm "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_FBL.fna"

if [[ $? -ne "0" ]]; then
  echo "cleaning ags fna output failed"
  exit 1
fi  

###############################################################################
# 12. Format AGS output
###############################################################################

awk -v s="${SAMPLE_NAME}" -v OFS="\t" '{
  if (NR > 1) { 
    print s,"AGS",$2
    print s,"NGs",$3
    print s,"BPs",$4
  }
}' "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_ags.tsv" > \
   "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_ags_tmp.tsv" 

if [[ $? -ne "0" ]]; then
  echo "awk ags output formatting failed"
  exit 1
fi  
   
mv "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_ags_tmp.tsv" \
   "${OUTPUT_DIR}/ags/${SAMPLE_NAME}_ags.tsv"
 
if [[ $? -ne "0" ]]; then
  echo "ags file renaming failed"
  exit 1
fi  

###############################################################################
# 13. Format ACN output
###############################################################################

awk -v s="${SAMPLE_NAME}" -v OFS="\t" '{
  if (NR > 1) { 
    print s,"ACN",$2
  }
}' "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_acn.tsv" > \
   "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_acn_tmp.tsv" 

if [[ $? -ne "0" ]]; then
  echo "awk acn output formatting failed"
  exit 1
fi  
   
mv "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_acn_tmp.tsv" \
   "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_acn.tsv"
 
if [[ $? -ne "0" ]]; then
  echo "acn file renaming failed"
  exit 1
fi  

###############################################################################
### 14. Module 4: compute taxonomic diversity
###############################################################################

echo -e "\ncomputing tax mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module4_tax_mg_traits.sh" \
--input_smrna "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_smrna.blast" \
--input_file "${OUTPUT_DIR}/acn/${SAMPLE_NAME}_smrna.fna" \
--output_dir "${OUTPUT_DIR}/tax" \
--sample_name "${SAMPLE_NAME}" \
--evalue "${EVALUE_DIV}" \
--nslots "${NSLOTS}" \
--min_length "${MIN_LENGTH}" \
--ref_db "${REF_DB}" \
--confidence "${CONFIDENCE}"

if [[ $? -ne 0 ]]; then
  echo "module4_tax_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 15. Module 5: Resfam annotation
###############################################################################

echo -e "\ncomputing resfam mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module5_res_mg_traits.sh" \
--input_file "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.faa" \
--output_dir "${OUTPUT_DIR}/res" \
--sample_name "${SAMPLE_NAME}" \
--num_genes "${NUM_GENES}" \
--evalue "${EVALUE_RES}" \
--nslots "${NSLOTS}"

if [[ $? -ne 0 ]]; then
  echo "module5_res_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 16. Module 6: bgc domains annotation
###############################################################################

echo -e "\ncomputing bgc mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module6_bgc_mg_traits.sh" \
--input_file "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.faa" \
--output_dir "${OUTPUT_DIR}/bgc" \
--sample_name "${SAMPLE_NAME}" \
--num_genes "${NUM_GENES}" \
--nslots "${NSLOTS}"

if [[ $? -ne 0 ]]; then
  echo "module5_res_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 15. Module 7: CAZymes annotation
###############################################################################

echo -e "\ncomputing cazyme mg_traits ...\n"

"${MG_TRAITS_DIR}/modules_mg_traits/module7_caz_mg_traits.sh" \
--input_file "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.faa" \
--output_dir "${OUTPUT_DIR}/caz" \
--sample_name "${SAMPLE_NAME}" \
--num_genes "${NUM_GENES}" \
--evalue "${EVALUE_CAZ}" \
--nslots "${NSLOTS}"

if [[ $? -ne 0 ]]; then
  echo "module5_res_mg_traits.sh failed"
  exit 1
fi  

###############################################################################
### 17. Compress large files
###############################################################################

"${pigz}" --processes "${NSLOTS}" "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.faa"

if [[ $? -ne 0 ]]; then
  echo "compressing file ${SAMPLE_NAME}.faa failed"
  exit 1
fi 

"${pigz}" --processes "${NSLOTS}" "${OUTPUT_DIR}/orf/${SAMPLE_NAME}.ffn"

if [[ $? -ne 0 ]]; then
  echo "compressing file ${SAMPLE_NAME}.ffn failed"
  exit 1
fi 

"${pigz}" --processes "${NSLOTS}" "${OUTPUT_DIR}/nuc/${SAMPLE_NAME}.info"

if [[ $? -ne 0 ]]; then
  echo "compressing file ${SAMPLE_NAME}.info failed"
  exit 1
fi 

###############################################################################
### 18. Exit status
###############################################################################

echo "exited with 0 errors"

