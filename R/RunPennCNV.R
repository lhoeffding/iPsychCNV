RunPennCNV <- function(PathRawData = "~/CNVs/MockData/PKU/Data", Pattern="*.tab", Cores=20, Skip=0, Normalization=TRUE, PFB="Mock.pfb")
{
	library(parallel)
	Files <- list.files(path=PathRawData, pattern=Pattern, full.names=TRUE, recursive=TRUE)
	write.table(Files, "Mock.List.Files.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
		
	if(is.na(PFB))
	{
		Command <- "/media/NeoScreen/NeSc_home/share/Programs/penncnv/compile_pfb.pl -listfile ./Mock.List.Files.txt -output Mock.pfb"
		system(Command)
		PFB <- "Mock.pfb"
	}
	

	Res <- mclapply(Files, mc.cores=Cores, mc.preschedule = FALSE, function(X) 
	{
		cat(X, "\n")
		ID <- tail(unlist(strsplit(X, "/")),n=1)
		CNV <- ReadCNV(X, skip=Skip, LCR=FALSE)
		
		if(Normalization)
		{
			CNV <- NormalizeData(CNV, ExpectedMean=0, DF=NA, FALSE)
		}
		
		Input <- paste(PathRawData, "/", ID, ".penncnv.in", sep="", collapse="")
		write.table(CNV, sep="\t", quote=FALSE, row.names=FALSE, file=Input)
		
		Output <- paste(ID, ".penncnv.out", sep="", collapse="")
		Command <- paste("/media/NeoScreen/NeSc_home/share/Programs/penncnv/detect_cnv.pl -test -minsnp 28 --minlength 10 --confidence -hmm /media/NeoScreen/NeSc_home/share/Programs/penncnv/lib/hhall.hmm -pfb ./Mock.pfb", Input, "-log logfile -out", Output, sep=" ", collapse="")
		cat(Command, "\n")
		system(Command)

		return(Output)
	})

	system("cat *.penncnv.out > All_Mock.penncnv.raw")
	system("clean_cnv.pl combineseg All_Mock.penncnv.raw --signalfile /media/NeoScreen/NeSc_home/bertalan/CNVs/MockData/PKU/SNP.Position.tab --fraction 0.2 --bp --output Merged.cnv")
	system(	"~/CNV/Scripts/Penn2Tab.pl < Merged.cnv > Merged.cnv.tab")

	tmp <- read.table("Merged.cnv.tab", sep="\t", header=TRUE, stringsAsFactors=FALSE)
	ID <- sapply(tmp$File, function(X){ ID <- tail(unlist(strsplit(X, "/")),n=1)  })
	ID2 <- sapply(ID, function(X){ unlist(strsplit(X, ".penncnv."))[1]  })
	tmp$ID <- ID2 
	return(tmp)
}