
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

# Reading the genes count matrix
data <-read.table("Trinity_gene.counts.matrix", header=TRUE)
dim(data)

# Adjusting the columns names to contain the samples names only
colnames(data) <- gsub("X", " ", colnames(data))
colnames(data)

# Filtering lowly expressed genes

rowsToKeep <- rowSums(data > 20) >= 2 #(reduces the number of genes approx.to half)
RSEM <- data[rowsToKeep,]
dim(RSEM)


# Converting counts to DGEList object using the edgeR package (object used by edgeR to store
# count data.)
dge <- DGEList(counts=RSEM)


# Plots before normalisation

# 1-MDS
plotMDS(RSEM)

# 2-PCA (outlier sample is obvious)
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


# Creating the design matrix

Group<- factor(c("C_0H","C_0H","C_12H","C_12H","C_12H",
                 "T_12H","T_12H","T_12H"))

design<- model.matrix(~0 + Group, (RSEM))

colnames(design) <- levels(Group)

colnames(design)<- gsub("Group","", colnames(design))

# Applying voom Transformation
# (normalize="quantile"- between array normalisation to deal with the noisy data)
# use voomWithQualityWeight function to down weight the outlier sample)

v<-voomWithQualityWeights(RSEM, design, plot=T, normalize.method="quantile") 

# Plots after normalisation

# 1-MDS
plotMDS(v$E)

# 2-PCA plot after normalisation (outlier sample is better clustered!)
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



##########################################
# Differential expression: voom approach 
# Making contrast matrix (To test the differences b/w conditions)
# In order to specify which comparisons need to be tested test)

contrast.matrix <- makeContrasts(C12VsC0_genes= C_12H - C_0H,
                                 T12VsC0_genes= T_12H - C_0H,
                                 T12VsC12_genes= T_12H - C_12H,levels=design)

# Fitting the linear model
fit <- lmFit(v, design)

# Extracting the linear model fit for the contrast
fit.cont <- contrasts.fit(fit, contrast.matrix)
fit.cont <- eBayes(fit.cont, trend=TRUE)

# Examining the number of differentially expressed genes with a minimum log-FC = ±1
# Performing differential expression analysis using a fitted model, and the threshold 
# values for FDR and log-FC
# returnList=T, returns a list of matrices containing statistics for the DE genes
# corresponding to each contrast

genes<-getDEperContrast(fit.cont, fdr = 0.01, lfc=1,returnList = T)

# Preparing the contrast matrices
C12VsC0_genes <- genes[[1]][["deg"]]
T12VsC0_genes <- genes[[2]][["deg"]]
T12VsC12_genes <- genes[[3]][["deg"]]

# Reading the annotation .txt file
annot = read.delim("AnnotatedData/mariam_MSc_blast_export.txt")

# Sorting the gene ID in contrasts to match the sequence name in annotation  
annot$Sequence.Name <- gsub("_i[123456789]", "", annot$Sequence.Name)
annot.genes<- annot[!duplicated(annot$Sequence.Name),]

annot.genes_m <- as.matrix(annot.genes)

# Merging contrast matrices with annotation from Blast by the ID column:
# turn all.x = T when you use isoforms

C12VsC0_genes_annot <- merge(x = C12VsC0_genes, y = annot.genes_m, by.x = "ID",
                           by.y = "Sequence.Name", all.x = T, all.y = F)

T12VsC0_genes_annot <- merge(x = T12VsC0_genes, y = annot.genes_m, by.x = "ID",
                           by.y = "Sequence.Name", all.x = T, all.y = F)

T12VsC12_genes_annot <- merge(x = T12VsC12_genes, y = annot.genes_m, by.x = "ID",
                            by.y = "Sequence.Name", all.x = T, all.y = F)

# Choosing the columns of interest
C12VsC0_genes_annot <- C12VsC0_genes_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
T12VsC0_genes_annot <- T12VsC0_genes_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]
T12VsC12_genes_annot <- T12VsC12_genes_annot[ ,c(1:3,5,8,10:12,25:29,31:35)]


#writing the contrast matrices into files
write.csv(C12VsC0_genes_annot, file = "C12VsC0_genes_annot.csv")
write.csv(T12VsC0_genes_annot, file = "T12VsC0_genes_annot.csv")
write.csv(T12VsC12_genes_annot, file = "T12VsC12_genes_annot.csv")


# Extracting IDs from the contrast matrix
C12VsC0_geneID <- C12VsC0_genes_annot[ ,1, drop= FALSE]
T12VsC0_geneID <- T12VsC0_genes_annot[ ,1, drop= FALSE]
T12VsC12_geneID <- T12VsC12_genes_annot[ ,1, drop= FALSE]


# writing ID files into csv 
write.table(C12VsC0_geneID, file="C12VsC0_geneID.csv",sep=",",col.names= TRUE)
write.table(T12VsC0_geneID, file="T12VsC0_geneID.csv",sep=",",col.names= TRUE)
write.table(T12VsC12_geneID, file="T12VsC12_geneID.csv",sep=",",col.names= TRUE)

# Reading the annotation with KEGG (.txt) file
annotWithKEGG <- read.delim("blast2go_kegg_20180920_2319_mariam_MSc.txt")

# Sorting the gene ID in in KEGG annotation to match sequence ID in annotated sequence
annotWithKEGG$Seq <- gsub("_i[123456789]", "", annotWithKEGG$Seq)
annotWithKEGG.genes<- annotWithKEGG[!duplicated(annotWithKEGG$Seq),]

# Converting it into a matrix
annotWithKEGG_m <-as.matrix(annotWithKEGG.genes) 

# Merge KEGG pathways with the annotated contrasts
C12VsC0_genes_annot.KEGG <- merge(x = C12VsC0_genes_annot, y = annotWithKEGG_m, by.x = "ID",
                                by.y = "Seq", all.x = T, all.y = F)

T12VsC0_genes_annot.KEGG <- merge(x = T12VsC0_genes_annot, y = annotWithKEGG_m, by.x = "ID",
                                by.y = "Seq", all.x = T, all.y = F)

T12VsC12_genes_annot.KEGG <- merge(x = T12VsC12_genes_annot, y = annotWithKEGG_m, by.x = "ID",
                                 by.y = "Seq", all.x = T, all.y = F)


# Writing merged matrices into files
write.csv(C12VsC0_genes_annot.KEGG, file = "C12VsC0_genes_annot.KEGG.csv")
write.csv(T12VsC0_genes_annot.KEGG, file = "T12VsC0_genes_annot.KEGG.csv")
write.csv(T12VsC12_genes_annot.KEGG, file = "T12VsC12_genes_annot.KEGG.csv")

