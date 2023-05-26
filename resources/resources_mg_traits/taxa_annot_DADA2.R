#!/usr/bin/env Rscript

# This code is a modified version of the DADA2 tutorial: 
# https://benjjneb.github.io/dada2/tutorial.html

###############################################################################
### 1. Def. env
###############################################################################

library(dada2)
library(Biostrings)
library(tidyverse)

###############################################################################
### 2. Get parameters
###############################################################################

args = commandArgs(trailingOnly=TRUE)

INPUT_FASTA <- args[1]
OUTPUT_TABLE <- args[2]
REF_DB <- args[3]
CONFIDENCE <- args[4] %>% as.numeric()
NSLOTS <- args[5] %>% as.numeric()

# INPUT_FASTA <- "~/workspace/dev/indicators_contaminants_2018/results/metagenomics/mg_traits/sample_1_mg_traits/tax/sample_1_centroids.fasta"
# OUTPUT_TABLE <- "~/workspace/dev/indicators_contaminants_2018/results/metagenomics/mg_traits/sample_1_mg_traits/tax/sample_1_centroids_annot.tsv"
# REF_DB <- "/home/bioinf/resources/pr2/pr2_version_4.12.0_18S_dada2_7fileds.fasta.gz"
# CONFIDENCE <- 50
# NSLOTS <- 12

###############################################################################
### 3. Load data
###############################################################################

seqs <- readDNAStringSet(INPUT_FASTA) 
seqs_vect <- seqs %>% 
             as.character(use.names=TRUE)
seqs_vect_uniq <- unique(seqs_vect)

###############################################################################
### 4. Perform annotation
###############################################################################

seqs_annot <- assignTaxonomy(seqs = seqs_vect_uniq, 
                             refFasta = REF_DB, 
                             minBoot = CONFIDENCE,
                             outputBootstraps = T,
                             multithread = NSLOTS,
                             tryRC = T)

###############################################################################
### 5. Format input and output files
###############################################################################

seqs_annot_tax <- seqs_annot$tax %>%
                  as.data.frame %>%
                  rownames_to_column("seq")

seqs_df <- data.frame(seq = seqs_vect, stringsAsFactors = F)
seqs_df$otu_id <- names(seqs_vect)

###############################################################################
### 6. Join
###############################################################################

seqs_annot_tax_ext <- left_join(seqs_df, seqs_annot_tax, by = "seq") %>%
                      select(-seq)

###############################################################################
### 7. Export
###############################################################################

write.table(x = seqs_annot_tax_ext, file = OUTPUT_TABLE, sep = "\t", col.names = T, row.names = F, quote = F)
