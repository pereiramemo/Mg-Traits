#!/usr/bin/env Rscript

###############################################################################
### 1. Def. env
###############################################################################

library(rRDP)
library(tidyverse)

###############################################################################
### 2. Get parameters
###############################################################################

args = commandArgs(trailingOnly=TRUE)

INPUT_FASTA <- args[1]
OUTPUT_TABLE <- args[2]
CONFIDENCE <- args[3] %>% as.numeric()

# INPUT_FASTA <- "~/workspace/dev/indicators_estuaries/taxa_annot/Alonso_et_al_2019_V1_V3/all_workable_centroids_extracted.fasta"
# OUTPUT_TABLE <- "~/workspace/dev/indicators_estuaries/taxa_annot/Alonso_et_al_2019_V1_V3/table_taxa_annot.tsv"

###############################################################################
### 3. Load data
###############################################################################

seqs <- readDNAStringSet(INPUT_FASTA)

###############################################################################
### 4. Perform annotation
###############################################################################

seqs_annot <- predict(rdp(), seqs, confidence = CONFIDENCE)

nas <- is.na(seqs_annot$phylum) %>% sum()
tot <- length(seqs_annot$phylum)
print(c("Phylum NAs perc:", nas/tot))

nas <- is.na(seqs_annot$family) %>% sum()
tot <- length(seqs_annot$family)
print(c("Family NAs perc:", nas/tot))

###############################################################################
### 5. Save asv annot table
###############################################################################

write.csv(x = seqs_annot, file = OUTPUT_TABLE)
