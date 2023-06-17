################################################################################
# Mg-Traits pipeline
################################################################################

FROM ubuntu:22.04

################################################################################
# 1. define env
################################################################################

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV DEBIAN_FRONTEND=noninteractive 

RUN mkdir -p /bioinfo/software/bin; \
mkdir /bioinfo/software/mg_traits; \
mkdir /bioinfo/software/mg_traits/toolbox/; \
mkdir -p /bioinfo/resources/; \
mkdir -p /bioinfo/resources/sortmerna; \
mkdir -p /output/; \
mkdir -p /input/

################################################################################
# 2. get basic packages
################################################################################

RUN apt-get update && apt-get install -y apt-utils 

RUN apt-get install -y \
  wget \
  zip \
  unzip \
  build-essential \
  joe \
  less \
  zlib1g-dev \
  software-properties-common \
  libcurl4-gnutls-dev \
  libxml2-dev \
  libssl-dev \
  bc \
  git \
  file
  
################################################################################
# 3. R and R packages: tidyverse and dada2 (+ dependencies)
################################################################################

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
E298A3A825C0D65DFD57CBB651716619E084DAB9; \
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
   
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y r-base

RUN echo "r <- getOption('repos'); \
r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

RUN Rscript -e "install.packages('tidyverse')"; \
Rscript -e "install.packages('devtools', dependencies = T)"; \
Rscript -e "install.packages('BiocManager')"; \
Rscript -e "BiocManager::install('dada2')"; \
Rscript -e "BiocManager::install('Biostrings')"
 
RUN apt install -y \
libfontconfig1-dev \
libharfbuzz-dev \
libfribidi-dev \
libtiff-dev

RUN Rscript -e "install.packages('systemfonts', dependencies=T)"; \
Rscript -e "install.packages('textshaping', dependencies=T)"; \
Rscript -e "install.packages('ragg', dependencies=T)"; \
Rscript -e "install.packages('tidyverse', dependencies=T)"

################################################################################
# 4. UProC
################################################################################

RUN wget http://uproc.gobics.de/downloads/uproc/uproc-1.2.0.tar.gz;\ 
tar xzfv uproc-1.2.0.tar.gz -C /bioinfo/software/bin/; \
cd  /bioinfo/software/bin/uproc-1.2.0/; \
./configure; \
make; \
make install

################################################################################
# 5. UProC model 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
http://uproc.gobics.de/downloads/models/model.tar.gz; \
cd  bioinfo/resources/; \
tar xzfv /bioinfo/resources/model.tar.gz

################################################################################
# 6. seqtk
################################################################################

RUN cd /bioinfo/software/bin; \
git clone https://github.com/lh3/seqtk.git; \
cd seqtk; \
make

################################################################################
# 7. vsearch
################################################################################

RUN apt-get install -y autoconf

RUN mkdir /bioinfo/software/bin/vsearch; \
wget https://github.com/torognes/vsearch/archive/v2.22.1.tar.gz; \
tar xzf v2.22.1.tar.gz; \
cd vsearch-2.22.1; \
./autogen.sh; \
./configure CFLAGS="-O3" CXXFLAGS="-O3" --prefix="/bioinfo/software/bin/vsearch"; \
make; \
make install;

################################################################################
# 8. FragGeneScanRs
################################################################################

RUN wget --directory-prefix=/bioinfo/software/bin \
https://github.com/unipept/FragGeneScanRs/releases/download/v1.1.0/FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz

RUN cd /bioinfo/software/bin; \
tar xzfv FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz; \
rm FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/unipept/FragGeneScanRs/main/train/illumina_1; \
wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/unipept/FragGeneScanRs/main/train/illumina_5

################################################################################
# 9. SortMeRNA tool and database
################################################################################

#  install
RUN wget \
https://github.com/biocore/sortmerna/releases/download/v4.3.6/sortmerna-4.3.6-Linux.sh

RUN mkdir /bioinfo/software/bin/sortmerna

RUN bash sortmerna-4.3.6-Linux.sh --skip-license --prefix=/bioinfo/software/bin/sortmerna

