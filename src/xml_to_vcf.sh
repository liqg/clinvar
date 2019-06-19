python -u src/parse_clinvar_xml.py -x output/ClinVarFullRelease_00-latest.xml.gz -g GRCh37 -o ./output/clinvar_table_raw.single.b37.tsv -m ./output/clinvar_table_raw.multi.b37.tsv

python -u src/normalize.py -R /home/liqg/Rarediseaseplatform/data/hg19.fasta < ./output/clinvar_table_raw.single.b37.tsv | grep -v ^$ | bgzip -c > ./output/clinvar_table_normalized.single.b37.tsv.gz

cat <(gunzip -c ./output/clinvar_table_normalized.single.b37.tsv.gz | head -1) <(gunzip -c ./output/clinvar_table_normalized.single.b37.tsv.gz | tail -n +2 | eg
rep -v "^[XYM]" | sort -k1,1n -k2,2n -k3,3 -k4,4 ) <(gunzip -c ./output/clinvar_table_normalized.single.b37.tsv.gz | tail -n +2 | egrep "^[XYM]" | sort -k1,1 -k2,2n -k3,3 -k4,4 )  | bgzip -c > ./output/clinvar_allele_trait_pairs.single.b37.tsv.gz

tabix -S 1 -s 1 -b 2 -e 2 ./output/clinvar_allele_trait_pairs.single.b37.tsv.gz

python -u src/group_by_allele.py -i ./output/clinvar_allele_trait_pairs.single.b37.tsv.gz | bgzip -c > ./output/clinvar_alleles_grouped.single.b37.tsv.gz

python src/join_variant_summary_with_clinvar_alleles.py ./output/variant_summary.txt.gz ./output/clinvar_alleles_grouped.single.b37.tsv.gz ./output/clinvar_alleles_combined.single.b37.tsv.gz GRCh37

cat <(gunzip -c ./output/clinvar_alleles_combined.single.b37.tsv.gz | head -1) <(gunzip -c ./output/clinvar_alleles_combined.single.b37.tsv.gz | tail -n +2 | egrep -v "^[XYM]" | sort -k1,1n -k2,2n -k3,3 -k4,4 ) <(gunzip -c ./output/clinvar_alleles_combined.single.b37.tsv.gz | tail -n +2 | egrep "^[XYM]" | sort -k1,1 -k2,2n -k3,3 -k4,4 )  | bgzip -c > ./output/clinvar_alleles.single.b37.tsv.gz

python -u src/clinvar_table_to_vcf.py ./output/clinvar_alleles.single.b37.tsv.gz /home/liqg/Rarediseaseplatform/data/hg19.fasta | bgzip -c > ./output/clinvar_alleles.single.b37.vcf.gz

tabix -p vcf output/clinvar_alleles.single.b37.vcf.gz
