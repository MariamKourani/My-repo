source("http://bioconductor.org/biocLite.R")

biocLite("limma")
biocLite("cummeRbund")
library (cummeRbund)
library(limma)
library(edgeR)
install.packages('gplots')
library(gplots)
library(ggplot2)
require('RColorBrewer')
require('gridExtra')
install.packages("digest", dependencies = TRUE)
source("Tea_RSEM_limma_fun_MB_2.R")

# Reading the count matrix:

data <-read.table("Trinity_trans.counts.matrix", header=TRUE)
dim(data)

# Adjusting the columns names to contain the samples names only:

colnames(data) <- gsub("X", " ", colnames(data))
colnames(data)

# Filtering lowly expressed genes:

rowsToKeep <- rowSums(data > 20) >= 2 #(reduces the number of genes approx.to half)
RSEM <- data[rowsToKeep,]
dim(RSEM)

# Convert counts to DGEList object using the edgeR package (object used by edgeR to store
# count data):
dge <- DGEList(counts=RSEM)

# Plots before normalisation:

# 1-MDS
plotMDS(RSEM)

# 2-PCA 
PCAdata<-t(RSEM)
rownames(PCAdata)<-gsub("_C[123]", "_C", rownames(PCAdata))
rownames(PCAdata)<-gsub("_T[123]", "_T", rownames(PCAdata))
pca<- prcomp(PCAdata, retx=TRUE, center= F, scale=F)
scores<-pca$x
df_out <- as.data.frame(pca$x)
df_out$group <- sapply( strsplit(as.character(row.names(PCAdata)), "_"), "[[", 1 )

rownames(scores)<-rownames(PCAdata)

theme<-theme(panel.background = element_blank(),
             panel.border=element_rect(fill=NA),
             panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             strip.background=element_blank(),
             axis.text.x=element_text(colour="black"),
             axis.text.y=element_text(colour="black"),
             axis.ticks=element_line(colour="black"),
             plot.margin=unit(c(1,1,1,1),"line"),
             legend.text=element_text(size=12))
percentage <- round(pca$sdev / sum(pca$sdev) * 100, 2)
percentage <- paste( colnames(df_out), "(", paste( as.character(percentage), "%", ")", sep="") )

