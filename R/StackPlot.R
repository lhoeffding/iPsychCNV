##' stack.plot produces stacked plots of cnv calls from multiple samples
##' for a specific lucus. For each sample two tracks are plotted
##' representing the intensity and the B-allel frequency.
##'
##' @title Stacked plots of multiple sample of a specified loci
##' @param Pos Position of the loci to plot in the form chr21:1050000-1350000
##' @param IDs List of IDs to plot
##' @param CNVs Data.frame containing the cnvs called on the samples
##' @param PathRawData The path to the raw data files contining LRR and BAF values to plot
##' @param Highlight Position of a specific region to be highlighted, in the form chr21:1050000-1350000
##' @return A png plot of the specified loci
##' @author Johan Hilge Thygesen
##' @export
##' @examples
##' mockCNV <- MockData(N=5, Type="Blood", Cores=1)
##' cnvs <- iPsychCNV(PathRawData=".", Cores=1, Pattern="^MockSample*", Skip=0)
##' stack.plot(Pos="chr21:28338230-46844965", Ids=unique(cnvs$ID), PathRawData=".", CNVs=cnvs, Highlight = "chr21:36653812-39117308")
library(data.table)

### Function to verify position integrity
verify.pos <- function(Pos, argument = "Position"){
    regmatch <- regexpr("chr[1-9X]{1,2}:[0-9]+-[0-9]+", Pos) # Regexp test of position
    if(attr(regmatch, "match.length") == nchar(Pos)) { # Split postion
        chr <- sub("chr", "", unlist(strsplit(Pos,":"))[1])
        Pos <- unlist(strsplit(Pos,":"))[2]
        x.start <- as.numeric(unlist(strsplit(Pos,"-"))[1])
        x.stop <- as.numeric(unlist(strsplit(Pos,"-"))[2])
        ## Test if start is smaller than stop
        if(x.stop<=x.start) {  
            stop(paste(argument,"stop is <= start /n/n"))
        }
    }else{
        stop(paste("the",argument,"position argument is not valid see --help"))
    }
    return(c(chr,x.start,x.stop))
}

