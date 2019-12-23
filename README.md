# Partners Biobank Genomics Data QC

This repository details the quality control (QC) pipeline of the Partners Biobank genotype data. 


- QC for each genotyping batch (metrics not affected by ancestry; `scripts 01-04`)
	- SNP-level call rate >0.95
	- Sample-level call rate >0.98
	- SNP-level call rate >0.98
	- Maximum SNP-level missing rate difference between two batches < empiricla threshold cutoff (e.g., 1%)

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
	- Absolute value of autosomal F-stat/inbreeding coeff >0.2 or heterozygosity rate deviating 3sd from the mean (--het)
	- Identify unrelated Individuals (Pi_hat <0.2) within European samples
	- Remove SNPs that show batch associations
		- Regress each batch indicator on SNPs, adjusting for sex (empirically pick a threshold)

- Calculate PCs within unrelated European samples using common, high-quality SNPs (`script 14`)

- Final SNP-level QC within unrelated European samples (`script 15`)
	- SNP-level call rate >0.98
	- HWE >1E-10

- Prepare data for HRC imputation using Michigan server (`scripts 16-17`)

- Send unrelated European samples to Michigan server for imputation (using HRC as the reference panel)

- Post-imputation QC
	- INFO score >0.8
	- MAF >1%
	- HWE >1E-10
	- SNP-level call rate (--geno) >0.98 (for hard-call genotypes)



## Quality control summary tables

#### Initial variant count: around 1M

| Variant QC metric  | #Variants removed | % Removed |
| ------------- | -------------: | -------------: |
| **_Batch QC:_**  |   |   |
| SNP call rate QC1 (<0.95)  | 614,459  | 8.9%  |
| SNP call rate QC2 (<0.98)  | 69,003  | 1.0%  |
| Missing rate diff > 0.0075  | 2,996,409  | 43.4%  |
| **_Merged QC:_**  |   |   |
| Total  | 220,614  | 3.2%  |
| Duplicated SNPs  | 220,614  | 3.2%  |
| Monomorphic SNPs  | 224,033  | 3.2%  |
| Not confidently mapped  | 662  | 0.01%  |
| **_EUR (pop-specific) QC:_**  |   |   |
| Showing batch association  | 5,906  | 0.09%  |
| **_Final QC:_**  |   |   |
| SNP-level call rate <0.98  | 5,906  | 0.09%  |
| HWE <1E-10  | 5,906  | 0.09%  |
| **_HRC QC:_**  |   |   |
| xxx  | 5,906  | 0.09%  |


  
#### Initial sample count: 36,424

| Sample QC metric  | #Cases removed | #Ctrls removed |
| ------------- | -------------: | -------------: |
| Sample-level call rate <0.98  | 0  | 0  |
| Non-European  | 2034  | 399  |
| Failing sex check  | 154  | 30  |
| Outliying heterozygosity rate  | 34  | 36  |
| IBD relatedness > 0.2  | 218  | 156  |



#### Popuation assignment (pred prob > 0.9)

| Population  | #N | % |
| ------------- | -------------: | -------------: |
| EUR  | 26,677  | 0  |
| AMR  | 1,840  | 0  |
| AFR  | 1,607  | 0  |
| EAS  | 504  | 0  |
| SAS  | 297  | 0  |
| Unknown/unclassified  | 0  | 0  |
| Total  | 36,424  | 100  |
