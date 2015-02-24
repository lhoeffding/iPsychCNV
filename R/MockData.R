MockData <- function(N=1)
{
	All <- sapply(1:N, function(SampleNum)
	{
		FileName <- paste("MockSample_", SampleNum, ".tab", sep="", collapse="")
		CNVsSize <- c(30, 50, 100, 150, 200, 300, 400, 500)
		Del <- seq(from=-0.15, to=-0.6, by=-0.05)
		Dup <- seq(from=0.15, to=0.6, by=0.05)
		BAFs <- seq(from=0, to=1, by=0.05) # 21
		BAF_Basic <- rep(0.02, 21)
		names(BAF_Basic) <- BAFs
		
		# BAF normal prob	
		BAF_Normal <- BAF_Basic
		BAF_Normal[c(1,2,20,21)] <- BAF_Normal[c(1,2,20,21)] + 0.38
		BAF_Normal[10:12] <- BAF_Normal[10:12] + 0.18
	
		# BAF Del prob
		BAF_Del <- BAF_Basic
		BAF_Del[c(1,2,20,21)] <- BAF_Del[c(1,2,20,21)] + 0.38
	
		# BAF Dup prob
		BAF_Dup <-  BAF_Basic
		BAF_Dup[c(1,2,20,21)] <- BAF_Dup[c(1,2,20,21)] + 0.38
		BAF_Dup[6:8] <- BAF_Dup[6:8] + 0.18 # 0.25 0.30 0.35, 
		BAF_Dup[15:17] <- BAF_Dup[15:17] + 0.18 # 0.7 0.75 0.8
	
		# BadSNPs
		BadSNPs <- c(0.01, 0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.09,0.08,0.01,0.15,0.05,0.05,0.10)
		names(BadSNPs) <- 1:22
		BadSNPIntensity <- seq(from=-0.1, to=-4, by=-0.1)
		BadSNPIntensityProb <- seq(from=0.5, to=0.11, by=-0.01)
	
		tmp <- sapply(unique(CNV$Chr), function(CHR)
		{
			subCNV <- subset(CNV, Chr %in% CHR)
			subCNV <- subCNV[order(subCNV$Position),]
			Position <- subCNV$Position
			SNP.Name <- subCNV$SNP.Name
	
			ChrLength <- nrow(subCNV)
			SD=sample(seq(from=0.1, to=0.5, by=0.1), 1, prob=c(0.2,0.35,0.3,0.07,0.03)) # chr sd
			X <- rnorm(ChrLength, sd=SD)
			BAF <- sample(BAFs, prob=BAF_Normal, replace=TRUE, size=length(X))
	
			# Adding ramdom noise
			t  <- 1:length(X)
			ssp <- spectrum(X, plot=FALSE)  
			per <- 1/ssp$freq[ssp$spec==max(ssp$spec)]
			reslm <- lm(X ~ sin(2*pi/per*t)+cos(2*pi/per*t))		
			X <- X + (fitted(reslm)*10)
	
			# Adding bad SNPs (in general because of GC and LCR)
			TotalNumberofBadSNPs <- round(length(X)*BadSNPs[CHR])
			BadSNPsIndx <- sample(1:length(X), TotalNumberofBadSNPs)
			NoiseSNP <- sample(BadSNPIntensity, prob=BadSNPIntensityProb, 1)
			X[BadSNPsIndx] <- X[BadSNPsIndx] + rnorm(TotalNumberofBadSNPs, sd=(SD*2), mean=NoiseSNP)
			#X <- round(X, digits=2)

			# Adding CNVs		
			NumCNVs <- ((round(length(X)/1000))-2)
			DF <- sapply(1:NumCNVs, function(i)
			{
				CN <- sample(c(1,3), 1) # CNV Type
				PositionIndx <- as.numeric(i) * 1000
				Size <- sample(CNVsSize, 1) # CNV Size
				if(CN == 1)
				{
					Impact <- sample(Del, 1)
					BAFCNV <- sample(BAFs, prob=BAF_Del, replace=TRUE, size=(Size+1))
				}
				if(CN == 3)
				{
					Impact <- sample(Dup, 1)
					BAFCNV <- sample(BAFs, prob=BAF_Dup, replace=TRUE, size=(Size+1))
				}
				## Changing GLOBAL VARIABLES ##
				X[PositionIndx:(PositionIndx+Size)] <<- X[PositionIndx:(PositionIndx+Size)] + Impact
				BAF[PositionIndx:(PositionIndx+Size)] <<- BAFCNV
				## Changing GLOBAL VARIABLES ##
				df <- data.frame(Start=Position[PositionIndx], Stop=Position[(PositionIndx+Size)], StartIndx=PositionIndx, StopIndx=(PositionIndx+Size), NumSNPs=Size, Chr=CHR, CNVmean=Impact, CN=CN, sd=SD, ID=FileName, NoiseSNP=NoiseSNP, BadSNPs=TotalNumberofBadSNPs, NumCNVs=NumCNVs, stringsAsFactors=FALSE)
				return(df)
			})
			df <- MatrixOrList2df(DF)
			df2 <- data.frame(SNP.Name=SNP.Name, Chr=rep(CHR, length(X)), Position=Position, Log.R.Ratio=X, B.Allele.Freq=BAF, stringsAsFactors=FALSE)
			return(list(LRR=df2, CNVs=df))
		})
		DF <- MatrixOrList2df(tmp["CNVs",])
		LRR <- MatrixOrList2df(tmp["LRR",])
	
		write.table(LRR, sep="\t", quote=FALSE, row.names=FALSE, file=FileName) 
		return(DF)
	})
	CNVs <- MatrixOrList2df(All)
	CNVs$Length <- CNVs$Stop -  CNVs$Start
	CNVs$CNVID <- 1:nrow(CNVs)
	return(CNVs)
}	