stack.plot <- function(Pos, Ids, PathRawData, CNVs, Highlight = NULL){
    options(scipen=999) ## Disable scientific notation of positions

    ## Check and split position
    split.pos <- verify.pos(Pos)
    chr <- split.pos[1]
    reg.start <- as.numeric(split.pos[2])
    reg.stop <- as.numeric(split.pos[3])

    ## Check ids
    if(length(Ids) < 1) {
        stop("Please specify minimum ID")
    }

    ## Check highlight position if specified
    if (length(Highlight) > 0){
        split.pos <- verify.pos(sub("--highlight ", "", Highlight)) 
        high.chr <- split.pos[1]
        high.start <- as.numeric(split.pos[2])
        high.stop <- as.numeric(split.pos[3])
        if(high.chr!=chr){
            stop("The highlight chromosome does not match the chromosome of the given position")
        }
    }

    ## Plot variables
    space <- 0.5
    box <- 1
    pr.page <- 5
    datestamp <- gsub(":",".",unlist(strsplit(as.character(Sys.time())," "))[2])
    basename <- paste("chr",chr,"-",reg.start,"-",reg.stop, "_at_", datestamp, sep="")
    xrange <- range(reg.start,reg.stop)
    yrange <- range(0, pr.page*(2*box+2*space))
    x <- 1 # start with id 1
    i <- 1 # we start with the 1 person on each page
    page.count <- 1 # start with page 1

    ## Loop over each ID and plot away
    while(x < length(Ids)){
        ## If more than pr.page individuals are plotted change the file name
        if(page.count > 1){outname <- paste(basename, "_page-", page.count, sep="")
                       }else{
                           outname <- basename
                       }
        png(paste(outname, ".png", sep=""), width=1024, height=768)
        plot(xrange, yrange, type="n", yaxt='n', xaxt='n', xlab="", ylab="", main = Pos, cex.main=0.6)
        axis(3, at=axTicks(3),labels=formatC(axTicks(3), format="d", big.mark='.'))
        topY <- max(yrange) - space
        ## CREATE a new plot after pr.page individuals have been plotted
        while(i <= pr.page) {
            id.file <- paste(PathRawData, Ids[x], sep="/")
            if(!file.exists(id.file)) {
                print(paste("NO intensity files exsists called: ", id.file))
            }else{
                print(paste("Plotting",Ids[x]))
                id <- ReadSample(id.file, chr=chr)
                id <- id[which(id[,3] > reg.start & id[,3] < reg.stop), ]
                ## Trim intensities to a range between 0.5:-0.5
                if(any(id[,4] > 1, na.rm=T)) { id[which(id[,4] > 1), 4] <- 1 }
                if(any(id[,4] < -1, na.rm=T)) { id[which(id[,4] < -1), 4] <- -1 }
                ## Set all CN-markers to NA (as they all have the non-usable value of 2) ONLY REALLY FOR AFFY DATA 
                if(any(id[,5] == 2, na.rm=T)) { id[which(id[,5] == 2), 5] <- NA }
                ## Define plot area
                if(nrow(id) > 1){
                    text(reg.stop-(reg.stop-reg.start)/2, topY + (space/3), paste("ID:",Ids[x]),lwd=1.5) ## Plot ID name
                    ## Plot Log R ratio and Intensity boxes
                    rect(reg.start, topY-box, reg.stop, topY, col="#ffe2e2", border= F) 
                    rect(reg.start, topY-(2*box+(space/2)), reg.stop, topY-(box+(space/2)), col="#e5e2ff", border= F)
                    ## Draw --Highlite box
                    if(length(Highlight) > 0) {
                        segments(high.start, topY-(2*box+(space/2)), high.start, topY, col="black",lwd=1.5) # Start
                        segments(high.stop, topY-(2*box+(space/2)), high.stop, topY, col="black",lwd=1.5) # Stop
                    }
                    ## Draw all CNV Calls that match alias, chr and fall within region
                    match <- CNVs[which(CNVs[,"ID"]==Ids[x] & CNVs[,"Chr"] == chr & CNVs[,"Start"] <= reg.stop & CNVs[,"Start"] >= reg.start),]
                    if(nrow(match)>0) {
                        ## do not draw cnv boxes outside of plot
                        if(any(match[,"Start"]<reg.start)) { match[which(match[,"Start"] < reg.start),"Start"] <- reg.start } 
                        if(any(match[,"Stop"]>reg.stop)) { match[which(match[,"Stop"] > reg.stop),"Stop"] <- reg.stop }
                        for(j in 1:nrow(match)) {
                            if(match[j,"CN"]>2){ rect(match[j,"Start"],topY-(2*box+(space/2)),match[j,"Stop"],topY,border="#2ef63c",lwd=2) }
                            if(match[j,"CN"]<2){ rect(match[j,"Start"],topY-(2*box+(space/2)),match[j,"Stop"],topY,border="#ff0000",lwd=2) }
                        }
                    }
                    ## Plot Log R ratio and Intestity points
                    points(id[,3], (id[,4]/2) + (topY-(0.5*box)), pch=20, cex=0.5, col = "darkred") 
                    points(id[,3], id[,5] + (topY-2*box-(space/2)), pch=20, cex=0.5, col = "darkblue")
                    ## Draw center line in boxs (x0, y0, x1, y1)
                    segments(reg.start, topY-(box/2), reg.stop, topY-(box/2), col="red") 
                    segments(reg.start, (topY-1.5*box-(space/2)), reg.stop, (topY-1.5*box-(space/2)), col="blue")
                    ## Calc new Y-top spot 
                    topY <- topY-(2*box+1.5*space)
                    
                }else{
                    print(paste("No data available at this loci for",Ids[x]))
                }
            }
            ## increment
            i <- i + 1
            if(x < length(Ids)){ x <- 1 + x}
            else{
                break
            }
        }
        page.count <- page.count + 1
        i <- 1 ## start with person 1 on the first page
        dev.off()
    }
}