# Mg-Traits

**mg_traits** is a command line application programmed in BASH, AWK, and R, dedicated to the computation of
29 (and counting) functional traits at the metagenome level (i.e., functional aggregated traits), ranging from GC variance and amino acid composition to functional diversity and average genome size. It takes as an input a preprocessed (unassembled) metagenomic sample and outputs the computed metagenomic traits organized in different tables and grouped in separate folders according to the type of data source
(see [Fig. 1](#figure1)). 

**Mg-Traits utilizes the following tools**:  
[AGS and ACN tools](https://github.com/pereiramemo/AGS-and-ACN-tools)  
[BBTools](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide) 
[DADA2](https://benjjneb.github.io/dada2/)  
[diamond](https://github.com/bbuchfink/diamond)  
[EMBOSS](http://emboss.sourceforge.net/)  
[FragGeneScanRs](https://github.com/unipept/FragGeneScanRs)  
[HMMER](http://hmmer.org)  
[R](https://www.r-project.org)  
[seqtk](https://github.com/lh3/seqtk)  
[SortMeRNA](https://github.com/sortmerna/sortmerna)  
[tidyverse](https://www.tidyverse.org)  
[UProC](http://uproc.gobics.de/)  
[VSEARCH](https://github.com/torognes/vsearch)  

**and databases**:  
[CANT-HYD](https://github.com/dgittins/CANT-HYD-HydrocarbonBiodegradation)  
[dbCAN and dbCAN-sub](https://bcb.unl.edu/dbCAN2)  
[NCYc](https://github.com/qichao1984/NCyc)  
[PCyc](https://github.com/ZengJiaxiong/Phosphorus-cycling-database)  
[Pfam (UProC format)](http://uproc.gobics.de)  
[PlasticDB](http://plasticdb.org/)  
[Resfams](http://www.dantaslab.org/resfams)  
[Silva SSU nr99 (DADA2 format)](https://zenodo.org/record/3986799)  

**Usage**:
```
Usage: ./mg_traits.sh <input file> <output dir> <options>
--help                          print this help
--clean t|f                     remove all intermediate files
--confidence NUM                confidence value to run rdp bayes classifier (from 0 to 100; default 50)
--evalue_acn NUM                evalue to filter reads for ACN computation (default 1e-15)
--evalue_div NUM                evalue to filter reads for diversity estimation (default 1e-15)
--evalue_res NUM                evalue to annotate ResFam with hmmsearch (default 1e-15)
--evalue_caz NUM                evalue to annotate CAZyme with hmmsearch (default 1e-15)
--evalue_hyd NUM                evalue to annotate Hyd with hmmsearch (default 1e-15)
--evalue_ncy NUM                evalue to annotate NCycle with diamond (default 1e-15)
--evalue_pcy NUM                evalue to annotate PCycle with diamond (default 1e-15)
--evalue_pls NUM                evalue to annotate Plastic DB with diamond (default 1e-15)
--nslots NUM                    number of threads used (default 12)
--max_length NUM                maximum read length used to trim reads (from the 3' end) for AGS computation (default 180)
--min_length NUM                minimum read length used to estimate taxonomic diversity (default 100)
--overwrite t|f                 overwrite previous directory (default f)
--ref_db CHAR                   reference database to run NBC (default silva_nr99_v138_train_set.fa.gz) 
--sample_name CHAR              sample name (default metagenomex)
--train_file_name CHAR          train file name to run FragGeneScan, see FragGeneScan help for options (default illumina_5)
--verbose t|f                   reduced verbose (default t)
--verbose_all t|f               complete verbose (default f)

<input file>: Fasta file used to compute mg-traits.
<output dir>: Output directory to store all computed ,g-traits.

```

**Workflow description**:

<a name="figure1">
</a>

![Figure 1](./figures/Mg_Traits-ENG.png)

__Figure 1. Mg-Traits pipeline. The 29 metagenomic traits computed by the Mg-Traits pipeline are divided into four different groups.__ 
The first includes the metagenomic traits computed at the nucleotide level: (1) GC content, (2) GC variance, and (3) Tetranucleotide frequency. 
The second group includes the traits obtained from the open reading frame (ORF) sequence data: (4) ORFs to Base Pairs (BPs) ratio, (5) Codon frequency, (6) Amino acid frequency, and (7) Acidic to basic amino acid ratio. 
The third group is based on the functional annotation of the ORF amino acid sequences. The first 16 metagenomic traits (from 8 to 23 in the figure) comprise the composition, diversity, richness, and percentage of annotated genes for
four different sets of genes: [Pfam](https://pfam.xfam.org), [Resfam](http://www.dantaslab.org/resfams), [Biosynthetic Gene Cluster (BGC) domains](https://doi.org/10.1101/2021.01.20.427441), and [CAZymes](https://bcb.unl.edu/dbCAN2/). 
Additionally, this group includes (24) the percentage of transcription factors (TFs) and (25) the average genome size (AGS). 
Lastly, in the fourth group are included the taxonomy-related metagenomic traits: (26) average copy number of 16S rRNA genes (ACN), taxonomic (27) composition, (28) diversity, and (29) richness.  