p<-ggplot(df_out,aes(x=PC1,y=PC2,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[1]) + ylab(percentage[2])
p<-p+ labs(color='Samples')
p

p<-ggplot(df_out,aes(x=PC1,y=PC3,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[1]) + ylab(percentage[3])
p<-p+ labs(color='Samples')
p

p<-ggplot(df_out,aes(x=PC2,y=PC3,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[2]) + ylab(percentage[3])
p<-p+ labs(color='Samples')
p

##################################################################
# Creating the design matrix:

Group<- factor(c("C_0H","C_0H","C_12H","C_12H","C_12H","T_12H","T_12H","T_12H"))

design<- model.matrix(~0 + Group, (RSEM))

colnames(design) <- levels(Group)

colnames(design)<- gsub("Group","", colnames(design))

# Applying Voom Transformation
# (normalize = "quantile"- between array normalisation to deal with the noisy data)
# use voomWithQualityWeight function to down weight the outlier sample)

v<-voomWithQualityWeights(RSEM, design, plot=T, normalize.method="quantile") 

# Plots after normalisation

# 1-MDS

plotMDS(v$E)

# 2-PCA plot after normalisation (outlier sample is better clustered)

PCAdata<-t(v$E)
rownames(PCAdata)<-gsub("_C[123]", "_C", rownames(PCAdata))
rownames(PCAdata)<-gsub("_T[123]", "_T", rownames(PCAdata))
pca<- prcomp(PCAdata, retx=TRUE, center= F, scale=F)
scores<-pca$x
df_out <- as.data.frame(pca$x)
df_out$group <- sapply( strsplit(as.character(row.names(PCAdata)), "_"), "[[", 1 )

rownames(scores)<-rownames(PCAdata)

theme<-theme(panel.background = element_blank(),
             panel.border=element_rect(fill=NA),
             panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             strip.background=element_blank(),
             axis.text.x=element_text(colour="black"),
             axis.text.y=element_text(colour="black"),
             axis.ticks=element_line(colour="black"),
             plot.margin=unit(c(1,1,1,1),"line"),
             legend.text=element_text(size=12))
percentage <- round(pca$sdev / sum(pca$sdev) * 100, 2)
percentage <- paste( colnames(df_out), "(", paste( as.character(percentage), "%", ")", sep="") )

p<-ggplot(df_out,aes(x=PC1,y=PC2,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[1]) + ylab(percentage[2])
p<-p+ labs(color='Samples')
p

p<-ggplot(df_out,aes(x=PC1,y=PC3,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[1]) + ylab(percentage[3])
p<-p+ labs(color='Samples')
p

p<-ggplot(df_out,aes(x=PC2,y=PC3,color=row.names(PCAdata) ))
p<-p+geom_point()+theme+ xlab(percentage[2]) + ylab(percentage[3])
p<-p+ labs(color='Samples')
p

###############################################

# Differential expression: voom approach 
# Making contrast matrix (To test the differences b/w conditions)
# In order to specify which comparisons need to be tested test)

contrast.matrix <- makeContrasts(C12VsC0= C_12H - C_0H, T12VsC0= T_12H - C_0H,
                                 T12VsC12= T_12H - C_12H,levels=design)

# Fitting the linear model:

fit <- lmFit(v, design)

# Extracting the linear model fit for the contrast:

fit.cont <- contrasts.fit(fit, contrast.matrix)
fit.cont <- eBayes(fit.cont, trend=TRUE)

######################################
# Obtaining full lists of differential expression transcripts per each contrast
# (without applying any filters)

deg_C12VsC0 <- topTable(fit.cont, adjust.method="BH", coef="C12VsC0", number=Inf)
deg_T12VsC0 <- topTable(fit.cont, adjust.method="BH", coef="T12VsC0", number=Inf)
deg_T12VsC12 <- topTable(fit.cont, adjust.method="BH", coef="T12VsC12", number=Inf)

# Converting rownames into a column called "ID":

library(data.table)

setDT(deg_C12VsC0, keep.rownames = "ID")
setDT(deg_T12VsC0, keep.rownames = "ID")
setDT(deg_T12VsC12, keep.rownames = "ID")

# Annotations

# 1. Reading the annotation .txt file obtained from Blast:
annot = read.delim("AnnotatedData/mariam_MSc_blast_export.txt")

# 2. Writing it into csv file
write.table(annot, file="AnnotatedData/mariam_MSc_blast_export.csv",sep=",",col.names= TRUE)

# 3. Reading the csv file
annot.csv= read.csv(file = "AnnotatedData/mariam_MSc_blast_export.csv", header = T, sep= ",", stringsAsFactors = F)


# Merging contrast matrices (that contains all the DE transcripts) with annotations
# by the ID column:

deg_C12VsC0_annot <- merge(x = deg_C12VsC0, y = annot.csv, by.x = "ID",
                       by.y = "Sequence.Name", all.x = T, all.y = F)

deg_T12VsC0_annot <- merge(x = deg_T12VsC0, y = annot.csv, by.x = "ID",
                       by.y = "Sequence.Name", all.x = T, all.y = F)

deg_T12VsC12_annot <- merge(x = deg_T12VsC12, y = annot.csv, by.x = "ID",
                      by.y = "Sequence.Name", all.x = T, all.y = F)

# Choosing the columns of interest:

deg_C12VsC0_annot <- deg_C12VsC0_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
deg_T12VsC0_annot <- deg_T12VsC0_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
deg_T12VsC12_annot <- deg_T12VsC12_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]

# Examining the number of differentially expressed genes with a minimum log-FC = ±1
# Performing differential expression analysis using a fitted model, and the threshold 
# values for FDR and log-FC
# returnList=T, returns a list of matrices containing statistics for the DE genes
# corresponding to each contrast

genes<-getDEperContrast(fit.cont, fdr = 0.01, lfc=1, returnList = T)

# Preparing contrast matrices:

C12VsC0 <- genes[[1]][["deg"]]
T12VsC0 <- genes[[2]][["deg"]]
T12VsC12 <- genes[[3]][["deg"]]


# Merging filtered contrast matrices with annotations from Blast by the ID column:
# turn all.x = T when you have isoforms

C12VsC0_annot <- merge(x = C12VsC0, y = annot.csv, by.x = "ID",
                           by.y = "Sequence.Name", all.x = T, all.y = F)

T12VsC0_annot <- merge(x = T12VsC0, y = annot.csv, by.x = "ID",
                           by.y = "Sequence.Name", all.x = T, all.y = F)

T12VsC12_annot <- merge(x = T12VsC12, y = annot.csv, by.x = "ID",
                            by.y = "Sequence.Name", all.x = T, all.y = F)

# Choosing the columns of interest
C12VsC0_annot <- C12VsC0_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
T12VsC0_annot <- T12VsC0_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
T12VsC12_annot <- T12VsC12_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]


# Writing contrast matrices into csv files
write.csv(C12VsC0_annot, file = "C12VsC0_annot.csv")
write.csv(T12VsC0_annot, file = "T12VsC0_annot.csv")
write.csv(T12VsC12_annot, file = "T12VsC12_annot.csv")


# Extracting IDs from contrast matrices
C12VsC0_ID <- C12VsC0_annot[ ,1, drop= FALSE]
T12VsC0_ID <- T12VsC0_annot[ ,1, drop= FALSE]
T12VsC12_ID <- T12VsC12_annot[ ,1, drop= FALSE]


# write IDs into csv files
write.table(C12VsC0_ID, file="C12VsC0_ID.csv",sep=",",col.names= TRUE)
write.table(T12VsC0_ID, file="T12VsC0_ID.csv",sep=",",col.names= TRUE)
write.table(T12VsC12_ID, file="T12VsC12_ID.csv",sep=",",col.names= TRUE)


# Reading annotations With KEGG (.txt) file
annotWithKEGG <- read.delim("Results/blast2go_kegg_20180920_2319_mariam_MSc.txt")

# Converting it into a matrix
annotWithKEGG_m <-as.matrix(annotWithKEGG)


# Merging KEGG pathways with the annotated contrasts
C12VsC0_annot.KEGG <- merge(x = C12VsC0_annot, y = annotWithKEGG_m, by.x = "ID",
                                by.y = "Seq", all.x = T, all.y = F)

T12VsC0_annot.KEGG <- merge(x = T12VsC0_annot, y = annotWithKEGG_m, by.x = "ID",
                                by.y = "Seq", all.x = T, all.y = F)

T12VsC12_annot.KEGG <- merge(x = T12VsC12_annot, y = annotWithKEGG_m, by.x = "ID",
                                 by.y = "Seq", all.x = T, all.y = F)


# Writing merged matrices into csv files
write.csv(C12VsC0_annot.KEGG, file = "C12VsC0_annot.KEGG.csv")
write.csv(T12VsC0_annot.KEGG, file = "T12VsC0_annot.KEGG.csv")
write.csv(T12VsC12_annot.KEGG, file = "T12VsC12_annot.KEGG.csv")

#########################################################################################
# Searching for transcripts encoding aroma & flavor related enzymes in the transcriptome
##########################################################################################

# Enzymes from the phenylpropanoid pathway in blast top hits:

# 1- Phenylalanine ammonia lyase (PAL) enzyme:
C12VsC0_annot.KEGG_PAL <- grep("Phenylalanine", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_PAL <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_PAL,])

T12VsC0_annot.KEGG_PAL <- grep("phenylalanine", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_PAL <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_PAL,])

T12VsC12_annot.KEGG_PAL<- grep("Phenylalanine", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_PAL <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_PAL,])

