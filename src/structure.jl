"""
    phytosociology(species::AbstractVector, plots::AbstractVector, d::AbstractVector{<:Length}, area::Area)

Calculates horizontal structure parameters and phytosociological indices for a forest community based on species-level data. Phytosociological indices refer to species importance values (density, dominance, frequency), while horizontal structure parameters describe the spatial distribution and abundance of species in the community. This function follows the IUFRO international standard, distinguishing between sample-based observations (lowercase) and population estimates per unit area (uppercase).

# Arguments
* `species`: A vector of strings or symbols representing the species identity for each tree.
* `plots`: A vector representing the sampling unit (plots) identifier for each tree.
* `d`: A vector of diameters (DBH) with `Unitful` length units (e.g., `u"cm"`).
* `area`: The total sampled area with `Unitful` area units (e.g., `u"ha"`).

# Returns
A `DataFrame` sorted by Importance Value Index (IVI) descending, containing phytosociological indices (species importance values) and horizontal structure parameters:

**Sample-Level Totals (Aggregation)**
* `n`: **Sample Frequency**, the total number of individuals of a species observed across all sampling units.
* `g`: **Sample Basal Area**, the sum of individual cross-sectional areas (gi) for all trees of the species within the sample.
* `plots`: **Plots**, the number of unique plots or quadrats where the species was recorded.

**Absolute Parameters (Per Unit Area)**
* `ADe`: **Absolute Density** (Abundance), the estimated number of individuals of a species per unit area (ha or ac). It represents the species' population density.
* `ADo`: **Absolute Dominance**, the sum of tree cross-sectional areas per unit area (m²/ha or ft²/ac). It indicates the physical space and biomass occupancy of the species.
* `AF`: **Absolute Frequency**, the percentage of sampling units in which the species occurs, indicating the uniformity of its spatial distribution.

**Relative Parameters (%)**
* `RDe`: **Relative Density**, the proportion of a species' density relative to the total density of all species in the community.
* `RDo`: **Relative Dominance**, the proportion of a species' basal area relative to the total stand basal area.
* `RF`: **Relative Frequency**, the species' frequency expressed as a percentage of the sum of absolute frequencies for all species.

**Integrated Phytosociological Indices**
* `VC`: **Cover Value**, the sum of Relative Density and Relative Dominance (RDe + RDo). This index characterizes the ecological importance and space utilization of a species, emphasizing abundance and dominance over distribution.
* `IVI`: **Importance Value Index**, the mean of the three relative parameters ((RDe + RDo + RF) / 3). It provides an overall "ecological score" for the species within the community.
"""
function phytosociology(species::AbstractVector, plots::AbstractVector, d::AbstractVector{<:Length}, area::Area)
  if length(species) != length(plots) || length(plots) != length(d)
    throw(DimensionMismatch("species, plots, and d vectors must have the same length"))
  end
  N = unique(plots) |> length
  # Aggregation (Raw Sums & Counts)
  ft = combine(
    groupby(
      DataFrame(species=species, plots=plots, g=basalarea.(d)), :species
    )
  ) do s
    (
      n=nrow(s),
      g=sum(s.g),
      plots=unique(s.plots) |> length
    )
  end
  # Expansion Factor
  EF = unit(ft.g[1]) == u"m^2" ? EF = uconvert(u"ha", area) .^ -1 : uconvert(u"ac", area) .^ -1
  # ADe: Absolute Density (trees/area)
  ft.ADe = ft.n .* EF .|> float
  # ADo: Absolute Dominance (basal area/area)
  ft.ADo = ft.g .* EF .|> float
  # RDe: Relative Density (%)
  ft.RDe = (ft.ADe ./ sum(ft.ADe)) .* 100
  # RDo: Relative Dominance (%)
  ft.RDo = (ft.ADo ./ sum(ft.ADo)) .* 100
  # AF: Absolute Frequency (%)
  ft.AF = (ft.plots ./ N) .* 100
  # RF: Relative Frequency (%)
  ft.RF = (ft.AF ./ sum(ft.AF)) .* 100
  # VC: Cover Value (%)
  ft.VC = ft.RDe .+ ft.RDo
  # IVI: Importance Value Index (%)
  ft.IVI = (ft.VC .+ ft.RF) ./ 3
  # Sort by IVI descending
  sort!(ft, :IVI, rev=true)
  return ft
end

phytosociology(species::AbstractVector, plots::AbstractVector, d::AbstractVector{<:Real}, area::Real) =
  phytosociology(species, plots, d .* u"cm", area * u"ha")
