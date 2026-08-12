# ForestEcology

ForestEcology.jl provides community ecology and phytosociology tools for analyzing
native/mixed forest inventories in Julia. Its focus is on describing the **horizontal
structure** of a forest community (species importance values), its **biodiversity**
(diversity, similarity, and species accumulation), building on
[ForestFoundations.jl](https://github.com/JuliaForests/ForestFoundations.jl) for units
and basal area. These methods support ecological monitoring, conservation assessment,
and forest inventory research.

[![Build Status](https://github.com/JuliaForests/ForestEcology.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/JuliaForests/ForestEcology.jl/actions/workflows/CI.yml?query=branch%3Amaster)

## Installation

Install the package via Julia's package manager:

```julia-repl
using Pkg
Pkg.add("ForestEcology")
```

## Overview

ForestEcology.jl is designed for researchers and practitioners working with native
forest community data (species, plots, and diameters). Its key features include:

- **Phytosociological Structure (`phytosociology`):**
  Computes the classic Curtis & McIntosh Importance Value Index (IVI) and its
  components — density, dominance, and frequency, both absolute and relative — per
  species, following the IUFRO international standard.

- **Community Matrix (`communitymatrix`):**
  Transforms raw plot/species records into a plots × species abundance matrix, the
  common input format for the biodiversity and accumulation functions below.

- **Biodiversity Indices (`diversity`):**
  Shannon-Wiener, Simpson, inverse Simpson, Pielou's evenness, Berger-Parker
  dominance, and the Chao1 richness estimator — computed per plot and pooled across
  the whole sample.

- **Floristic Similarity (`floristicsimilarity`, `floristicdistance`):**
  Pairwise similarity/dissimilarity between plots using Jaccard, Sørensen, or
  Bray-Curtis.

- **Species Accumulation (`speciesaccumulation`):**
  Sample-based (collector curve) and individual-based (rarefaction) species
  accumulation curves via Monte Carlo resampling, with 95% confidence intervals.

## Example Usage

### Phytosociological Structure

```julia-repl
using ForestEcology

julia> species = ["Oak", "Oak", "Pine", "Pine", "Pine", "Maple", "Oak", "Pine"];
julia> plots = [1, 1, 1, 2, 2, 2, 3, 3];
julia> d = [30.0, 22.5, 40.0, 35.2, 28.7, 15.4, 26.1, 33.9]u"cm";
julia> area = 0.03u"ha";

julia> phytosociology(species, plots, d, area)
3×12 DataFrame
 Row │ species  n      g              plots  ADe            ADo                 RDe      RDo       AF        RF       VC        IVI
     │ String   Int64  Quantity…      Int64  Quantity…      Quantity…           Float64  Float64   Float64   Float64  Float64   Float64
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ Pine         4   0.377929 m^2      3  133.333 ha^-1   12.5976 m^2 ha^-1     50.0  67.4266   100.0     50.0     117.427   55.8089
   2 │ Oak          3   0.163949 m^2      2    100.0 ha^-1   5.46496 m^2 ha^-1     37.5  29.2502    66.6667  33.3333   66.7502  33.3612
   3 │ Maple        1  0.0186265 m^2      1  33.3333 ha^-1  0.620883 m^2 ha^-1     12.5   3.32317   33.3333  16.6667   15.8232  10.8299
```

### Biodiversity Indices

```julia-repl
using ForestEcology

julia> diversity(plots, species)
4×9 DataFrame
 Row │ plots   richness  abundance  shannon   simpson   invsimpson  jevenness  berger    chao1
     │ Any     Int64     Int64      Float64   Float64   Float64     Float64    Float64   Float64
─────┼───────────────────────────────────────────────────────────────────────────────────────────
   1 │ 1              2          3  0.636514  0.444444     1.8       0.918296  0.666667      2.5
   2 │ 2              2          3  0.636514  0.444444     1.8       0.918296  0.666667      2.5
   3 │ 3              2          2  0.693147  0.5          2.0       1.0       0.5           3.0
   4 │ pooled         3          8  0.974315  0.59375      2.46154   0.88686   0.5           3.0

# diversity indices can also be computed directly from a vector of abundances
julia> diversity([12, 8, 5, 1])
1×8 DataFrame
 Row │ richness  abundance  shannon  simpson   invsimpson  jevenness  berger    chao1
     │ Int64     Int64      Float64  Float64   Float64     Float64    Float64   Float64
─────┼──────────────────────────────────────────────────────────────────────────────────
   1 │        4         26  1.16188  0.653846     2.88889    0.83812  0.461538      4.0
```

### Floristic Similarity

```julia-repl
using ForestEcology

julia> floristicsimilarity(plots, species)
3×4 DataFrame
 Row │ plots  1         2         3
     │ Int64  Float64   Float64   Float64
─────┼─────────────────────────────────────
   1 │     1  1.0       0.333333  1.0
   2 │     2  0.333333  1.0       0.333333
   3 │     3  1.0       0.333333  1.0

# other supported methods: "jaccard" (default), "sorensen", "braycurtis"
julia> matrix = communitymatrix(plots, species);
julia> floristicdistance(matrix; method="braycurtis")
3×4 DataFrame
 Row │ plots  1         2         3
     │ Int64  Float64   Float64   Float64
─────┼────────────────────────────────────
   1 │     1  0.0       0.666667      0.2
   2 │     2  0.666667  0.0           0.6
   3 │     3  0.2       0.6           0.0
```

### Species Accumulation

```julia-repl
using ForestEcology

julia> speciesaccumulation(plots, species; iterations=200)
3×5 DataFrame
 Row │ plots  richness  std       lower    upper
     │ Int64  Float64   Float64   Float64  Float64
─────┼─────────────────────────────────────────────
   1 │     1     2.0    0.0       2.0      2.0
   2 │     2     2.605  0.490077  1.63859  3.57141
   3 │     3     3.0    0.0       3.0      3.0
```

## Keywords

Forest ecology, phytosociology, community ecology, importance value index, biodiversity,
species diversity, floristic similarity, species accumulation, rarefaction, forest
inventory.

## License

This project is licensed under the MIT License.
