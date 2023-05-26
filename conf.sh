# dirs # general
BIOINF_DIR="/home/bioinf"
BIN="${BIOINF_DIR}/bin"
MG_TRAITS_DIR="${HOME}/workspace/repositories/tools/metagenomic_pipelines/mg_traits"
MG_TRAITS_RESOURCES="${MG_TRAITS_DIR}/resources_mg_traits"
LOCAL="/home/epereira/.local/"

# files
TRANSFACT_ACC="${MG_TRAITS_RESOURCES}/TF.txt"
RESFAM_HMM="${MG_TRAITS_RESOURCES}/Resfams.hmm"
PFAM_MODEL_DIR="${MG_TRAITS_RESOURCES}/model_uproc_pfam"
PFAM_DB="${MG_TRAITS_RESOURCES}/pfam28_db"
BGC_MODEL_DIR="${MG_TRAITS_RESOURCES}/model_uproc_bgc"
BGC_DB="${MG_TRAITS_RESOURCES}/bgc13062014"
CAZ_HMM="${MG_TRAITS_RESOURCES}/dbCAN-HMMdb-V11.txt"
PFAM_HMM="${MG_TRAITS_RESOURCES}/Pfam-A.hmm"
HYD_HMM="${MG_TRAITS_RESOURCES}/CANT-HYD.hmm"

# tools
# bbduk
bbmap_version="38.79"
bbduk="${BIN}/bbmap/bbmap-${bbmap_version}/bbduk.sh"
bbmerge="${BIN}/bbmap/bbmap-${bbmap_version}/bbmerge.sh"
filterbyname="${BIN}/bbmap/bbmap-${bbmap_version}/filterbyname.sh"

# pear
pear_version="0.9.8"
pear="${BIN}/pear/pear-${pear_version}/bin/pear"

# fraggenescan

# fraggenescanplusplus="${BIN}/fraggenescan/FragGeneScanPlusPlus-master/FGSpp"
# TRAIN="${BIN}/fraggenescan/FragGeneScanPlusPlus-master/train"
# fraggenescan_version="1.31"
# fraggenescan="${BIN}/fraggenescan/FragGeneScan-${fraggenescan_version}/run_FragGeneScan.pl"

fraggenescan_version="Rs"
fraggenescan="${BIN}/fraggenescan/FragGeneScan${fraggenescan_version}/bin/FragGeneScan${fraggenescan_version}"
FRAGGENESCAN_TRAIN_FILE_DIR="${BIN}/fraggenescan/FragGeneScan${fraggenescan_version}/FragGeneScan${fraggenescan_version}/train"

#uproc
uproc_version="1.2.0"
uproc_prot="${BIN}/uproc/uproc-${uproc_version}/uproc-prot"

# emboss
infoseq="/usr/bin/infoseq"
compseq="/usr/bin/compseq"
cusp="/usr/bin/cusp"

# ags and acn
ags="${BIN}/ags_n_acn/ags.sh"
acn="${BIN}/ags_n_acn/acn.sh"

# vsearch
vsearch_version="2.15.1"
vsearch="${BIN}/vsearch/vsearch-${vsearch_version}/bin/vsearch"

# hmmer
hmmer_version="3.3"
hmmsearch="${BIN}/hmmer/hmmer-${hmmer_version}/bin/hmmsearch"

# R
r_interpreter="/usr/bin/R"
r_script="/usr/bin/Rscript"
taxa_annot="${MG_TRAITS_RESOURCES}/taxa_annot_DADA2.R"

# other
seqtk="${BIN}/seqtk/seqtk"
cutadapt="${LOCAL}/bin/cutadapt"
# seq_num_and_length_counter="${SCRIPTS}/seq_num_and_length_counter.bash"
bzip2="/bin/bzip2"
gunzip="/bin/gunzip"
fq2fa="/home/epereira/bin/fq2fa.sh"
pigz="/usr/bin/pigz"

