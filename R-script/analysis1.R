####################################################
################ LOAD SAFE DATABASE ################
####################################################
### to generate this safe DB have a look at analysis1-encrypt.R
DB_SAFE_PATH <- '/home/enrico/manolo/PCA-jan2022/DB/db_01feb20222.tsv'
db0 <- read.csv( DB_SAFE_PATH, sep = '\t', header = T )

####################################################
################ FACTOR ANALYSIS MD ################
####################################################
### based on discussions, e.g. https://rpkgs.datanovia.com/factoextra/  http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/
#     it looks like the best analysis for this dataset is Factor Analysis for Mixed Data: http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/115-famd-factor-analysis-of-mixed-data-in-r-essentials/
#     Multiple Component Analysis (MCA) would require ONLY categorical variables: http://factominer.free.fr/index.html
library(FactoMineR)
library(factoextra)

COL_2REMOVE <- c( 'ID', 'Dateofbirth', 'OBSCO1_50', 'OBSCO2_50', 'clusterfinale_catpcatwostep' )
db1 <- db0[ , -which(names(db0) %in% COL_2REMOVE ) ]

### factorize variables (not Ageofepilepsyonsetyears)
i=1
while(i < ncol(db1))
{
  i=i+1
  db1[,i] = as.factor(db1[,i])
}

famd0 <- FAMD(db1, graph = FALSE)

### plot percentage of inertia explained by each FAMD dimensions
fviz_screeplot( famd0 )

### get results per sample
FAMD_SAMPLE <- get_famd_ind( famd0 )

### to identify the best number of components we should define the cumulative variance that
#     we want to explain: https://www.mikulskibartosz.name/pca-how-to-choose-the-number-of-components/
#     to perform this with FAMD() I have to look at famd0$eig 3rd column (cumulative percentage of variance)
#     with 10 components we get to 92%, so we should keep at least those
famd0 <- FAMD(db1, ncp = 10, graph = FALSE)

### plot percentage of inertia explained by each FAMD dimensions
fviz_screeplot( famd0 )

### when I will have cluster results I can plot individulas based on cluster groups with:
fviz_mfa_ind(famd0,
             label = "none", # hide individual labels
             habillage = db2$K_cluster # color by groups
             )

### extract values
famd0.IND <- famd0$ind$coord
db2 <- cbind( db1, famd0.IND )



###############################################
################ K MEANS CLUSTER ##############
###############################################

### best number of clusters seems to be 4 (silhouette)
fviz_nbclust(famd0.IND, kmeans, method='silhouette')

### calculate the clusters
set.seed(123)
KM.famd0.IND <- kmeans(famd0.IND, centers = 4)
### add to dataframe
db2$K_cluster <- KM.famd0.IND$cluster
### Visualize cluster
fviz_cluster( KM.famd0.IND, famd0.IND, ellipse.type = "norm" )


###############################################
############### 2 STEP CLUSTER ################
###############################################
library(prcr)


###### 4 groups division
m4 <- create_profiles_cluster( db2, Dim.1, Dim.2, Dim.3, Dim.4, Dim.5, Dim.6, Dim.7, Dim.9, Dim.9, Dim.10, n_profiles = 4, distance_metric = "squared_euclidean", linkage = "complete" )
# m4 <- create_profiles_cluster(df, broad_interest, enjoyment, instrumental_mot, self_efficacy, n_profiles = 3)
plot_profiles(m4, to_center = TRUE)
m4DB <- na.omit( data.frame( lapply( m4, as.factor ) ) )
table( m4DB$cluster )

### add to db0
db2$TWOstep_cluster <- m4DB$cluster


####################################################
################ HIERARCHICAL CLUSTER ##############
####################################################
# Visualize silhouette: best number seems 6
fviz_nbclust(famd0.IND, hcut, method='silhouette')

### create clusters (try with 4 variables)
hc.cut <- hcut( famd0.IND, k = 4, hc_method = "ward.D2")
### add to dataframe
db2$H_cluster <- hc.cut$cluster
# Visualize dendrogram
fviz_dend(hc.cut, show_labels = FALSE, rect = TRUE)
# Visualize cluster
fviz_cluster(hc.cut, ellipse.type = "convex")
















####################################################
################## COMPARE CLUSTERS ################
####################################################
library(pdfCluster)

### compare with Manolo
adj.rand.index(  db0$clusterfinale_catpcatwostep, db2$TWOstep_cluster )
adj.rand.index(  db0$clusterfinale_catpcatwostep, db2$K_cluster )
adj.rand.index(  db0$clusterfinale_catpcatwostep, db2$H_cluster )
### compare amongst them
adj.rand.index( db2$TWOstep_cluster, db2$K_cluster )
adj.rand.index( db2$TWOstep_cluster, db2$H_cluster )
adj.rand.index( db2$K_cluster, db2$H_cluster )




















####################################################
#################### SAVE CLUSTERS #################
####################################################
### add Manolo's
db2$manu_2step <- factor(db0$clusterfinale_catpcatwostep)

DB_CLUSTER_PATH <- '/home/enrico/manolo/PCA-jan2022/DB/db_01feb20222-clusterEC.tsv'
write.table( db2, file = DB_CLUSTER_PATH, quote = F, row.names = F, col.names = T, sep = '\t' )






















### ENDc
