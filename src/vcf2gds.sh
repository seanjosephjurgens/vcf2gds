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

    # Unpack the R library
    #tar -zxf r_library.tar.gz

    # Run the R script to 1) convert VCF to GDS, 2) inject PASS as a QC filter
    #Rscript vcf2gds.R vcf_file gds $parallel

    # Path to PLINK2 binary
    dx download file-GpYzKvjJ5F2kQ5z2kvX44jP6
    unzip plink2_linux_avx2_20240704.zip
    
    # run plink
    ./plink2 \
    --vcf vcf_file \
    --threads $parallel \
    --make-pgen \
    --out gds

    #mv gds.pgen ${gds_filename}.pgen
    #mv gds.pvar ${gds_filename}.pvar
    #mv gds.psam ${gds_filename}.psam
    
    # Upload the GDS file to the project directory
    #dx upload ${gds_filename}.*

    # Upload the GDS file to the project directory
    gds=$(dx upload gds.pgen --brief --path ./${gds_filename}.pgen)
    dx-jobutil-add-output gds.pgen "$gds" --class=file

    gds=$(dx upload gds.pvar --brief --path ./${gds_filename}.pvar)
    dx-jobutil-add-output gds.pvar "$gds" --class=file

    gds=$(dx upload gds.psam --brief --path ./${gds_filename}.psam)
    dx-jobutil-add-output gds.psam "$gds" --class=file

}
