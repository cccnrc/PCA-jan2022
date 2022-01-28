###############################################
################ LOAD DATABASE ################
###############################################
library(haven)

DB_PATH <- '/home/enrico/manolo/PCA-jan2022/SECURE/db_jan2022.sav'
FP <- file.path(DB_PATH)
db0 <- read_sav(FP)
db0 <- as.data.frame( db0 )


###############################################
################ LOAD DATABASE ################
###############################################
### I changed ID and created a conversion table stored in SECURE (ID-conversion.tsv)
#     now I can simply load the converted DB with
DB_PATH <- '/home/enrico/manolo/PCA-jan2022/DB/db0.tsv'
db0 <- read.csv( DB_PATH, sep = '\t' )

###############################################
############### 2 STEP CLUSTER ################
###############################################
library(prcr)


###### 3 groups division
m3 <- create_profiles_cluster( db0, OBSCO1_50, OBSCO2_50, n_profiles = 3, linkage = "average" )
# m3 <- create_profiles_cluster(df, broad_interest, enjoyment, instrumental_mot, self_efficacy, n_profiles = 3)
plot_profiles(m3, to_center = TRUE)
m3DB <- na.omit( data.frame( lapply( m3, as.factor ) ) )
table( m3DB$cluster )

### add to db0
db0$TWOstep_cluster <- m3DB$cluster






###############################################
################ K MEANS CLUSTER ##############
###############################################
library(factoextra)

### keep only cluster analysis variables in the DB
db1 <- db0[ , c(2,3) ]

### calculate the cluster
set.seed(123)
km.db1 <- kmeans(db1, centers = 3, nstart = 10)
### get the means
aggregate(db1, by=list(cluster=km.db1$cluster), mean)
### add to dataframe
db0$K_cluster <- km.db1$cluster
### Visualize cluster
fviz_cluster( km.db1, db1, ellipse.type = "norm" )






####################################################
################ HIERARCHICAL CLUSTER ##############
####################################################
hc.cut <- hcut(db1, k = 3, hc_method = "complete")
### add to dataframe
db0$H_cluster <- hc.cut$cluster
# Visualize dendrogram
fviz_dend(hc.cut, show_labels = FALSE, rect = TRUE)
# Visualize cluster
fviz_cluster(hc.cut, ellipse.type = "convex")








####################################################
################ ADJUSTED RAND INDEX ###############
####################################################
library(pdfCluster)

### compare with Manolo
adj.rand.index(  db0$clusterfinale_catpcatwostep, db0$TWOstep_cluster )
adj.rand.index(  db0$clusterfinale_catpcatwostep, db0$K_cluster )
adj.rand.index(  db0$clusterfinale_catpcatwostep, db0$H_cluster )
### compare amongst them
adj.rand.index( db0$TWOstep_cluster, db0$K_cluster )
adj.rand.index( db0$TWOstep_cluster, db0$H_cluster )
adj.rand.index( db0$K_cluster, db0$H_cluster )
















### ENDc
