% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FilterFromCNVs.R
\name{FilterFromCNVs}
\alias{FilterFromCNVs}
\title{FilterFromCNVs.}
\source{
\url{http://biopsych.dk/iPsychCNV}
}
\usage{
FilterFromCNVs(CNVs, PathRawData, MinNumSNPs = 10, Source = "iPsychCNV",
  Skip = 0, Cores = 1)
}
\arguments{
\item{CNVs}{data frame with CNVs.}

\item{PathRawData}{Path where are the LLR and BAF files. Exaple: "/media/NeoScreen/NeSc_home/ILMN/iPSYCH/Version2".}

\item{MinNumSNPs}{Minimum number of SNPs per CNV.}

\item{Source}{Which method is the original call.}

\item{Skip}{How many rows should skip. Use if file has comments.}

\item{Cores}{Number of cores to run in parallel.}
}
\value{
Data frame with the estimate copy number for each chromosome.
}
\description{
iPsychCNV: Find Copy Number Variation (CNV) from SNP genotyping arrays. 
Specifically designed to reduce false positive CNVs and handle data from amplified DNA on dried blood spots.
}
\details{
FilterFromCNVs: Filter CNV from other methods.
}
\examples{
LongRoi <- MakeLongMockSample(Mean=c(-0.6, -0.3, 0.3, 0.6), Size=c(200, 400, 600))
# GADA
Sample <- read.table("LongMockSample.tab", sep="\\t", header=TRUE, stringsAsFactors=F)
Gada <- RunGada(Sample)
Gada.filter <- FilterFromCNVs(CNVs=Gada, PathRawData=".", MinNumSNPs=10, Source="Gada", Skip=0, Cores=1)
See iPsychCNV tutorial for more examples
http://biopsych.dk/iPsychCNV/tutorial.html
}
\author{
Marcelo Bertalan
}

