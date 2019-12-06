

source("http://bioconductor.org/biocLite.R")
install.packages('gplots')
library(gplots)
library(ggplot2)
require('RColorBrewer')
require('gridExtra')



###############################################################################################


#Reading exon expression (.dat) file
exonExp <- read.table("DTU_2.dexseq.results.dat", sep = "\t" , header= TRUE)



##TRINITY_DN86415_c0_g1
#######################

##plotting PAL individual isoforms:

#PAL isoform 2
exonExp_PAL_86415_c0_g1_i2 <- grep("TRINITY_DN86415_c0_g1_i2", exonExp$transcripts, ignore.case = TRUE)
exonExp_PAL_86415_c0_g1_i2 <- (exonExp[exonExp_PAL_86415_c0_g1_i2,])

PAL_i2 <- data.frame(row.names= (exonExp_PAL_86415_c0_g1_i2$featureID),
                     control= exonExp_PAL_86415_c0_g1_i2$log2fold_12H_0H,
                     treatment= exonExp_PAL_86415_c0_g1_i2$log2fold_12HT_0H)

##change data frame into matrix because barplot takes matrix
PAL_i2 <- do.call(rbind, PAL_i2)
##add column names
colnames(PAL_i2) <- (exonExp_PAL_86415_c0_g1_i2$featureID)
##plot the bar graph
x11()
par(mfrow=c(3,1))
PAL_i2_plot <- barplot(PAL_i2, main="Exon expression for PAL isoform 2", xlab="Exons",
            col=c("darkblue","grey"), beside = TRUE, ylim=c(0,2), legend.text = row.names(PAL_i2), 
            args.legend = list(x = "topleft", bty="n"))

#PAL isoform 3
exonExp_PAL_86415_c0_g1_i3 <- grep("TRINITY_DN86415_c0_g1_i3", exonExp$transcripts, ignore.case = TRUE)
exonExp_PAL_86415_c0_g1_i3 <- (exonExp[exonExp_PAL_86415_c0_g1_i3,])

PAL_i3 <- data.frame(row.names= (exonExp_PAL_86415_c0_g1_i3$featureID),
                     control= exonExp_PAL_86415_c0_g1_i3$log2fold_12H_0H,
                     treatment= exonExp_PAL_86415_c0_g1_i3$log2fold_12HT_0H)

##change data frame into matrix because barplot takes matrix
PAL_i3 <- do.call(rbind, PAL_i3)
##add column names
colnames(PAL_i3) <- (exonExp_PAL_86415_c0_g1_i3$featureID)
##plot the bar graph
PAL_i3_plot <- barplot(PAL_i3, main="Exon expression for PAL isoform 3", xlab="Exons",
                       col=c("darkblue","grey"), beside = TRUE, ylim=c(0,2), legend.text = row.names(PAL_i3), 
                       args.legend = list(x = "topleft", bty="n"))

#PAL isoform 5
exonExp_PAL_86415_c0_g1_i5 <- grep("TRINITY_DN86415_c0_g1_i5", exonExp$transcripts, ignore.case = TRUE)
exonExp_PAL_86415_c0_g1_i5 <- (exonExp[exonExp_PAL_86415_c0_g1_i5,])

PAL_i5 <- data.frame(row.names= (exonExp_PAL_86415_c0_g1_i5$featureID),
                     control= exonExp_PAL_86415_c0_g1_i5$log2fold_12H_0H,
                     treatment= exonExp_PAL_86415_c0_g1_i5$log2fold_12HT_0H)

## Change data frame into matrix because barplot takes matrix
PAL_i5 <- do.call(rbind, PAL_i5)
##add column names
colnames(PAL_i5) <- (exonExp_PAL_86415_c0_g1_i5$featureID)
##plot the bar graph
PAL_i5_plot <- barplot(PAL_i5, main="Exon expression for PAL isoform 5",
                       xlab="Exons", col=c("darkblue","grey"), beside = TRUE, ylim=c(0,2),
                       legend.text = row.names(PAL_i5), args.legend = list(x = "topleft", bty="n"))

##PAL- TRINITY_DN65913_c0_g1_i3
#------------------------------
exonExp_PAL_65913_c0_g1_i3 <- grep("TRINITY_DN65913_c0_g1_i3", exonExp$transcripts, ignore.case = TRUE)
exonExp_PAL_65913_c0_g1_i3 <- (exonExp[exonExp_PAL_65913_c0_g1_i3,])

PAL_65913_c0_g1_i3 <- data.frame(row.names= (exonExp_PAL_65913_c0_g1_i3$featureID),
                     control= exonExp_PAL_65913_c0_g1_i3$log2fold_12H_0H,
                     treatment= exonExp_PAL_65913_c0_g1_i3$log2fold_12HT_0H)

##change data frame into matrix because barplot takes matrix
PAL_65913_c0_g1_i3 <- do.call(rbind, PAL_65913_c0_g1_i3)
##add column names
colnames(PAL_65913_c0_g1_i3) <- (exonExp_PAL_65913_c0_g1_i3$featureID)
##plot the bar graph
x11()
par(mfrow=c(3,1))
PAL_65913_c0_g1_i3_plot <- barplot(PAL_65913_c0_g1_i3, main="Exon expression for PAL 65913_c0_g1_i3", xlab="Exons",
                       col=c("lightblue","grey"), beside = TRUE, ylim=c(0,2), legend.text = row.names(PAL_65913_c0_g1_i3), 
                       args.legend = list(x = "topleft", bty="n"))

# Add the text 
text(x = PAL_65913_c0_g1_i3_plot, y = PAL_65913_c0_g1_i3, labels = PAL_65913_c0_g1_i3 ,cex=1)

