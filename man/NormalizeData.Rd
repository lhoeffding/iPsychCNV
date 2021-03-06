% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NormalizeData.R
\name{NormalizeData}
\alias{NormalizeData}
\title{Normalize Data}
\usage{
NormalizeData(Sample = Sample, ExpectedMean = 0, penalty = 60,
  Quantile = FALSE, QSpline = FALSE, sd = 0.18)
}
\value{
LRR normalized
}
\description{
NormalizeData: Normalize LRR.
}
\details{
Specifically designed to handle noisy data from amplified DNA on  Phenylketonuria (PKU) cards. The function is a pipeline using many subfunctions.
}
\author{
Marcelo Bertalan
}

