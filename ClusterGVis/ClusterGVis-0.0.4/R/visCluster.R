#' @name visCluster
#' @author JunZhang
#' @title using visCluster to visualize cluster results from clusterData output
#'
#' @param object clusterData object, default NULL.
#' @param ht.col heatmap colors, default c("blue", "white", "red").
#' @param border whether add border for heatmap, default TRUE.
#' @param plot.type the plot type to choose which incuding "line","heatmap" and "both".
#' @param ms.col membership line color form Mfuzz cluster method results,
#' default c('#0099CC','grey90','#CC3333').
#' @param line.size line size for line plot, default 0.1.
#' @param line.col line color for line plot, default "grey90".
#' @param add.mline whether add median line on plot, default TRUE.
#' @param mline.size median line size, default 2.
#' @param mline.col median line color, default "#CC3333".
#' @param ncol the columns for facet plot with line plot, default 4.
#' @param ctAnno.col the heatmap cluster annotation bar colors, default NULL.
#' @param set.md the represent line method on heatmap-line plot(mean/median), default "median".
#' @param textbox.pos the relative position of text in left-line plot, default c(0.5,0.8).
#' @param textbox.size the text size of the text in left-line plot, default 8.
#' @param panel.arg the settings for the left-line panel which are
#' panel size,gap,width,fill and col, default c(2,0.25,4,"grey90",NA).
#' @param annoTerm.data the GO term annotation for the clusters, default NULL.
#' @param annoTerm.mside the wider GO term annotation box side, default "right".
#' @param termAnno.arg the settings for GO term panel annotations which are fill and col,
#' default c("grey95","grey50").
#'
#' @param add.box whether add boxplot, default FALSE.
#' @param boxcol the box fill colors, default NULL.
#' @param box.arg this is related to boxplot width and border color, default c(0.1,"grey50").
#' @param add.point whether add point, default FALSE.
#' @param point.arg this is related to point shape,fill,color and size, default c(19,"orange","orange",1).
#' @param add.line whether add line, default TRUE.
#' @param line.side the line annotation side, default "right".
#'
#' @param markGenes the gene names to be added on plot, default NULL.
#' @param markGenes.side the gene label side, default "right".
#' @param genes.gp gene labels graphics settings, default c('italic',10,NA).
#' @param go.col the GO term text colors, default NULL.
#' @param go.size the GO term text size(numeric or "pval"), default NULL.
#' @param mulGroup to draw multiple lines annotation, supply the groups numbers with vector, default NULL.
#' @param lgd.label the lines annotation legend labels, default NULL.
#' @param show_row_names whether to show row names, default FALSE.
#' @param term.text.limit the GO term text size limit, default c(10,18).
#' @param subgroup.anno the sub-cluster for annotation, supply sub-cluster id, default NULL.
#' @param add.bar whether add bar plot for GO enrichment, default FALSE.
#' @param bar.width the GO enrichment bar width, default 8.
#' @param textbar.pos the barplot text relative position, default c(0.8,0.8).
#'
#' @param annnoblock.text whether add cluster numbers on right block annotation, default TRUE.
#' @param annnoblock.gp right block annotation text color and size, default c("white",8).
#' @param add.sampleanno whether add column annotation, default TRUE.
#' @param sample.group the column sample groups, default NULL.
#' @param sample.col column annotation colors, default NULL.
#' @param sample.order the orders for column samples, default NULL.
#' @param HeatmapAnnotation the 'HeatmapAnnotation' object from 'ComplexHeatmap'
#' when you have multiple annotations, default NULL.
#' @param column.split how to split the columns when supply multiple column annotations, default NULL.
#'
#' @param ... othe aruguments passed by Heatmap fuction.
#'
#' @return a ggplot2 or Heatmap object.
#' @export
#'
#' @examples
#' \dontrun{
#' data("termanno")
#' data("exps")
#'
#' # mfuzz
#' cm <- clusterData(exp = exps,
#'                   cluster.method = "mfuzz",
#'                   cluster.num = 8)
#'
#' # plot
#' visCluster(object = cm,
#'            plot.type = "line")
#' }
globalVariables(c('cell_type', 'cluster.num', 'gene',"ratio","bary",
                  'membership', 'norm_value','id', 'log10P', 'pval',
                  'Var1'))
