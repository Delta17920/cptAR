# cptAR

[![R-CMD-check](https://github.com/Delta17920/cptAR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Delta17920/cptAR/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/Delta17920/cptAR/graph/badge.svg)](https://app.codecov.io/gh/Delta17920/cptAR)

Changepoint detection in autoregressive time series, with or without a linear trend. `cptAR` wraps the internal regression machinery of `EnvCpt` into a clean, user-facing interface - no manual lag matrix construction required.

## The problem it solves

Fitting changepoint models to AR(1) or AR(2) processes in R currently requires you to manually build a lagged covariate matrix and pass it to unexported package internals. `cptAR` handles all of that for you, and adds optional trend support on top.
```r
# Before cptAR — manual and error-prone
ar1_data <- cbind(data[-1], rep(1, n - 1), data[-n])
EnvCpt:::cpt.reg(ar1_data, method = "PELT", minseglen = 3)

# With cptAR — one line
cptAR(data, order = 1, trend = FALSE)
```

## Installation
```r
devtools::install_github("Delta17920/cptAR")
```

## Quick start
```r
library(cptAR)
library(changepoint)

set.seed(42)
x <- c(arima.sim(list(ar = 0.8), n = 100),
       arima.sim(list(ar = -0.5), n = 100))

fit <- cptAR(x, order = 1, trend = FALSE)
cpts(fit)   # detected changepoint
plot(fit)   # standard changepoint plot
```

## Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `data` | — | Numeric vector, no NAs |
| `order` | `1` | AR order: `1` or `2` |
| `trend` | `FALSE` | Add a linear trend to the model |
| `method` | `"PELT"` | `"PELT"` or `"AMOC"` |
| `penalty` | `"MBIC"` | Any penalty supported by `changepoint` |
| `minseglen` | `3` | Minimum observations per segment |

## How the matrix construction works

Under the hood, `cptAR` builds the regression matrix that `EnvCpt:::cpt.reg` expects:

- **AR(1):** `cbind(y[-1], intercept, y[-n])`
- **AR(2):** `cbind(y[-c(1,2)], intercept, lag1, lag2)`
- **With trend:** a time index column is inserted after the intercept

The returned object is a standard `cpt.reg` S4 object, fully compatible with `cpts()`, `plot()`, and `param()` from the `changepoint` package.