# 2- Cinnamate 4-hydroxylase /cinnamate 4-monoxygenase (C4H) enzyme:
C12VsC0_annot.KEGG_C4H <- grep("cinnamate", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_C4H <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_C4H,])

T12VsC0_annot.KEGG_C4H <- grep("cinnamate", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_C4H <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_C4H,])

T12VsC12_annot.KEGG_C4H<- grep("cinnamate", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_C4H <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_C4H,])

# 3- Four-Coumarate CoA ligase enzyme (4CL):
C12VsC0_annot.KEGG_4CL <- grep("coumarate", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_4CL <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_4CL,])

T12VsC0_annot.KEGG_4CL <- grep("coumarate", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_4CL <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_4CL,])

T12VsC12_annot.KEGG_4CL <- grep("coumarate", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_4CL <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_4CL,])

# 4- O-methyltransferases enzymes (OMTs):
C12VsC0_annot.KEGG_OMT <- grep("O-methyltransferase", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_OMT <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_OMT,])

T12VsC0_annot.KEGG_OMT <- grep("O-methyltransferase", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_OMT <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_OMT,])

T12VsC12_annot.KEGG_OMT<- grep("O-methyltransferase", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_OMT <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_OMT,])

# 5- Caffeoyl shikimate esterase (CSE) enzyme:
C12VsC0_annot.KEGG_CSE <- grep("Caffeoylshikimate", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_CSE <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_CSE,])

T12VsC0_annot.KEGG_CSE <- grep("Caffeoylshikimate", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_CSE <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_CSE,])

T12VsC12_annot.KEGG_CSE <- grep("Caffeoylshikimate", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_CSE <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_CSE,])

# 6- Cinnamoyl-CoA Reductase (CCR) enzyme:
C12VsC0_annot.KEGG_CCR <- grep("Cinnamoyl-CoA reductase", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_CCR <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_CCR,])

T12VsC0_annot.KEGG_CCR <- grep("Cinnamoyl-CoA reductase", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_CCR <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_CCR,])

T12VsC12_annot.KEGG_CCR <- grep("Cinnamoyl-CoA reductase", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_CCR <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_CCR,])

# Terpene enzymes

# 1-Linalool Synthase:
C12VsC0_annot.KEGG_LS <- grep("linalool", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_LS <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_LS,])

T12VsC0_annot.KEGG_LS <- grep("linalool", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_LS <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_LS,])

T12VsC12_annot.KEGG_LS <- grep("linalool", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_LS <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_LS,])

# 2-Nerolidol Synthase:
C12VsC0_annot.KEGG_NS <- grep("nerolidol", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_NS <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_NS,])

