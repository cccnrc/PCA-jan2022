###############################################
################ LOAD DATABASE ################
###############################################
library(haven)

DB_PATH <- '/home/enrico/manolo/PCA-jan2022/SECURE/db_01feb20222.sav'
FP <- file.path(DB_PATH)
db0 <- read_sav(FP)
db0 <- as.data.frame( db0 )


###########################################################
################ ENCRYPT SENSITIVE COLUMNS ################
###########################################################
library(encryptr)

### this needs to generates public and private RSA keys that I store in SECURE/encryptr-KEYS/ BAlt0ne!!!
KEYS_DIR <- '/home/enrico/manolo/PCA-jan2022/SECURE/encryptr-KEYS'
# genkeys(file.path(KEYS_DIR, "id_rsa"))      ### generate only FIRST time you use this

library(dplyr)
db0_encrypt = db0 %>%
                encrypt(ID, Dateofbirth, public_key_path = file.path(KEYS_DIR, "id_rsa.pub") )

### now I can write down the encrypted DB to load directly for future analysis
DB_SAFE_PATH <- '/home/enrico/manolo/PCA-jan2022/DB/db_01feb20222.tsv'
write.table( db0_encrypt, file = DB_SAFE_PATH, quote = F, row.names = F, col.names = T, sep = '\t' )