#  downlaod dbs: default
RUN wget --directory-prefix=/bioinfo/resources/sortmerna/ \
https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz; \
mkdir /bioinfo/resources/sortmerna/sortmerna_databases; \
tar -xvf /bioinfo/resources/sortmerna/database.tar.gz -C /bioinfo/resources/sortmerna/sortmerna_databases

#  downlaod dbs: arc
RUN wget --directory-prefix=/bioinfo/resources/sortmerna/sortmerna_databases/ \
https://raw.githubusercontent.com/sortmerna/sortmerna/master/data/rRNA_databases/silva-arc-16s-id95.fasta

#  downlaod dbs: bac
RUN wget --directory-prefix=/bioinfo/resources/sortmerna/sortmerna_databases/ \
https://raw.githubusercontent.com/sortmerna/sortmerna/master/data/rRNA_databases/silva-bac-16s-id90.fasta

#  index dbs: default
RUN /bioinfo/software/bin/sortmerna/bin/sortmerna \
-ref /bioinfo/resources/sortmerna/sortmerna_databases/smr_v4.3_default_db.fasta \
--index 1 \
--workdir /bioinfo/resources/sortmerna/

#  index dbs: arc
RUN /bioinfo/software/bin/sortmerna/bin/sortmerna \
-ref /bioinfo/resources/sortmerna/sortmerna_databases/silva-arc-16s-id95.fasta \
--index 1 \
--workdir /bioinfo/resources/sortmerna/

#  index dbs: bac
RUN /bioinfo/software/bin/sortmerna/bin/sortmerna \
-ref /bioinfo/resources/sortmerna/sortmerna_databases/silva-bac-16s-id90.fasta \
--index 1 \
--workdir /bioinfo/resources/sortmerna/

################################################################################
# 10. bbmap, diamond, hmmer, emboss, and gawk
################################################################################

RUN apt-get install -y \
bbmap \
diamond-aligner \
hmmer \
emboss \
gawk

################################################################################
# 11. Pfam UProC DB 
################################################################################

RUN wget \
--directory-prefix=/bioinfo/resources/ \
http://uproc.gobics.de/downloads/db/pfam28.uprocdb.gz

# COPY resources/pfam28.uprocdb.gz /bioinfo/resources/

RUN /bioinfo/software/bin/uproc-1.2.0/uproc-import \
/bioinfo/resources/pfam28.uprocdb.gz /bioinfo/resources/pfam28_db

################################################################################
# 12. dbCAN3 and dbCAN3 sub
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-old@UGA/dbCAN-fam-HMMs.txt.v11; \
wget --directory-prefix=/bioinfo/resources/ \
https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN_sub.hmm

################################################################################
# 13. Resfam 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
http://dantaslab.wustl.edu/resfams/Resfams-full.hmm.gz; \
gunzip /bioinfo/resources/Resfams-full.hmm.gz

################################################################################
# 14. BGC domains 
################################################################################

RUN wget -O /bioinfo/resources/uproc_bgc_db.tar.gz \
https://figshare.com/ndownloader/files/41140853; \
tar xzfv /bioinfo/resources/uproc_bgc_db.tar.gz -C /bioinfo/resources/

################################################################################
# 15. HYD HMMs
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/dgittins/CANT-HYD-HydrocarbonBiodegradation/main/HMMs/concatenated%20HMMs/CANT-HYD.hmm

################################################################################
# 16. NCyc db
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/qichao1984/NCyc/master/data/NCyc_100.faa.gz; \
gunzip /bioinfo/resources/NCyc_100.faa.gz

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/qichao1984/NCyc/master/data/id2gene.map; \
mv /bioinfo/resources/id2gene.map /bioinfo/resources/ncyc_id2genemap.txt; \
diamond makedb \
--in /bioinfo/resources/NCyc_100.faa \
--db /bioinfo/resources/NCyc

################################################################################
# 17. PCyc db
################################################################################