T12VsC0_annot.KEGG_NS <- grep("nerolidol", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_NS <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_NS,])

T12VsC12_annot.KEGG_NS <- grep("nerolidol", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_NS <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_NS,])

# 3-Santalene Synthase:
C12VsC0_annot.KEGG_SS <- grep("santalene", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_SS <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_SS,])

T12VsC0_annot.KEGG_SS <- grep("santalene", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_SS <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_SS,])

T12VsC12_annot.KEGG_SS <- grep("santalene", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_SS <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_SS,])

# UDP-glycosyltransferase enzymes:

C12VsC0_annot.KEGG_GT <- grep("UDP-glycosyltransferase", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_GT <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_GT,])

T12VsC0_annot.KEGG_GT <- grep("UDP-glycosyltransferase", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_GT <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_GT,])

T12VsC12_annot.KEGG_GT<- grep("UDP-glycosyltransferase", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_GT <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_GT,])

# plotting UDP-glycosyltransferase

x11()

# Take only the name of the top enzyme from blast top hits column:
enzyme_name_GT_T12VsC0 = strsplit2(T12VsC0_annot.KEGG_GT$Blast.Top.Hit.Description..HSP., split = "\\[")[,1]

glycosyltransferase_T12VsC0_Plot <- ggplot(T12VsC0_annot.KEGG_GT, aes(x=ID, y = logFC, fill = enzyme_name_GT_T12VsC0)) + geom_bar(stat="identity", position=position_dodge())
glycosyltransferase_T12VsC0_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("UDP-glycosyltransferase_T12VsC0")

# Take only the name of the top enzyme from blast top hits column:
enzyme_name_GT_T12VsC12 = strsplit2(T12VsC12_annot.KEGG_GT$Blast.Top.Hit.Description..HSP., split = "\\[")[,1]

glycosyltransferase_T12VsC12_Plot <- ggplot(T12VsC12_annot.KEGG_GT, aes(x=ID, y = logFC, fill = enzyme_name_GT_T12VsC12)) + geom_bar(stat="identity", position=position_dodge())
glycosyltransferase_T12VsC12_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("UDP-glycosyltransferase_T12VsC12")

grid.arrange(glycosyltransferase_T12VsC0_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("UDP-glycosyltransferase_T12VsC0"), glycosyltransferase_T12VsC12_Plot
             +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("UDP-glycosyltransferase_T12VsC12"), nrow = 2)


# Beta-glucosidase enzymes:
C12VsC0_annot.KEGG_BG <- grep("beta-glucosidase", C12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
C12VsC0_annot.KEGG_BG <- (C12VsC0_annot.KEGG[C12VsC0_annot.KEGG_BG,])

T12VsC0_annot.KEGG_BG <- grep("beta-glucosidase", T12VsC0_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC0_annot.KEGG_BG <- (T12VsC0_annot.KEGG[T12VsC0_annot.KEGG_BG,])

T12VsC12_annot.KEGG_BG <- grep("beta-glucosidase", T12VsC12_annot.KEGG$Blast.Top.Hit.Description..HSP., ignore.case = TRUE)
T12VsC12_annot.KEGG_BG <- (T12VsC12_annot.KEGG[T12VsC12_annot.KEGG_BG,])

# Plotting Beta-glucosidase enzymes

x11()

# Take only the name of the top enzyme from blast top hits column:
enzyme_name_BG_T12VsC0 <- strsplit2(T12VsC0_annot.KEGG_BG$Blast.Top.Hit.Description..HSP., split = "\\[")[,1]


B_glucosidase_T12VsC0_Plot <- ggplot(T12VsC0_annot.KEGG_BG, aes(x=ID, y = logFC, fill = enzyme_name_BG_T12VsC0)) + geom_bar(stat="identity", position=position_dodge())
B_glucosidase_T12VsC0_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("B_glucosidase_T12VsC0")

# Take only the name of the top enzyme from blast top hits column:
enzyme_name_BG_T12VsC12 <- strsplit2(T12VsC12_annot.KEGG_BG$Blast.Top.Hit.Description..HSP, split = "\\[")[,1]

B_glucosidase_T12VsC12_Plot <- ggplot(T12VsC12_annot.KEGG_BG, aes(x=ID, y = logFC, fill = enzyme_name_BG_T12VsC12)) + geom_bar(stat="identity", position=position_dodge())
B_glucosidase_T12VsC12_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("B_glucosidase_T12VsC12")

grid.arrange(B_glucosidase_T12VsC0_Plot +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("B_glucosidase_T12VsC0"), B_glucosidase_T12VsC12_Plot
             +  theme(text = element_text(size=9),axis.text.x = element_text(angle=90, vjust=1)) + ggtitle("B_glucosidase_T12VsC12"), nrow = 2)


















