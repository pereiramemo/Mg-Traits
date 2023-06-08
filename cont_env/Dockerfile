################################################################################
# Mg-Traits pipeline
################################################################################

FROM ubuntu:22.04

################################################################################
# 1. define env
################################################################################

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV DEBIAN_FRONTEND=noninteractive 

RUN mkdir -p /bioinfo/software/bin
RUN mkdir /bioinfo/software/mg_traits
RUN mkdir /bioinfo/software/mg_traits/toolbox/
RUN mkdir -p /bioinfo/resources/
RUN mkdir -p /bioinfo/resources/sortmerna
RUN mkdir -p /output/
RUN mkdir -p /input/

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
  bc
  
RUN apt-get install -y gawk

################################################################################
# 3. R and R packages: tidyverse and dada2 (+ dependencies)
################################################################################

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
E298A3A825C0D65DFD57CBB651716619E084DAB9 
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
   
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y r-base

RUN echo "r <- getOption('repos'); \
r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('tidyverse')"
RUN Rscript -e "install.packages('devtools', dependencies = T)"

RUN Rscript -e "install.packages('BiocManager')"
RUN Rscript -e "BiocManager::install('dada2')"
RUN Rscript -e "BiocManager::install('Biostrings')"

RUN apt install -y libfontconfig1-dev
RUN apt install -y libharfbuzz-dev  libfribidi-dev
RUN apt install -y libtiff-dev

RUN Rscript -e "install.packages('systemfonts', dependencies=T)"
RUN Rscript -e "install.packages('textshaping', dependencies=T)"
RUN Rscript -e "install.packages('ragg', dependencies=T)"
RUN Rscript -e "install.packages('tidyverse', dependencies=T)"

################################################################################
# 4. EMBOSS
################################################################################

RUN apt-get install -y emboss

################################################################################
# 5. UProC
################################################################################

RUN wget http://uproc.gobics.de/downloads/uproc/uproc-1.2.0.tar.gz
RUN tar xzfv uproc-1.2.0.tar.gz -C /bioinfo/software/bin/
  
RUN  cd  /bioinfo/software/bin/uproc-1.2.0/; \
./configure; \
make; \
make install

################################################################################
# 6. UProC model 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
http://uproc.gobics.de/downloads/models/model.tar.gz

RUN cd  bioinfo/resources/; \
tar xzfv /bioinfo/resources/model.tar.gz

################################################################################
# 7. seqtk
################################################################################

RUN apt-get install -y git

RUN cd /bioinfo/software/bin; \
git clone https://github.com/lh3/seqtk.git; \
cd seqtk; \
make

################################################################################
# 8. hmmsearch
################################################################################

RUN apt install -y hmmer

################################################################################
# 9. vsearch
################################################################################

RUN apt-get install -y autoconf

RUN mkdir /bioinfo/software/bin/vsearch

RUN wget https://github.com/torognes/vsearch/archive/v2.22.1.tar.gz
RUN tar xzf v2.22.1.tar.gz
RUN cd vsearch-2.22.1; \
./autogen.sh; \
./configure CFLAGS="-O3" CXXFLAGS="-O3" --prefix="/bioinfo/software/bin/vsearch"; \
make; \
make install;

################################################################################
# 10. FragGeneScanRs
################################################################################

RUN wget --directory-prefix=/bioinfo/software/bin \
https://github.com/unipept/FragGeneScanRs/releases/download/v1.1.0/FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz

RUN cd /bioinfo/software/bin; \
tar xzfv FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz; \
rm FragGeneScanRs-v1.1.0-x86_64-unknown-linux-musl.tar.gz

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/unipept/FragGeneScanRs/main/train/illumina_1

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/unipept/FragGeneScanRs/main/train/illumina_5

################################################################################
# 11. SortMeRNA tool and database
################################################################################

#  install
RUN wget \
https://github.com/biocore/sortmerna/releases/download/v4.3.6/sortmerna-4.3.6-Linux.sh

RUN mkdir /bioinfo/software/bin/sortmerna

RUN bash sortmerna-4.3.6-Linux.sh --skip-license --prefix=/bioinfo/software/bin/sortmerna

#  downlaod dbs
RUN wget --directory-prefix=/bioinfo/resources/sortmerna/ \
https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz; \
mkdir /bioinfo/resources/sortmerna/sortmerna_databases; \
tar -xvf /bioinfo/resources/sortmerna/database.tar.gz -C /bioinfo/resources/sortmerna/sortmerna_databases

#  index dbs
RUN /bioinfo/software/bin/sortmerna/bin/sortmerna \
-ref /bioinfo/resources/sortmerna/sortmerna_databases/smr_v4.3_default_db.fasta \
--index 1 \
--workdir /bioinfo/resources/sortmerna/

################################################################################
# 12. bbmap
################################################################################

RUN apt-get install -y bbmap

################################################################################
# 13. diamond
################################################################################

RUN apt-get install -y diamond-aligner

################################################################################
# 14. Pfam UProC DB 
################################################################################

# RUN wget \
# --directory-prefix=/bioinfo/resources/ \
# http://uproc.gobics.de/downloads/db/pfam28.uprocdb.gz

COPY resources/pfam28.uprocdb.gz /bioinfo/resources/

