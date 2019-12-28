# Partners Biobank Genomics Data QC

This repository details the quality control (QC) pipeline of the Partners Biobank genotype data, which largely follows the recommendations described in:

Peterson, R. E., Kuchenbaecker, K., Walters, R. K., Chen, C.-Y., Popejoy, A. B., Periyasamy, S., et al. (2019). Genome-wide Association Studies in Ancestrally Diverse Populations: Opportunities, Methods, Pitfalls, and Recommendations. Cell, 179(3), 589–603. http://doi.org/10.1016/j.cell.2019.08.051

The current dataset (`as of Dec. 2019`) includes 36,424 individuals genotyped on Illumina’s Multi-Ethnic Global array in hg19 coordinates.


## Quality control pipeline

* QC for each genotyping batch (metrics not affected by ancestry; `scripts 01-04`)
	* SNP-level call rate >0.95
	* Sample-level call rate >0.98
	* SNP-level call rate >0.98
	* Maximum SNP-level missing rate difference between two batches < empirical threshold cutoff (e.g., 1%)

* Merge genotyping batches (`scripts 05-06`)
	* Remove duplicated SNPs
	* Remove monomorphic SNPs
	* Remove SNPs not confidently mapped (chr=0)

* Population assignment (`scripts 07-08`)
	* Select common, high-quality SNPs for population inference
		* SNP-level call rate >0.98
		* MAF >5%
		* Remove strand ambiguous SNPs and long-range LD regions (chr6:25-35Mb; chr8:7-13Mb inversion)
		* Prune to <100K independent SNPs
	* Identify individuals with European ancestry using selected SNPs
		* Run PCA combining study samples + 1KG data
		* Use Random Forest to classify genetic ancesty with a prediciton probability >0.9

* QC within European samples (metrics may be affected by ancestry; `scripts 09-13`)
	* Remove samples that fail sex check (--check-sex)
	* Absolute value of autosomal heterozygosity rate deviating from the mean (e.g., 5SD; --het)
	* Identify unrelated Individuals (Pi_hat <0.2) within European samples
	* Remove SNPs that show batch associations
		* Regress each batch indicator on SNPs, adjusting for sex (association P < empirical threshold cutoff)

* Calculate PCs within unrelated European samples using common, high-quality SNPs (`script 14`)

* Final SNP-level QC within unrelated European samples (`script 15`)
	* SNP-level call rate >0.98
	* HWE P >1e-10
	* Retain only autosomal SNPs, excluding indels and monomorphic SNPs (for imputation; HRC: SNP only)

* Prepare data for HRC imputation using Michigan server (`scripts 16-17`)
	* Harmonize study data with HRC data
	* Convert plink files to vcf and split by chromosome

* Send unrelated European samples to Michigan server for imputation (using HRC as the reference panel)

* Post-imputation QC (converting vcf dosages to plink hard-call files; `scripts 18-20`)
	* INFO score/Imputation R2 >0.8
	* MAF (based on imputed dosages) >1%
	* HWE P >1e-10
	* SNP-level call rate >0.98



## Summary of pre-imputation QC

### Genetic ancestry assignment
- Random Forest prediction probability >0.9 based on top 6 PCs, with 1KG samples as the training data
- "Unclassified" consists of mostly admixed individuals

| 1KG superpop    |  EUR   |  AMR   |  AFR   |  EAS   |  SAS   | Unclassified | Total |
| --- | -----: | -----: | -----: | -----: | -----: | -----------: | -----:|   
| # Samples | 26,677 | 1,840 | 1,607 | 504 | 297 | 5,499 | 36,424 |
| % Total | 73.2% | 5.1% | 4.4% | 1.4% | 0.8% | 15.1% | 100% |



### Sample QC
- Samples are genotyped on 8 batches, with the first 7 batches each containing ~5K individuals and the 8th batch around 900 individuals

| Sample QC metric | # Samples | % Total |
| ---------------- | -------: | -----: |
| Initial sample size | 36,424 | 100%  |
| **_Batch QC:_**  |   |   |
| Sample-level call rate <0.98  | 0  | 0.0%  |
| **_Merged QC:_**  |   |   |
| Non-European | 9,747  | 26.8%  |
| **_EUR (pop-specific) QC:_**  |   |   |
| Failing sex check (reported != imputed sex, using F <0.25 <br>for female & >0.75 for male) | 25  | 0.07%  |
| Outlying heterozygosity rate (>5SD from the mean) | 50  | 0.14%  |
| IBD relatedness >0.2 | 908  | 2.5%  |
| _Any of the above three_ | 979  | 2.7%  |
| **_Post-QC_** | 25,698  | 70.6%  |


### Variant QC

| Variant QC metric  | # Variants | % Total |
| ------------- | -------------: | -------------: |
| Initial variant count (avg. across batches) | 1.7M | - |
| **_Batch QC:_**  |   |   |
| SNP call rate <0.95 and then <0.98 (avg. across batches)| 20K  | -  |
| Common across batches | 1,370,695 | - |
| Missing rate diff > 0.0075 between any two batches  | 48,929  | -  |
| **_Merged QC:_**  |   |   |
| Total  | 1,321,766  | 100%  |
| Monomorphic SNPs  | 122,742  | 9.3%  |
| Duplicated SNPs  | 19,973  | 1.5%  |
| Not confidently mapped SNPs (chr & pos=0)  | 2,183  | 0.17%  |
| _Any of the above three_  | 144,456  | 10.9%  |
| **_EUR (pop-specific) QC:_**  |   |   |
| Showing batch association (P <1e-04)  | 2,316  | 0.18%  |
| **_Final QC:_**  |   |   |
| SNP-level call rate <0.98  | 1  | 7e-05%  |
| HWE P <1e-10  | 2375  | 0.18%  |
| Non-autosomal SNPs, indels, or monomorphic SNPs | 125,030  | 9.5%  |
| **_Post-QC_** | 1,047,588 | 79.3% |
| **_HRC QC (for imputation):_**  |   |   |
| Not in HRC or mismatched info  | 138,359  | 10.5%  |
| **_Send to Michigan imputation server_**  | 909,229  | 68.8%  |



## Summary of post-imputation QC

| Variant filter (1) | # Variants | % Total |   | Variant filter (2)  | # Variants | % Total |
| ------------------ | ---------: | ------: |---| ------------------- | ---------: | ------: |
| Total imputed | 33,822,636 | 100% | 		    | Total imputed | 33,822,636 | 100% | 
| MAF (dosage) <1% | 26,051,805 | 77.0% |    | MAF (dosage) <0.5% | 24,946,776 | 73.8% | 
| Imputation R2 <0.8 | 17,443,564 | 51.6% |    | Imputation R2 <0.6 | 9,993,397 | 29.5% |
| _Any of the above two_ | 26,468,624 | 78.3% | | _Any of the above two_ | 25,100,024 | 74.2% |
| Call rate <0.98 | 0 | 0.0% |                 | Call rate <0.98 | 0 | 0.0% |
| HWE P <1e-10 | 167 | 5e-04% |                 | HWE P <1e-10 | 213 | 6e-04% |
| **_Post-QC_** | 7,353,845 | 21.7% |           |**_Post-QC_** | 8,722,399 | 25.8% |