RUN wget  --directory-prefix=/bioinfo/resources/ \
https://github.com/ZengJiaxiong/Phosphorus-cycling-database/releases/download/untagged-5a0f44fdf33412c5d1d3/PCycDBv1.1.faa; \
wget  --directory-prefix=/bioinfo/resources/ \
https://github.com/ZengJiaxiong/Phosphorus-cycling-database/releases/download/untagged-5a0f44fdf33412c5d1d3/id2genemap.txt

RUN mv /bioinfo/resources/id2genemap.txt /bioinfo/resources/pcyc_id2genemap.txt; \
diamond makedb \
--in /bioinfo/resources/PCycDBv1.1.faa \
--db /bioinfo/resources/PCyc

################################################################################
# 18. Plastic db
################################################################################

RUN wget  --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/pereiramemo/Mg-Traits/main/cont_env/resources/PlasticDB.fasta.gz; \
gunzip /bioinfo/resources/PlasticDB.fasta.gz; \
diamond makedb \
--in /bioinfo/resources/PlasticDB.fasta \
--db /bioinfo/resources/PlasticDB

################################################################################
# 19. TF.txt factor 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/pereiramemo/Mg-Traits/main/cont_env/resources/TF.txt

# COPY resources/TF.txt /bioinfo/resources/

################################################################################
# 20. Silva train nr99 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://zenodo.org/record/3986799/files/silva_nr99_v138_train_set.fa.gz?download=1; \
mv "/bioinfo/resources/silva_nr99_v138_train_set.fa.gz?download=1" \
/bioinfo/resources/silva_nr99_v138_train_set.fa.gz

################################################################################
# 21. SCG uproc db and cog lengths file
################################################################################

RUN wget -O /bioinfo/resources/uproc_scg_db.tar.gz \
https://figshare.com/ndownloader/files/41142581

# COPY resources/uproc_scg_db.tar.gz /bioinfo/resources/
RUN tar xzfv /bioinfo/resources/uproc_scg_db.tar.gz -C /bioinfo/resources/

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/pereiramemo/Mg-Traits/main/cont_env/resources/all_cog_lengths.tsv

# COPY resources/all_cog_lengths.tsv /bioinfo/resources/all_cog_lengths.tsv

################################################################################
# 22. Pfam acc list 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/pereiramemo/Mg-Traits/main/cont_env/resources/Pfam_v28.0_acc.txt

#COPY resources/Pfam_v28.0_acc.txt /bioinfo/resources/

################################################################################
# 23. taxa annot scripts 
################################################################################

COPY software/mg_traits/toolbox/taxa_annot_rRDP.R /bioinfo/software/mg_traits/toolbox/
COPY software/mg_traits/toolbox/taxa_annot_DADA2.R /bioinfo/software/mg_traits/toolbox/

################################################################################
# 24. AGS and ACN tools
################################################################################

COPY software/mg_traits/toolbox/ags.sh /bioinfo/software/mg_traits/toolbox/
COPY software/mg_traits/toolbox/acn.sh /bioinfo/software/mg_traits/toolbox/

################################################################################
# 25. code: modules + mg_traits.sh
################################################################################

COPY software/mg_traits/modules /bioinfo/software/mg_traits/modules
COPY software/mg_traits/mg_traits.sh /bioinfo/software/mg_traits/
COPY software/mg_traits/conf.sh /bioinfo/software/mg_traits/
COPY software/mg_traits/funs.sh /bioinfo/software/mg_traits/

################################################################################
# 26. Set permissions
################################################################################

RUN chmod -R +x /bioinfo/software/; \
chmod -R 777 /output/; \
chmod -R 777 /input/; \
chmod -R 777 /bioinfo/resources/sortmerna/

################################################################################
## 27. clean
################################################################################

RUN rm uproc-1.2.0.tar.gz; \
rm v2.22.1.tar.gz; \
rm -r vsearch-2.22.1; \
rm /bioinfo/resources/model.tar.gz; \
rm sortmerna-4.3.6-Linux.sh;

################################################################################
## 28. entry point
################################################################################

ENTRYPOINT ["/bioinfo/software/mg_traits/mg_traits.sh"]
