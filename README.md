# Partners Biobank Genomics Data QC

This repository details the quality control (QC) pipeline of the Partners Biobank genotype data (`N=36K as of Dec 2019`), which largely follows the recommendations described in:

Peterson, R. E., Kuchenbaecker, K., Walters, R. K., Chen, C.-Y., Popejoy, A. B., Periyasamy, S., et al. (2019). Genome-wide Association Studies in Ancestrally Diverse Populations: Opportunities, Methods, Pitfalls, and Recommendations. Cell, 179(3), 589–603. http://doi.org/10.1016/j.cell.2019.08.051


## Quality control pipeline

- QC for each genotyping batch (metrics not affected by ancestry; `scripts 01-04`)
	- SNP-level call rate >0.95
	- Sample-level call rate >0.98
	- SNP-level call rate >0.98
	- Maximum SNP-level missing rate difference between two batches < empirical threshold cutoff (e.g., 1%)

- Merge genotyping batches (`scripts 05-06`)
	- Remove duplicated SNPs
	- Remove monomorphic SNPs
	- Remove SNPs not confidently mapped (chr=0)

- Population assignment (`scripts 07-08`)
	- Select common, high-quality SNPs for population inference
		- SNP-level call rate >0.98
		- MAF >5%
		- Remove strand ambiguous SNPs and long-range LD regions (chr6:25-35Mb; chr8:7-13Mb inversion)
		- Prune to <100K independent SNPs
	- Identify individuals with European ancestry using selected SNPs
		- Run PCA combining study samples + 1KG data
		- Use Random Forest to classify genetic ancesty with a prediciton prob. > 0.9

- QC within European samples (metrics may be affected by ancestry; `scripts 09-13`)
	- Remove samples that fail sex check (--check-sex)
	- Absolute value of autosomal heterozygosity rate deviating 3 or 5sd from the mean (--het)
	- Identify unrelated Individuals (Pi_hat <0.2) within European samples
	- Remove SNPs that show batch associations
		- Regress each batch indicator on SNPs, adjusting for sex (empirically pick a threshold)

- Calculate PCs within unrelated European samples using common, high-quality SNPs (`script 14`)

- Final SNP-level QC within unrelated European samples (`script 15`)
	- SNP-level call rate >0.98
	- HWE >1E-10
	- Retain only autosomal SNPs, excluding indels and monomorphic SNPs (for imputation)

- Prepare data for HRC imputation using Michigan server (`scripts 16-17`)
	- Harmonize study data with HRC data
	- Convert plink to vcf by chromosome

- Send unrelated European samples to Michigan server for imputation (using HRC as the reference panel)

- Post-imputation QC
	- INFO score >0.8
	- MAF >1%
	- HWE >1E-10
	- SNP-level call rate (--geno) >0.98 (for hard-call genotypes)



## Quality control summary tables

#### [ Ancestral popuation assignment (pred. prob. > 0.9) ]

| Population  | N | % | Batch1 | Batch2 | Batch3 | Batch4 | Batch5 | Batch6 | Batch7 | Batch8 |
| ------------- | -------------: | -------------: | -------------: | -------------: | -------------: | -------------: | -------------: | -------------: | -------------: | -------------: |
| EUR  | 26,677  | 73.2%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| AMR  | 1,840  | 5.1%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| AFR  | 1,607  | 4.4%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| EAS  | 504  | 1.4%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| SAS  | 297  | 0.8%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| Unclassified  | 5,499  | 15.1%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |
| Total  | 36,424  | 100%  | xx  | xx  | xx  | xx  | xx  | xx  | xx  | xx  |


#### [ Sample QC ]
- Samples are genotyped in batches, with the first severn batches each containing 5K individuas and the 8th batch around 900 individuals

| Sample QC metric | #Samples | %Total |
| ---------------- | -------: | -----: |
| Initial sample size | 36,424 | 100%  |
| Sample-level call rate <0.98  | 0  | 0%  |
| Non-European | xx  | xx%  |
| Failing sex check | xx  | xx%  |
| Outliying heterozygosity rate | xx  | xx%  |
| IBD relatedness > 0.2 | xx  | xx%  |


### [ Variant QC ]

| Variant QC metric  | #Variants | %Total |
| ------------- | -------------: | -------------: |
| Initial variant count | around 1M | 100% |
| **_Batch QC:_**  |   |   |
| SNP call rate QC1 (<0.95)  | xx  | xx%  |
| SNP call rate QC2 (<0.98)  | xx  | xx%  |
| Missing rate diff > 0.0075  | xx  | xx%  |
| **_Merged QC:_**  |   |   |
| Total  | xx  | xx%  |
| Duplicated SNPs  | xx  | xx%  |
| Monomorphic SNPs  | xx  | xx%  |
| Not confidently mapped  | xx  | xx%  |
| **_EUR (pop-specific) QC:_**  |   |   |
| Showing batch association (p<1e-04)  | xx  | xx%  |
| **_Final QC:_**  |   |   |
| SNP-level call rate <0.98  | xx  | xx%  |
| HWE <1e-10  | xx  | xx%  |
| **_HRC QC:_**  |   |   |
| xxx  | xx  | xx%  |




