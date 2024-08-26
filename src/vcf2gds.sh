#!/bin/bash
# vcf2gds 0.0.2
# Andrew R Wood
# University of Exeter
# No warrenty provided!
# App will run on a single machine from beginning to end.

main() {

    echo "Input VCF: '$vcf_file'"
    echo "Output GDS: '$gds_filename'"    
    echo "Number of parallel processes for file conversion: '$parallel'"

    # Download the VCF to convert to GDS
    dx download "$vcf_file" -o vcf_file
    
    if [ "$sex_info_file" != "NA" ]
    then
        echo "Sex Information File: '$sex_info_file'"
        #Download the Sex info file
        dx download "$sex_info_file" -o sex_info_file
    fi
        
    # Unpack the R library
    #tar -zxf r_library.tar.gz

    # Run the R script to 1) convert VCF to GDS, 2) inject PASS as a QC filter
    #Rscript vcf2gds.R vcf_file gds $parallel

    # Path to PLINK2 binary
    dx download file-GpYzKvjJ5F2kQ5z2kvX44jP6
    unzip plink2_linux_avx2_20240704.zip

    if [ "$sex_info_file" != "NA" ]
    then
        # run plink
        ./plink2 \
        --vcf vcf_file \
        --update-sex sex_info_file \
        --split-par 2781479 155701383 \
        --threads $parallel \
        --make-pgen \
        --keep-allele-order \
        --set-all-var-ids @:#:\$r:\$a \
        --new-id-max-allele-len 5000 \
        --out gds
    else
        # run plink
        ./plink2 \
        --vcf vcf_file \
        --threads $parallel \
        --make-pgen \
        --keep-allele-order \
        --set-all-var-ids @:#:\$r:\$a \
        --new-id-max-allele-len 5000 \
        --out gds
    fi
    mv gds.pgen pgen
    mv gds.pvar pvar
    mv gds.psam psam

    pgen_filename="${gds_filename}.pgen"
    pvar_filename="${gds_filename}.pvar"
    psam_filename="${gds_filename}.psam"

    echo "PGEN outfile is: "$pgen_filename
    echo "PVAR outfile is: "$pvar_filename
    echo "PSAM outfile is: "$psam_filename
    
    # Upload the GDS file to the project directory
    pgen=$(dx upload pgen --brief --path ./$pgen_filename)
    dx-jobutil-add-output pgen "$pgen" --class=file

    pvar=$(dx upload pvar --brief --path ./$pvar_filename)
    dx-jobutil-add-output pvar "$pvar" --class=file

    psam=$(dx upload psam --brief --path ./$psam_filename)
    dx-jobutil-add-output psam "$psam" --class=file

}
