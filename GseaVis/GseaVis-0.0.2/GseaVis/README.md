
# GseaVis <img src="man/gseaVis-logo.svg" align="right" height="200" />

<!-- badges: start -->

The goal of GseaVis is to visualize GSEA enrichment results as an implement package for **enrichplot** _gseaplot2_ function. And some codes origin from **enrichplot** package, thanks for **Guangchuang Yu** professor's contribution!

You can mark your gene name on GSEA plot and this package also support more avaliable parameters to customize your own plot.

<!-- badges: end -->

## Installation

You can install the development version of GseaVis from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("junjunlab/GseaVis")
```

## Citation

> Jun Z (2022). *GseaVis: An Implement R Package to Visualize GSEA Results.*  https://github.com/junjunlab/GseaVis, https://github.com/junjunlab/GseaVis/wiki

## Examples

This is a basic example:

``` r
library(GseaVis)
## basic example code

# all plot
gseaNb(object = gseaRes,
       geneSetID = 'GOBP_NUCLEOSIDE_DIPHOSPHATE_METABOLIC_PROCESS')
```

![image](https://user-images.githubusercontent.com/64965509/177512952-7043555d-7f06-427c-b969-8427c0a065f5.png)

## More examples refer to

> **https://github.com/junjunlab/GseaVis/wiki**
