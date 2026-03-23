#' Autoregressive Changepoint Detection
#'
#' Fits a changepoint model to time series data using an Autoregressive (AR1 or AR2)
#' structure, optionally with a linear trend.
#'
#' @param data A numeric vector containing the time series data.
#' @param order Integer. The order of the AR model (1 or 2). Default is 1.
#' @param trend Logical. Should a linear trend be included? Default is FALSE.
#' @param method Character. The changepoint algorithm to use ("PELT" or "AMOC"). Default is "PELT".
#' @param penalty Character. The penalty to use (e.g., "MBIC", "AIC"). Default is "MBIC".
#' @param minseglen Integer. Minimum segment length. Default is 3.
#'
#' @return An object of class \code{cpt.reg} from the \code{changepoint} package.
#' @export
#'
#' @examples
#' set.seed(42)
#' # Simulate AR(1) with a change in phi
#' x <- c(arima.sim(list(ar = 0.8), n = 100), arima.sim(list(ar = -0.5), n = 100))
#'
#' # Fit the model
#' result <- cptAR(x, order = 1, trend = FALSE)
#' changepoint::cpts(result)
cptAR <- function(data, order = 1, trend = FALSE, method = "PELT", penalty = "MBIC", minseglen = 3) {

  # ── 1. Input Validation Checks ──────────────────────────────────────────────
  if (!is.numeric(data)) stop("Argument 'data' must be a numeric vector.")
  if (any(is.na(data))) stop("Argument 'data' cannot contain missing values.")
  if (!order %in% c(1, 2)) stop("Argument 'order' must be exactly 1 or 2.")
  if (!is.logical(trend)) stop("Argument 'trend' must be a logical value (TRUE or FALSE).")
  if (!is.character(method) || length(method) != 1) stop("Argument 'method' must be a single string.")

  n <- length(data)

  # ── 2. Format Data Matrix ───────────────────────────────────────────────────
  if (order == 1) {
    if (n <= 2) stop("Data is too short to fit an AR(1) model.")

    y <- data[-1]
    intercept <- rep(1, n - 1)
    lag1 <- data[-n]

    if (trend) {
      t_seq <- 2:n
      reg_mat <- cbind(y, intercept, t_seq, lag1)
    } else {
      reg_mat <- cbind(y, intercept, lag1)
    }

  } else if (order == 2) {
    if (n <= 3) stop("Data is too short to fit an AR(2) model.")

    y <- data[-c(1, 2)]
    intercept <- rep(1, n - 2)
    lag1 <- data[2:(n - 1)]
    lag2 <- data[1:(n - 2)]

    if (trend) {
      t_seq <- 3:n
      reg_mat <- cbind(y, intercept, t_seq, lag1, lag2)
    } else {
      reg_mat <- cbind(y, intercept, lag1, lag2)
    }
  }

  # ── 3. Call Internal EnvCpt Function ────────────────────────────────────────
  ans <- EnvCpt:::cpt.reg(
    data = reg_mat,
    method = method,
    penalty = penalty,
    minseglen = minseglen
  )

  return(ans)
}
