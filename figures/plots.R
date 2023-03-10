## Code to generate comparison plots for subvariant antibody performance

library(dplyr)
library(readxl)
library(ggplot2)
library(ggpubr)

data <- read_excel("HADDOCK_Results.xlsx", sheet = "Results") %>% 
  filter(`Antibody Name` != 'Omi-9') %>% 
  mutate(van_der_waals_energy = `Van der Waals energy`,
         haddock_score = `HADDOCK score`,
         electrostatic_energy = `Electrostatic energy`,
         desolvation_energy = `Desolvation energy`,
         restraints_violation_energy = `Restraints violation energy`,
         buried_surface_area = `Buried Surface Area`,
         prodigy_deltag = `PRODIGY DGprediction (Kcal/mol)`)

# moctet_model <- readRDS("../../../moctet_affinity_model/moctet_model.RDS")
# 
# data$`Predicted Octet Affinity` <- predict(moctet_model, data)

####################
## Box Plots

# wilcox.test((data %>% filter(`Spike RBD` == "BJ.1"))$`HADDOCK score`,
#             (data %>% filter(`Spike RBD` == "XBB.1.5"))$`HADDOCK score`)

## Define Variant Comparisons
# variant_comparisons <- list(
#   c("BJ.1", "BM.1.1.1"),
#   c("BJ.1", "XBB.1.5"),
#   c("BM.1.1.1", "XBB.1.5")
#   )

variant_comparisons <- combn(c("B.1.1.529", "BJ.1", "BM.1.1.1", "XBB.1.5"), 2, simplify = FALSE)

## HADDOCK Score
had_boxplot <- ggboxplot(data, x = "Spike RBD",
          y = "HADDOCK score",
          xlab = "",
          color = "Spike RBD",
          # palette = "jco",
          palette = get_palette("Dark2", 4),
          add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)


## Van der Waals Energy
vdw_boxplot <- ggboxplot(data, x = "Spike RBD",
          y = "Van der Waals energy",
          xlab = "",
          color = "Spike RBD",
          # palette = "jco",
          palette = get_palette("Dark2", 4),
          add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)


## Electrostatic Energy
ee_boxplot <- ggboxplot(data, x = "Spike RBD",
          y = "Electrostatic energy",
          xlab = "",
          color = "Spike RBD",
          # palette = "jco",
          palette = get_palette("Dark2", 4),
          add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)

## Desolvation Energy
de_boxplot <- ggboxplot(data, x = "Spike RBD",
                     y = "Desolvation energy",
                     xlab = "",
                     color = "Spike RBD",
                     # palette = "jco",
                     palette = get_palette("Dark2", 4),
                     add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)

## Restraints Violation Energy
# rve_boxplot <- ggboxplot(data, x = "Spike RBD",
#                      y = "Restraints violation energy",
#                      color = "Spike RBD",
#                      palette = "jco",
#                      add = "dotplot") + 
#   stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)

## Predicted Octet Affinity
# poa_boxplot <- ggboxplot(data, x = "Spike RBD",
#                       y = "Predicted Octet Affinity",
#                       ylab = "Predicted Octet Affinity\nlog(kD/nM)",
#                       xlab = "",
#                       color = "Spike RBD",
#                       # palette = "jco",
#                       palette = get_palette("Dark2", 4),
#                       add = "dotplot") + 
#   stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)

## PRODIGY
pdg_boxplot <- ggboxplot(data, x = "Spike RBD",
                         # y = "PRODIGY DGprediction (Kcal/mol)",
                         y = "prodigy_deltag",
                         # ylab = "PRODIGY Predicted ??G\nKcal/mol",
                         ylab = "PRODIGY Predicted \u0394G\nKcal/mol",
                         xlab = "",
                         color = "Spike RBD",
                         # palette = "jco",
                         palette = get_palette("Dark2", 4),
                         add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)

## Buried Surface Area
bsa_boxplot <- ggboxplot(data, x = "Spike RBD",
                     y = "Buried Surface Area",
                     xlab = "",
                     color = "Spike RBD",
                     # palette = "jco",
                     palette = get_palette("Dark2", 4),
                     add = "dotplot") + 
  stat_compare_means(method = "wilcox.test", comparisons = variant_comparisons)


## Combined BoxPlot Figure
boxplot_figure <- ggarrange(had_boxplot,
                            vdw_boxplot,
                            ee_boxplot,
                            de_boxplot,
                            # poa_boxplot,
                            bsa_boxplot,
                            pdg_boxplot,
                    # labels = c("HADDOCK Score",
                    #            "van der Waals Energy",
                    #            "Electrostatic Energy",
                    #            "Desolvation Energy",
                    #            "Restraints Violation Energy",
                    #            "Buried Surface Area"),
                    labels = c("A", "B", "C", "D", "E", "F"),
                    # ncol = 3, nrow = 2,
                    ncol = 2, nrow = 3,
                    common.legend = TRUE,
                    legend = "bottom")

boxplot_figure


ggsave(filename = "boxplot_vert.eps", 
       plot = boxplot_figure, 
       device = cairo_ps, 
       dpi = 1200,
       width = 8,
       height = 12, 
       units = "in")

###############

## UMAP
library(umap)

umap_fit <- data %>%
  select(`HADDOCK Job Name`,
         `Van der Waals energy`,
         `HADDOCK score`,
         `Electrostatic energy`,
         `Desolvation energy`,
         # `Restraints violation energy`,
         `Buried Surface Area`,
         # `Predicted Octet Affinity`
         `PRODIGY DGprediction (Kcal/mol)`) %>%
  tibble::column_to_rownames("HADDOCK Job Name") %>%
  scale() %>% 
  umap()


umap_df <- umap_fit$layout %>%
  as.data.frame()%>%
  rename(UMAP1="V1",
         UMAP2="V2") %>%
  tibble::rownames_to_column(var = "HADDOCK Job Name") %>% 
  inner_join(data, by="HADDOCK Job Name")


umap_df %>%
  ggplot(aes(
    x = UMAP1,
    y = UMAP2,
    # x = `HADDOCK score`,
    # y = `Predicted Octet Affinity`,
             color = `Antibody Name`,
             shape = `Spike RBD`)) +
  # geom_point(size=3, alpha=0.5) +
  geom_label(
    label=umap_df$`Antibody Name`
  ) +
  facet_wrap(~`Spike RBD`) +
  theme_pubr() +
  theme(legend.position = "none")
  