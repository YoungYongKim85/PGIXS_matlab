# PGIXS (MATLAB) — manual summary in English

The full user manual, [`manual_ko.md`](manual_ko.md), is in Korean, because the
people who use this software at the beamline read Korean. This page is a
condensed English version of it: enough to understand what each tool does, how
the reduction works, and how this implementation relates to the Python one,
without translating 700 lines.

For installing and running, see the [README](../README.md). For a step-by-step
walkthrough on data you can generate yourself, the Python version's
[quickstart](https://github.com/YoungYongKim85/PGIXS_python/blob/main/docs/quickstart.md)
covers the same workflow in English.

---

## What it is

PGIXS reduces area-detector frames from grazing-incidence and transmission
X-ray scattering experiments at the 3C beamline of the Pohang Accelerator
Laboratory. It covers the whole path from a raw frame to a publishable curve:
calibrating the sample-detector distance against a standard, mapping detector
pixels into reciprocal space, applying detector corrections, cutting 1D and
azimuthal profiles, and analysing *in-situ* frame series against time,
temperature or incidence angle.

`PGIXS.m` opens a console window that launches the individual tools; it does no
computation itself.

| Tool | What it does |
| --- | --- |
| **SDD calculator** | Beam centre and sample-detector distance from a standard (silver behenate, SEBS, mesoporous silica, sucrose). Writes the calibration the other tools read. |
| **GIXS** | Single grazing-incidence frame: Q maps, detector corrections, line/cake/accumulation cuts, azimuthal profiles. |
| **GIXS-series** | The same across a frame sequence, plotted against time, temperature or incidence angle, with heatmaps and region-of-interest tracking. |
| **TrXS** | Single transmission frame. Its primary 1D reduction is a circular (q-binned) average. |
| **TrXS-series** | Transmission sequences, with background subtraction and normalisation. |
| **Transmittance** | X-ray transmittance of a material versus photon energy. |
| **Penetration Depth** | Penetration depth versus incidence angle, with the critical angle. Used to choose an incidence angle before measuring. |
| **Converter** | HDF5 to TIFF. |

A separate set of crystal-indexing tools exists in the source tree but is
excluded from the end-user distribution and from the manual.

## The order things happen in

Nothing downstream works until **q-Map Cal.** (single frame) or **q-Cal.**
(series) has run, and that in turn needs a calibration loaded with **Load
Info**. The buttons are deliberately inert before then.

```
  calibrant frame                     sample frames
        |                                   |
        v                                   |
  [SDD calculator]                          |
   beam centre + SDD                        |
   -> *_standard.mat / .std / .json         |
        |                                   |
        +---------------+-------------------+
                        v
             [GIXS] or [TrXS]        single frame
              Load Info -> q-Map Cal. -> 1D / azimuthal cut
                        |
                        +--> [GIXS-series] / [TrXS-series]
                               reduced against time / temperature / angle
```

## What q-Map Cal. actually does

Two things at once.

**Reciprocal-space mapping.** Each pixel is mapped to (q<sub>xy</sub>,
q<sub>z</sub>) or (q<sub>y</sub>, q<sub>z</sub>). For grazing incidence the
incidence angle enters the mapping, so the result is not symmetric about the
beam centre.

**Detector corrections.** Intensity is divided by

```
solid angle  x  polarization  x  Kapton window transmission  [ x  silicon sensor absorption, Eiger4M ]
```

It also regrids the frame onto a uniform Q grid (`Itrans`) and into
(2θ<sub>f</sub>, α<sub>f</sub>) coordinates. Selecting a Q-space **Map format**
makes the 1D and azimuthal cuts operate on the regridded image, so coverage
gaps that exist only in reciprocal space — the "missing wedge" near
q<sub>xy</sub> ≈ 0 — show up in the cut instead of being interpolated over.

## Concepts worth knowing before reading results

**Detector mask.** Known bad pixels and inactive areas are excluded as NaN when
a frame is loaded: about 6.2% of an Eiger4M, about 21.6% of a MarCCD/SX165.

**Gap-edge buffer (3 px).** Pixels immediately bordering a detector module gap
can carry biased counts — incomplete charge collection, or charge shared with a
neighbour. A 3-pixel dilation of the mask is therefore excluded from the 1D
reductions, but **not** from the displayed 2D image or from ROI sums. Excluded
pixels stay in the geometry, so they lower coverage rather than silently
shrinking the sample a bin was averaged from.

**Coverage.** `valid data pixels / pixels geometrically belonging to the bin`,
between 0 and 1. In TrXS circular averaging the **Min cov** field is a real
cutoff: bins below it are set to NaN. A curve with gaps in a narrow angular
sector usually means bins were dropped for crossing module gaps, which is the
intended behaviour rather than a fault.

**Mean vs. Median.** In this implementation *Mean* is a plain arithmetic mean
(`processPGIXSRadiusBin1D`); *Median* is the median. The Python implementation
uses the same arithmetic mean since its v0.3.14 (it used a Huber M-estimator
before).

**Multishot averaging.** Frames are summed and divided by the file count, so a
pixel that is NaN in any one shot is NaN in the average. The Python version
averages whichever shots are valid; that difference was reviewed and the Python
behaviour judged the better one, but this implementation was left as it is.

## Relationship to the Python implementation

The [Python version](https://github.com/YoungYongKim85/PGIXS_python) covers the
same reduction workflow and needs no MATLAB licence. It is an independent
implementation, not a translation, which is what makes agreement between the
two meaningful — and disagreement informative.

### Scope

| | MATLAB | Python |
| --- | --- | --- |
| SDD calibration, GIXS, TrXS, series tools, transmittance, penetration depth | yes | yes |
| HDF5-to-TIFF converter | yes | no |
| Crystal-structure indexing tools | yes | no |
| MATLAB licence required | yes | **no** |
| Prebuilt binaries | — | Windows, macOS, Linux |

### What must agree, and does

Measured on real beamline frames with identical calibration inputs:

| Quantity | Result |
| --- | --- |
| Peak positions (q, azimuthal angle) | agree to **≤ 6×10⁻⁴ Å⁻¹**, far below one bin |
| Signed median intensity difference | −0.16% / +0.57% / −0.68% (vertical cut / horizontal cut / azimuthal) |
| Bin count and NaN positions | identical — 1937 bins, the same 70 NaN positions, in TrXS circular averaging |

These depend on beam centre, SDD, energy and the detector corrections all being
right, so they are the checks that matter.

### What differs by design

| Reduction | MATLAB | Python |
| --- | --- | --- |
| GIXS 1D line cut | one bilinearly interpolated ray | ±1° wedge averaged into q bins |
| GIXS azimuthal | polar grid at 0.2°, nearest pixel | real annulus pixels binned at 1° |
| Multishot averaging | NaN in any shot ⇒ NaN | valid shots only |

Consequences that are expected rather than faults:

- **Python's curves start later.** A ±1° wedge holds less than one pixel below
  a radius of about 26 px, so there are no bins below q ≈ 0.046 Å⁻¹ on a
  typical geometry. The MATLAB ray interpolates and returns a value even inside
  the beamstop, where it is not physically trustworthy.
- **The horizontal cut scatters more than the vertical one.** The wedge
  half-width grows with radius (±4.7 px at q = 0.5, ±14 px at q = 1.5) and, in
  grazing incidence, the horizontal direction crosses the fast-varying
  Yoneda/horizon region. Median relative difference 17.7% against 6.0% for the
  vertical cut. Its signed median (+2.9%) is the largest of the set, because the
  wedge takes in the brighter pixels just above the horizon.
  Where counts are low this is the Poisson noise on MATLAB's single ray; the
  Python estimate is the less noisy of the two.
- **The TrXS circular average agrees closely** (median 0.07%, at most 0.2%):
  both take the arithmetic mean of the same pixels in the same bins.
- **q axes differ by ~1×10⁻⁵ relative**, because the two codebases use slightly
  different values of *hc* (12.3985167 vs. 12.3984198 keV·Å). 7.8 ppm, of no
  practical consequence.

### Checking it yourself

The Python repository carries a cross-check harness under
[`tools/matlab_crosscheck/`](https://github.com/YoungYongKim85/PGIXS_python/tree/main/tools/matlab_crosscheck).
Both sides read one JSON configuration, so neither can quietly use a different
beam centre or SDD:

```
matlab -batch "restoredefaultpath; addpath('tools/matlab_crosscheck'); run_matlab('tools/matlab_crosscheck/config.example.json')"
python tools/matlab_crosscheck/run_python.py tools/matlab_crosscheck/config.example.json
python tools/matlab_crosscheck/compare.py    tools/matlab_crosscheck/config.example.json --plot compare.png
```

Read the report by its **peak positions** and **signed median difference**. The
relative-difference median is expected to be nonzero and is a noise measure,
not an error measure.

## Two things that will waste your time if you do not know them

**MATLAB remembers its path between sessions.** A directory added earlier can
shadow `functions/` — in particular the generated `dist/build/` package, which
`addpath(genpath(...))` puts first. This has already caused a comparison to
measure a stale copy and be believed. If a result looks impossible:

```matlab
restoredefaultpath
cd /path/to/PGIXS_matlab
PGIXS
```

**`dist/build/` does not regenerate itself.** It is the compile-ready copy
handed to the MATLAB Compiler. The test suite fails if it has fallen behind the
source; regenerate with `run('dist/build_dist_package.m')` before building.

## Tests

```matlab
cd /path/to/PGIXS_matlab
run('tests/run_pgixs_core_tests.m')
```

Covers the reduction and calibration routines in `functions/`, the detector
pixel-size table, and the freshness of `dist/build`.
