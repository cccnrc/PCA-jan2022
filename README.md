# Manolo PCA

This is for the PCA-cluster analysis (January 2022)

---
## GitHub

To start the github repo:
```
git init
git add .
git commit -m "PCA Manolo v0.0"
git branch -M main
git remote add origin https://github.com/cccnrc/PCA-jan2022.git
git push -u origin main
```
for updates:
```
VERSION='0.5'
git add . && git commit -m "PCA Manolo v${VERSION}" && git push
```

---

## R analysis

Analysis scripts are stored in `R-script` folder.

First analysis on Manolo's PCA results (jan 2022):
```
atom R-script/analysis0.R
```

Second analysis on re-run PCA and clustering (feb 2022):
```
atom R-script/analysis1.R
```

---

## Database

For privacy reason, original DB are not uploaded here, but a version with converted IDs and no sensitive data is stored inside `DB` folder (`db0.tsv`)
