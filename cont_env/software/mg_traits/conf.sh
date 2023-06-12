###############################################################################
# dirs
###############################################################################

SOFTWARE_DIR="/bioinfo/software"
MG_TRAITS_DIR="${SOFTWARE_DIR}/mg_traits"
RESOURCES_DIR="/bioinfo/resources"

###############################################################################
# files
###############################################################################

PFAM_UPROC_DB="${RESOURCES_DIR}/pfam28_db"
BGC_UPROC_DB="${RESOURCES_DIR}/uproc_bgc_db"
SINGLE_COPY_COGS_DB="${RESOURCES_DIR}/uproc_scg_db"
UPROC_MODEL="${RESOURCES_DIR}/model"

TRANSFACT_ACC="${RESOURCES_DIR}/TF.txt"
COG_LENGTHS="${RESOURCES_DIR}/all_cog_lengths.tsv"

RESFAM_HMM="${RESOURCES_DIR}/Resfams-full.hmm"
CAZ_HMM="${RESOURCES_DIR}/dbCAN-fam-HMMs.txt.v11"
CAZSUB_HMM="${RESOURCES_DIR}/dbCAN_sub.hmm"

HYD_HMM="${RESOURCES_DIR}/CANT-HYD.hmm"

DB="${RESOURCES_DIR}/sortmerna/sortmerna_databases/"
REF_DEFAULT="${DB}/smr_v4.3_default_db.fasta"
REF_SENSITIVE="${DB}/smr_v4.3_sensitive_db.fasta"
REF_SENSITIVE_RFAMSEEDS="${DB}/smr_v4.3_sensitive_db_rfam_seeds.fasta"
REF_FAST="${DB}/smr_v4.3_fast_db.fasta"
REF_DB="${RESOURCES_DIR}/silva_nr99_v138_train_set.fa.gz"

NCYC_DB="${RESOURCES_DIR}/NCyc.dmnd"
NCYC_IDMAP="${RESOURCES_DIR}/ncyc_id2genemap.txt"
PCYC_DB="${RESOURCES_DIR}/PCyc.dmnd"
PCYC_IDMAP="${RESOURCES_DIR}/pcyc_id2genemap.txt"
PLASTIC_DB="${RESOURCES_DIR}/PlasticDB.dmnd"

###############################################################################
# tools
###############################################################################

# fraggenescan
fraggenescan="${SOFTWARE_DIR}/bin/FragGeneScanRs"
FRAGGENESCAN_TRAIN_FILE_DIR="${RESOURCES_DIR}"

#uproc
uproc_version="1.2.0"
uproc_prot="${SOFTWARE_DIR}/bin/uproc-${uproc_version}/uproc-prot"

# emboss
infoseq="/usr/bin/infoseq"
compseq="/usr/bin/compseq"
cusp="/usr/bin/cusp"

# hmmer
hmmsearch="/usr/bin/hmmsearch"

# ags and acn
ags="${SOFTWARE_DIR}/mg_traits/toolbox/ags.sh"
acn="${SOFTWARE_DIR}/mg_traits/toolbox/acn.sh"

# vsearch
vsearch_version="2.15.1"
vsearch="${SOFTWARE_DIR}/bin/vsearch/bin/vsearch"

# bbduk
bbduk="/usr/bin/bbduk.sh"

# sortmerna
sortmerna="${SOFTWARE_DIR}/bin/sortmerna/bin/sortmerna"

# R 
r_interpreter="/usr/bin/R"
r_script="/usr/bin/Rscript"
taxa_annot="${SOFTWARE_DIR}/mg_traits/toolbox/taxa_annot_DADA2.R"

# seqtk
seqtk="${SOFTWARE_DIR}/bin/seqtk/seqtk"

# diamond
diamond="/usr/bin/diamond"

# other
bzip2="/bin/bzip2"
gunzip="/bin/gunzip"
pigz="/usr/bin/pigz"
unpigz="/usr/bin/unpigz"

