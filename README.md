At the moment, this package creates an app that allows for visual inspection of EMA/ESM data.

The package was developed with the datasets from openESM in mind, and can currently plot built-in datasets, the users own data, and data from openESM accessed through the link to download the dataset from its dedicated Zenodo page. However, the last option is not guaranteed to work.

The purpose is to give EMA/ESM researchers a nice overview of what their data looks like, and possibly guide decisions on what statistical model to use. It plots according to the expected days and beeps of the study, and therefore requires all participants to have the same study lengths. You can currently only plot the variables of one participant at the time.

While "PlotESM" currently might be a more fitting name, ideally some statistical tests will later be implemented.

See more information in the package's vignette, which when downloaded with the following code, should be accessible through `vignette()`or `browseVignettes()`.

```{r}
remotes::install_github("Programming-The-Next-Step-2026/Assumption-Plotter",
               subdir = "AssumptionPlotter",
               build_manual = TRUE,
               build_vignettes = TRUE)
```