RUN /bioinfo/software/bin/uproc-1.2.0/uproc-import \
/bioinfo/resources/pfam28.uprocdb.gz /bioinfo/resources/pfam28_db

################################################################################
# 15. dbCAN3 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-old@UGA/dbCAN-fam-HMMs.txt.v11

################################################################################
# 16. Resfam 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
http://dantaslab.wustl.edu/resfams/Resfams-full.hmm.gz

RUN gunzip /bioinfo/resources/Resfams-full.hmm.gz

################################################################################
# 17. BGC domains 
################################################################################

COPY resources/bgc_uproc_db_all /bioinfo/resources/bgc_uproc_db_all

################################################################################
# 18. HYD HMMs
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/dgittins/CANT-HYD-HydrocarbonBiodegradation/main/HMMs/concatenated%20HMMs/CANT-HYD.hmm

################################################################################
# 19. NCyc db
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/qichao1984/NCyc/master/data/NCyc_100.faa.gz

RUN gunzip /bioinfo/resources/NCyc_100.faa.gz

RUN wget --directory-prefix=/bioinfo/resources/ \
https://raw.githubusercontent.com/qichao1984/NCyc/master/data/id2gene.map

RUN mv /bioinfo/resources/id2gene.map /bioinfo/resources/ncyc_id2genemap.txt 

RUN diamond makedb \
--in /bioinfo/resources/NCyc_100.faa \
--db /bioinfo/resources/NCyc

################################################################################
# 20. PCyc db
################################################################################

RUN wget  --directory-prefix=/bioinfo/resources/ \
https://github.com/ZengJiaxiong/Phosphorus-cycling-database/releases/download/untagged-5a0f44fdf33412c5d1d3/PCycDBv1.1.faa

RUN wget  --directory-prefix=/bioinfo/resources/ \
https://github.com/ZengJiaxiong/Phosphorus-cycling-database/releases/download/untagged-5a0f44fdf33412c5d1d3/id2genemap.txt

RUN mv /bioinfo/resources/id2genemap.txt /bioinfo/resources/pcyc_id2genemap.txt 

RUN diamond makedb \
--in /bioinfo/resources/PCycDBv1.1.faa \
--db /bioinfo/resources/PCyc

################################################################################
# 21. Plastic db
################################################################################

# RUN wget  --directory-prefix=/bioinfo/resources/ \
# https://plasticdb.org/static/PlasticDB.fasta

COPY resources/PlasticDB.fasta /bioinfo/resources/

RUN diamond makedb \
--in /bioinfo/resources/PlasticDB.fasta \
--db /bioinfo/resources/PlasticDB

################################################################################
# 22. TF.txt factor 
################################################################################

COPY resources/TF.txt /bioinfo/resources/

################################################################################
# 23. Silva train nr99 
################################################################################

RUN wget --directory-prefix=/bioinfo/resources/ \
https://zenodo.org/record/3986799/files/silva_nr99_v138_train_set.fa.gz?download=1

RUN mv "/bioinfo/resources/silva_nr99_v138_train_set.fa.gz?download=1" \
/bioinfo/resources/silva_nr99_v138_train_set.fa.gz

################################################################################
# 24. SCG uproc db and cog lengths file
################################################################################

COPY resources/uproc_scg_db /bioinfo/resources/uproc_scg_db
COPY resources/all_cog_lengths.tsv /bioinfo/resources/all_cog_lengths.tsv

################################################################################
# 25. Pfam acc list 
################################################################################

COPY resources/Pfam_v28.0_acc.txt /bioinfo/resources/

################################################################################
# 26. taxa annot scripts 
################################################################################

COPY software/mg_traits/toolbox/taxa_annot_rRDP.R /bioinfo/software/mg_traits/toolbox/
COPY software/mg_traits/toolbox/taxa_annot_DADA2.R /bioinfo/software/mg_traits/toolbox/

################################################################################
# 27. AGS and ACN tools
################################################################################

COPY software/mg_traits/toolbox/ags.sh /bioinfo/software/mg_traits/toolbox/
COPY software/mg_traits/toolbox/acn.sh /bioinfo/software/mg_traits/toolbox/

################################################################################
# 28. code: modules + mg_traits.sh
################################################################################

COPY software/mg_traits/modules /bioinfo/software/mg_traits/modules
COPY software/mg_traits/mg_traits.sh /bioinfo/software/mg_traits/
COPY software/mg_traits/conf.sh /bioinfo/software/mg_traits/
COPY software/mg_traits/funs.sh /bioinfo/software/mg_traits/

################################################################################
# 29. Set permissions
################################################################################

RUN chmod -R +x /bioinfo/software/
RUN chmod -R 777 /output/
RUN chmod -R 777 /input/
RUN chmod -R 777 /bioinfo/resources/sortmerna/

################################################################################
## 30. clean
################################################################################

RUN rm uproc-1.2.0.tar.gz
RUN rm v2.22.1.tar.gz
RUN rm -r vsearch-2.22.1
RUN rm /bioinfo/resources/model.tar.gz
RUN rm sortmerna-4.3.6-Linux.sh

################################################################################
## 31. entry point
################################################################################

ENTRYPOINT ["/bioinfo/software/mg_traits/mg_traits.sh"]