visCluster <- function(object = NULL,
                       # plot.data = NULL,
                       ht.col = c("blue", "white", "red"),
                       border = TRUE,
                       plot.type = c("line","heatmap","both"),
                       ms.col = c('#0099CC','grey90','#CC3333'),
                       line.size = 0.1,
                       line.col = "grey90",
                       add.mline = TRUE,
                       mline.size = 2,
                       mline.col = "#CC3333",
                       ncol = 4,
                       ctAnno.col = NULL,
                       set.md = "median",
                       textbox.pos = c(0.5,0.8),
                       textbox.size = 8,
                       # panel size,gap,width,fill,col
                       panel.arg = c(2,0.25,4,"grey90",NA),
                       annoTerm.data = NULL,
                       annoTerm.mside = "right",
                       # textbox fill and col
                       termAnno.arg = c("grey95","grey50"),
                       add.box = FALSE,
                       boxcol = NULL,
                       # box with and border color
                       box.arg = c(0.1,"grey50"),
                       add.point = FALSE,
                       # shape,fill,color,size
                       point.arg = c(19,"orange","orange",1),
                       add.line = TRUE,
                       line.side = "right",
                       markGenes = NULL,
                       markGenes.side = "right",
                       genes.gp = c('italic',10,NA),
                       go.col = NULL,
                       go.size = NULL,
                       term.text.limit = c(10,18),
                       mulGroup = NULL,
                       lgd.label = NULL,
                       show_row_names = FALSE,
                       subgroup.anno = NULL,
                       add.bar = FALSE,
                       bar.width = 8,
                       textbar.pos = c(0.8,0.8),
                       annnoblock.text = TRUE,
                       annnoblock.gp = c("white",8),
                       add.sampleanno = TRUE,
                       sample.group = NULL,
                       sample.col = NULL,
                       sample.order = NULL,
                       HeatmapAnnotation = NULL,
                       column.split = NULL,
                       ...){
  ComplexHeatmap::ht_opt(message = FALSE)
  col_fun = circlize::colorRamp2(c(-2, 0, 2), ht.col)
  plot.type <- match.arg(plot.type)

  # choose plot type
  if(plot.type == "line"){
    # process data
    # if(is.null(plot.data)){
    #   data <- data.frame(object$long.res)
    # }else{
    #   data <- plot.data
    # }
    data <- data.frame(object$long.res)

    # sample orders
    if(!is.null(sample.order)){
      data$cell_type <- factor(data$cell_type,levels = sample.order)
    }

    # basic plot
    line <-
      ggplot2::ggplot(data,ggplot2::aes(x = cell_type,y = norm_value))

    # type
    if(object$type == "mfuzz"){
      line <- line +
        ggplot2::geom_line(ggplot2::aes(color = membership,group = gene),size = line.size) +
        ggplot2::scale_color_gradient2(low = ms.col[1],mid = ms.col[2],high = ms.col[3],
                                       midpoint = 0.5)

    }else{
      line <- line +
        ggplot2::geom_line(ggplot2::aes(group = gene),color = line.col,size = line.size)
    }

    if(add.mline == TRUE){
      if(object$type == "wgcna"){
        # line colors
        linec <- unique(data$modulecol)
        names(linec) <- linec

        line <- line +
          # median line
          ggplot2::geom_line(stat = "summary", fun = "median",
                             # colour = "brown",
                             size = mline.size,
                             ggplot2::aes(group = 1,color = modulecol)) +
          ggplot2::scale_color_manual(values = linec)
      }else{
        line <- line +
          # median line
          ggplot2::geom_line(stat = "summary", fun = "median", colour = mline.col, size = mline.size,
                             ggplot2::aes(group = 1))
      }
    }else{
      line <- line
    }

    # other themes
    line1 <- line +
      ggplot2::theme_classic(base_size = 14) +
      ggplot2::ylab('Normalized expression') + ggplot2::xlab('') +
      ggplot2::theme(axis.ticks.length = ggplot2::unit(0.1,'cm'),
                     axis.text.x = ggplot2::element_text(angle = 45,hjust = 1,color = 'black'),
                     strip.background = ggplot2::element_blank()) +
      ggplot2::facet_wrap(~cluster_name,ncol = ncol,scales = 'free')

    return(line1)

  }else{
    # ==========================================================================
    # process data
    # if(is.null(plot.data)){
    #   data <- data.frame(object$wide.res)
    # }else{
    #   data <- plot.data
    # }

    data <- data.frame(object$wide.res)

    # prepare matrix
    if(object$type == "mfuzz"){
      mat <- data %>%
        dplyr::arrange(cluster) %>%
        dplyr::select(-gene,-cluster,-membership)
    }else if(object$type == "wgcna"){
      mat <- data %>%
        dplyr::arrange(cluster) %>%
        dplyr::select(-gene,-cluster,-modulecol)
    }else{
      mat <- data %>%
        dplyr::arrange(cluster) %>%
        dplyr::select(-gene,-cluster)
    }

    rownames(mat) <- data$gene

    # sample orders
    if(!is.null(sample.order)){
      mat <- mat[,sample.order]
    }

    # split info
    cl.info <- data.frame(table(data$cluster)) %>%
      dplyr::arrange(Var1)
    cluster.num <- nrow(cl.info)

    subgroup <- lapply(1:nrow(cl.info),function(x){
      nm <- rep(as.character(cl.info$Var1[x]),cl.info$Freq[x])
      paste("C",nm,sep = '')
    }) %>% unlist()

    # plot
    # =================== bar annotation for samples
    # sample group info
    if(is.null(sample.group)){
      sample.info = colnames(mat)

      # split columns
      if(is.null(HeatmapAnnotation)){
        column_split = NULL
      }else{
        column_split = column.split
      }
    }else{
      sample.info = sample.group

      # split columns
      column_split = sample.group
    }

    # order
    sample.info <- factor(sample.info,levels = unique(sample.info))

    # sample colors
    if(is.null(sample.col)){
      # scol <- ggsci::pal_npg()(length(sample.info))
      scol <- circlize::rand_color(n = length(sample.info))
      names(scol) <- sample.info
    }else{
      scol <- sample.col
      names(scol) <- sample.info
    }

    # top anno
    if(add.sampleanno == TRUE){
      if(is.null(HeatmapAnnotation)){
        topanno = ComplexHeatmap::HeatmapAnnotation(sample = sample.info,
                                                    col = list(sample = scol),
                                                    gp = grid::gpar(col = "white"),
                                                    show_annotation_name = FALSE)
      }else{
        topanno = HeatmapAnnotation
      }

    }else{
      topanno = NULL
    }

    # =================== bar annotation for clusters
    if(is.null(ctAnno.col)){
      colanno <- jjAnno::useMyCol("stallion",n = cluster.num)
    }else{
      colanno <- ctAnno.col
    }

    names(colanno) <- 1:cluster.num
    # anno.block <- ComplexHeatmap::anno_block(gp = grid::gpar(fill = colanno,col = NA),
    #                                          which = "row")

    align_to = split(1:nrow(mat), subgroup)
    anno.block <- ComplexHeatmap::anno_block(align_to = align_to,
                                             panel_fun = function(index, nm) {
                                               npos = as.numeric(unlist(strsplit(nm,split = "C"))[2])

                                               # rect
                                               grid::grid.rect(gp = grid::gpar(fill = colanno[npos],col = NA))

                                               # text
                                               if(annnoblock.text == TRUE){
                                                 grid::grid.text(label = paste("n:",length(index),sep = ''),
                                                                 rot = 90,
                                                                 gp = grid::gpar(col = annnoblock.gp[1],
                                                                                 fontsize = as.numeric(annnoblock.gp[2])))
                                               }
                                             },
                                             which = "row")

    # =================== gene annotation for heatmap
    # whether mark your genes on plot
    if(!is.null(markGenes)){
      # all genes
      rowGene <- rownames(mat)

      # tartget gene
      annoGene <- markGenes

      # add color for gene
      gene.col <- data %>%
        dplyr::select(gene,cluster) %>%
        dplyr::filter(gene %in% annoGene)

      purrr::map_df(1:cluster.num,function(x){
        tmp <- gene.col %>%
          dplyr::filter(cluster == x) %>%
          dplyr::mutate(col = colanno[x])
      }) -> gene.col

      gene.col <- gene.col[match(annoGene,gene.col$gene),]

      if(is.na(genes.gp[3])){
        gcol = gene.col$col
      }else{
        gcol = genes.gp[3]
      }

      # get target gene index
      index <- match(annoGene,rowGene)

      # some genes annotation
      geneMark = gene = ComplexHeatmap::anno_mark(at = index,
                                                  labels = annoGene,
                                                  which = "row",
                                                  side = markGenes.side,
                                                  labels_gp = grid::gpar(fontface = genes.gp[1],
                                                                         fontsize = as.numeric(genes.gp[2]),
                                                                         col = gcol))
    }else{
      geneMark = NULL
    }

    # final annotation for heatmap
    right_annotation = ComplexHeatmap::rowAnnotation(gene = geneMark,cluster = anno.block)

    # =======================================================
    # return plot according to plot type
    if(plot.type == "heatmap"){
      # draw HT
      htf <-
        ComplexHeatmap::Heatmap(as.matrix(mat),
                                name = 'Z-score',
                                cluster_columns = FALSE,
                                show_row_names = show_row_names,
                                border = border,
                                column_split = column_split,
                                row_split = subgroup,
                                column_names_side = "top",
                                # border = TRUE,
                                top_annotation = topanno,
                                right_annotation = right_annotation,
                                col = col_fun,
                                ...)

      # draw
      ComplexHeatmap::draw(htf,merge_legend = TRUE)
    }else{
      #====================== heatmap + line
      rg = range(mat)

      # # panel_fun for line plot
      # panel_fun = function(index, nm) {
      #   grid::pushViewport(grid::viewport(xscale = c(1,ncol(mat)), yscale = rg))
      #   grid::grid.rect()
      #
      #   # grid.xaxis(gp = gpar(fontsize = 8))
      #   # grid.annotation_axis(side = 'right',gp = gpar(fontsize = 8))
      #
      #   # choose method
      #   if(set.md == "mean"){
      #     mdia <- colMeans(mat[index, ])
      #   }else if(set.md == "median"){
      #     mdia <- apply(mat[index, ], 2, stats::median)
      #   }else{
      #     message("supply mean/median !")
      #   }
      #
      #   # get gene numbers
      #   text <- paste("Gene Size:",nrow(mat[index, ]),sep = ' ')
      #   ComplexHeatmap::grid.textbox(text,x = textbox.pos[1],y = textbox.pos[2],
      #                                gp = grid::gpar(fontsize = textbox.size,fontface = "italic"))
      #
      #   # grid.points(x = 1:ncol(m),y = mdia,
      #   #             pch = 19,
      #   #             gp = gpar(col = 'orange'))
      #
      #   grid::grid.lines(x = scales::rescale(1:ncol(mat),to = c(0,1)),
      #                    y = scales::rescale(mdia,to = c(0,1),from = rg),
      #                    gp = grid::gpar(lwd = 3,col = mline.col))
      #
      #   grid::popViewport()
      # }

      # ====================================================================
      # panel_fun for line plot
      panel_fun = function(index, nm) {

        # whether add boxplot
        if(add.box == TRUE & add.line != TRUE){
          xscale = c(-0.1,1.1)
        }else{
          xscale = c(0,1)
        }

        grid::pushViewport(grid::viewport(xscale = xscale, yscale = c(0,1)))
        grid::grid.rect()

        # grid.xaxis(gp = gpar(fontsize = 8))
        # grid.annotation_axis(side = 'right',gp = gpar(fontsize = 8))

        # # choose method
        # if(set.md == "mean"){
        #   mdia <- colMeans(mat[index, ])
        # }else if(set.md == "median"){
        #   mdia <- apply(mat[index, ], 2, stats::median)
        # }else{
        #   message("supply mean/median !")
        # }
        #
        # # boxplot xpos
        # pos = scales::rescale(1:ncol(mat),to = c(0,1))
        #
        # # boxcol
        # if(is.null(boxcol)){
        #   boxcol <- rep("grey90",ncol(mat))
        # }else{
        #   boxcol <- boxcol
        # }
        #
        # # boxplot grobs
        # if(add.box == TRUE){
        #   lapply(1:ncol(mat), function(x){
        #     ComplexHeatmap::grid.boxplot(scales::rescale(mat[index, ][,x],
        #                                                  to = c(0,1),
        #                                                  from = c(rg[1] - 0.5,rg[2] + 0.5)),
        #                                  pos = pos[x],
        #                                  direction = "vertical",
        #                                  box_width = as.numeric(box.arg[1]),
        #                                  outline = FALSE,
        #                                  gp = grid::gpar(col = box.arg[2],fill = boxcol[x]))
        #   })
        # }
        #
        # # points grobs
        # if(add.point == TRUE){
        #   grid::grid.points(x = scales::rescale(1:ncol(mat),to = c(0,1)),
        #                     y = scales::rescale(mdia,to = c(0,1),from = c(rg[1] - 0.5,rg[2] + 0.5)),
        #                     pch = as.numeric(point.arg[1]),
        #                     gp = grid::gpar(fill = point.arg[2],col = point.arg[3]),
        #                     size = grid::unit(as.numeric(point.arg[4]), "char"))
        # }
        #
        # # lines grobs
        # if(add.line == TRUE){
        #   grid::grid.lines(x = scales::rescale(1:ncol(mat),to = c(0,1)),
        #                    y = scales::rescale(mdia,to = c(0,1),from = c(rg[1] - 0.5,rg[2] + 0.5)),
        #                    gp = grid::gpar(lwd = 3,col = mline.col))
        # }

        # whether given multiple groups
        if(is.null(mulGroup)){
          mulGroup <- ncol(mat)

          # ================ calculate group columns index
          seqn <- data.frame(st = 1,
                             sp = ncol(mat))
        }else{
          mulGroup <- mulGroup

          grid::grid.lines(x = c(0,1),y = rep(0.5,2),
                           gp = grid::gpar(col = "black",lty = "dashed"))

          # ================ calculate group columns index
          cu <- cumsum(mulGroup)
          seqn <- data.frame(st = c(1,cu[1:(length(cu) - 1)] + 1),
                             sp = c(cu[1],cu[2:length(cu)]))
        }

        # loop for multiple groups to create grobs
        lapply(1:nrow(seqn), function(x){
          tmp <- seqn[x,]
          tmpmat <- mat[index, c(tmp$st:tmp$sp)]

          # choose method
          if(set.md == "mean"){
            mdia <- colMeans(tmpmat)
          }else if(set.md == "median"){
            mdia <- apply(tmpmat, 2, stats::median)
          }else{
            message("supply mean/median !")
          }

          # boxplot xpos
          pos = scales::rescale(1:ncol(tmpmat),to = c(0,1))

          # boxcol
          if(is.null(boxcol)){
            boxcol <- rep("grey90",ncol(tmpmat))
          }else{
            boxcol <- boxcol
          }

          # boxplot grobs
          if(add.box == TRUE){
            lapply(1:ncol(tmpmat), function(x){
              ComplexHeatmap::grid.boxplot(scales::rescale(tmpmat[,x],
                                                           to = c(0,1),
                                                           from = c(rg[1] - 0.5,rg[2] + 0.5)),
                                           pos = pos[x],
                                           direction = "vertical",
                                           box_width = as.numeric(box.arg[1]),
                                           outline = FALSE,
                                           gp = grid::gpar(col = box.arg[2],fill = boxcol[x]))
            })
          }

          # points grobs
          if(add.point == TRUE){
            grid::grid.points(x = scales::rescale(1:ncol(tmpmat),to = c(0,1)),
                              y = scales::rescale(mdia,to = c(0,1),from = c(rg[1] - 0.5,rg[2] + 0.5)),
                              pch = as.numeric(point.arg[1]),
                              gp = grid::gpar(fill = point.arg[2],col = point.arg[3]),
                              size = grid::unit(as.numeric(point.arg[4]), "char"))
          }

          # lines grobs
          if(add.line == TRUE){
            grid::grid.lines(x = scales::rescale(1:ncol(tmpmat),to = c(0,1)),
                             y = scales::rescale(mdia,to = c(0,1),from = c(rg[1] - 0.5,rg[2] + 0.5)),
                             gp = grid::gpar(lwd = 3,col = mline.col[x]))
          }
        })

        # get gene numbers
        grid.textbox <- utils::getFromNamespace("grid.textbox", "ComplexHeatmap")

        text <- paste("Gene Size:",nrow(mat[index, ]),sep = ' ')
        grid.textbox(text,x = textbox.pos[1],y = textbox.pos[2],
                     gp = grid::gpar(fontsize = textbox.size,
                                     fontface = "italic",
                                     ...))

        grid::popViewport()
      }

      # whether annotate subgroups
      if(!is.null(subgroup.anno)){
        align_to = split(1:nrow(mat), subgroup)
        align_to = align_to[subgroup.anno]
      }else{
        align_to = subgroup
      }

      # anno link annotation
      anno = ComplexHeatmap::anno_link(align_to = align_to,
                                       which = "row",
                                       panel_fun = panel_fun,
                                       size = grid::unit(as.numeric(panel.arg[1]), "cm"),
                                       gap = grid::unit(as.numeric(panel.arg[2]), "cm"),
                                       width = grid::unit(as.numeric(panel.arg[3]), "cm"),
                                       side = line.side,
                                       link_gp = grid::gpar(fill = panel.arg[4],col = panel.arg[5]))

      # =====================================
      # whether add go term annotations
      if(!is.null(annoTerm.data)){
        # load term info
        termanno <- annoTerm.data
        if(ncol(termanno) == 2){
          colnames(termanno) <- c("id","term")
        }else if(ncol(termanno) == 3){
          colnames(termanno) <- c("id","term","pval")
        }else if(ncol(termanno) == 4){
          colnames(termanno) <- c("id","term","pval","ratio")
        }else{
          message("No more than 4 columns!")
        }

        # term colors
        if(is.null(go.col)){
          gocol <- circlize::rand_color(n = nrow(termanno))
        }else{
          gocol <- go.col
        }

        # term text size
        if(is.null(go.size)){
          gosize <- rep(12,nrow(termanno))
        }else{
          if(go.size == "pval"){
            # loop for re-scaling pvalue
            purrr::map_df(unique(termanno$id),function(x){
              tmp <- termanno %>%
                dplyr::filter(id == x) %>%
                dplyr::mutate(size = scales::rescale(-log10(pval),to = term.text.limit))
            }) -> termanno.tmp

            gosize <- termanno.tmp$size
          }else{
            gosize <- go.size
          }
        }

        # add to termanno
        termanno <- termanno %>%
          dplyr::mutate(col = gocol,fontsize = gosize)

        # to list
        lapply(1:length(unique(termanno$id)), function(x){
          tmp = termanno[which(termanno$id == unique(termanno$id)[x]),]
          df <- data.frame(text = tmp$term,
                           col = tmp$col,
                           fontsize = tmp$fontsize)
          return(df)
        }) -> term.list

        # add names
        names(term.list) <- unique(termanno$id)

        # whether annotate subgroups
        if(!is.null(subgroup.anno)){
          align_to2 = split(seq_along(subgroup), subgroup)
          align_to2 = align_to2[subgroup.anno]

          term.list = term.list[subgroup.anno]
        }else{
          align_to2 = subgroup
          term.list = term.list
        }

        # textbox annotations
        # if(add.bar == TRUE){
        #   box.side = "left"
        # }else{
        #   box.side = "right"
        # }

        textbox = ComplexHeatmap::anno_textbox(align_to2, term.list,
                                               word_wrap = TRUE,
                                               add_new_line = TRUE,
                                               side = annoTerm.mside,
                                               background_gp = grid::gpar(fill = termAnno.arg[1],
                                                                          col = termAnno.arg[2]))

        # final row annotation
        # if(line.side == "right"){
        #   right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block,
        #                                                     line = anno,
        #                                                     textbox = textbox)
        #   left_annotation = NULL
        # }else{
        #   right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block,
        #                                                     textbox = textbox)
        #   left_annotation = ComplexHeatmap::rowAnnotation(line = anno)
        # }

        # GO bar anno function
        if(ncol(termanno) - 2 > 2){
          anno_gobar <- function(data = NULL,
                                 bar.width = 0.1,
                                 # col = NA,
                                 align_to = NULL,
                                 panel.arg = panel.arg,
                                 ...){
            # process data
            if(ncol(data) - 2 == 3){
              data <- data %>%
                dplyr::mutate(bary = -log10(pval))
            }else{
              data <- data %>%
                dplyr::mutate(bary = ratio)
            }

            ComplexHeatmap::anno_zoom(align_to = align_to,
                                      which = "row",

                                      # =====================
                                      panel_fun = function(index,nm){
                                        grid::pushViewport(grid::viewport(xscale = c(0,1),yscale = c(0,1)))

                                        grid::grid.rect()

                                        # sub data
                                        tmp <- data %>%
                                          dplyr::filter(id == nm) %>%
                                          dplyr::arrange(bary)

                                        # bar grobs
                                        # grid::grid.rect(x = rep(0,nrow(tmp)),
                                        #                 y = scales::rescale(1:nrow(tmp),to = c(0,1)),
                                        #                 width = scales::rescale(tmp$log10P,to = c(0,1)),
                                        #                 height = bar.width,
                                        #                 gp = grid::gpar(fill = tmp$col,col = col))

                                        grid::grid.segments(x0 = rep(0,nrow(tmp)),
                                                            x1 = scales::rescale(tmp$bary,to = c(0,1)),
                                                            y0 = scales::rescale(1:nrow(tmp),to = c(0,1)),
                                                            y1 = scales::rescale(1:nrow(tmp),to = c(0,1)),
                                                            gp = grid::gpar(lwd = bar.width,
                                                                            col = tmp$col,
                                                                            lineend = "butt"))

                                        # add cluster name
                                        grid.textbox <- utils::getFromNamespace("grid.textbox", "ComplexHeatmap")

                                        text <- nm
                                        grid.textbox(text,
                                                     x = textbar.pos[1],y = textbar.pos[2],
                                                     gp = grid::gpar(fontsize = textbox.size,
                                                                     fontface = "italic",
                                                                     col = unique(tmp$col),
                                                                     ...))

                                        grid::popViewport()
                                      },

                                      # =======================
                                      size = grid::unit(as.numeric(panel.arg[1]), "cm"),
                                      gap = grid::unit(as.numeric(panel.arg[2]), "cm"),
                                      width = grid::unit(as.numeric(panel.arg[3]), "cm"),
                                      side = "right",
                                      link_gp = grid::gpar(fill = termAnno.arg[1],col = termAnno.arg[2]),
                                      ...)
          }

          # ================================
          # bar anno
          baranno = anno_gobar(data = termanno,
                               align_to = align_to2,
                               panel.arg = panel.arg,
                               bar.width = bar.width)

        }

        # whether add bar annotation
        if(add.bar == TRUE){
          baranno
        }else{
          baranno = NULL
        }

      }else{
        # ======================================================
        # no GO annotation
        # if(line.side == "right"){
        #   right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block,line = anno)
        #   left_annotation = NULL
        # }else{
        #   right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block)
        #   left_annotation = ComplexHeatmap::rowAnnotation(line = anno)
        # }
        textbox = NULL
        baranno = NULL
      }

      # ====================================================
      # final row annotations
      if(line.side == "right"){
        if(markGenes.side == "right"){
          right_annotation2 = ComplexHeatmap::rowAnnotation(gene = geneMark,
                                                            cluster = anno.block,
                                                            line = anno,
                                                            textbox = textbox,
                                                            bar = baranno)
          left_annotation = NULL
        }else{
          right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block,
                                                            line = anno,
                                                            textbox = textbox,
                                                            bar = baranno)
          left_annotation = ComplexHeatmap::rowAnnotation(gene = geneMark)
        }

      }else{
        if(markGenes.side == "right"){
          right_annotation2 = ComplexHeatmap::rowAnnotation(gene = geneMark,
                                                            cluster = anno.block,
                                                            textbox = textbox,
                                                            bar = baranno)
          left_annotation = ComplexHeatmap::rowAnnotation(line = anno)
        }else{
          right_annotation2 = ComplexHeatmap::rowAnnotation(cluster = anno.block,
                                                            textbox = textbox,
                                                            bar = baranno)
          left_annotation = ComplexHeatmap::rowAnnotation(line = anno,
                                                          gene = geneMark)
        }
      }

      # save
      # pdf('test.pdf',height = 10,width = 10)
      htf <- ComplexHeatmap::Heatmap(as.matrix(mat),
                                     name = "Z-score",
                                     cluster_columns = FALSE,
                                     show_row_names = show_row_names,
                                     border = border,
                                     column_split = column_split,
                                     top_annotation = topanno,
                                     right_annotation = right_annotation2,
                                     left_annotation = left_annotation,
                                     column_names_side = "top",
                                     row_split = subgroup,
                                     col = col_fun,
                                     ...)

      # draw lines legend
      if(is.null(mulGroup)){
        ComplexHeatmap::draw(htf,merge_legend = TRUE)
      }else{
        if(is.null(lgd.label)){
          lgd.label <- paste("group",1:length(mulGroup),sep = '')
        }else{
          lgd.label <- lgd.label
        }

        lgd_list = list(
          ComplexHeatmap::Legend(labels = lgd.label,
                                 type = "lines",
                                 legend_gp = grid::gpar(col = mline.col, lty = 1)))

        ComplexHeatmap::draw(htf,annotation_legend_list = lgd_list,merge_legend = TRUE)
      }
      # dev.off()
    }

  }
}


###############################
#' This is a test data for this package
#' test data describtion
#'
#' @name termanno
#' @docType data
#' @author Junjun Lao
"termanno"

#' This is a test data for this package
#' test data describtion
#'
#' @name termanno2
#' @docType data
#' @author Junjun Lao
"termanno2"
