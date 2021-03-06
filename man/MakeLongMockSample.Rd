% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MakeLongMockSample.R
\name{MakeLongMockSample}
\alias{MakeLongMockSample}
\title{iPsychCNV}
\usage{
MakeLongMockSample(CNVDistance = 1000, Type = c(0, 1, 2, 3, 4),
  Mean = c(-0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, 0.2, 0.3, 0.4, 0.5,
  0.6, 0.7, 0.8, 0.9), Size = c(100, 200, 300, 400, 500, 600, 700, 800, 900,
  1000))
}
\value{
Data frame with CNVs predicted.
}
\description{
iPsychCNV: Find Copy Number Variation (CNV) from SNP genotyping arrays.
}
\details{
Specifically designed to handle noisy data from amplified DNA on  Phenylketonuria (PKU) cards. The function is a pipeline using many subfunctions.
}
\author{
Marcelo Bertalan
}

