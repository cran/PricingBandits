## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>",
                      fig.width = 7.5, fig.height = 5)

## ----setup--------------------------------------------------------------------
library(PricingBandits)

## ----valuations, eval = FALSE-------------------------------------------------
# set.seed(29)
# valuations <- rbeta(1000, 2, 9)
# prices     <- seq(10)/10          # ten candidate prices: 0.1, 0.2, ..., 1.0

## ----runs, eval = FALSE-------------------------------------------------------
# run <- function(policy, hetero = FALSE) {
#   set.seed(1)
#   PricingBandit(valuations, prices,
#                 policy     = policy,
#                 batch_size = 10,
#                 hetero     = hetero)
# }
# 
# # Baselines: each arm learned independently
# out_ucb  <- run("UCB")
# out_ts   <- run("TS")
# 
# # Gaussian-process variants: the demand curve correlates the arms
# out_gpucb <- run("GP-UCB")
# out_gpts  <- run("GP-TS")
# 
# # Monotonic variants (basis-function construction; num_knots = 11 default)
# out_gpucb_m <- run("GP-UCB-M")
# out_gpts_m  <- run("GP-TS-M")
# 
# # Heterogeneous-noise versions of the monotonic algorithms
# out_gpucb_m_h <- run("GP-UCB-M", hetero = TRUE)
# out_gpts_m_h  <- run("GP-TS-M",  hetero = TRUE)

## ----metric, eval = FALSE-----------------------------------------------------
# expected_reward <- prices * (1 - pbeta(prices, 2, 9))
# grid            <- seq(1e-6, 1, 1e-6)
# true_optimal    <- max(grid * (1 - pbeta(grid, 2, 9)))
# 
# score <- function(out) {
#   er <- expected_reward[match(out$PricesTested, prices)]
#   cumsum(er) / (seq_along(er) * true_optimal) * 100
# }

## ----assemble, eval = FALSE---------------------------------------------------
# runs <- list("UCB"    = out_ucb,     "TS"      = out_ts,
#              "GP-UCB" = out_gpucb,   "GP-TS"   = out_gpts,
#              "GP-UCB-M" = out_gpucb_m, "GP-TS-M" = out_gpts_m,
#              "GP-UCB-M (hetero)" = out_gpucb_m_h,
#              "GP-TS-M (hetero)"  = out_gpts_m_h)
# 
# res <- do.call(rbind, lapply(names(runs), function(nm) {
#   data.frame(policy   = sub(" (hetero)", "", nm, fixed = TRUE),
#              hetero   = grepl("hetero", nm),
#              label    = nm,
#              consumer = seq_along(valuations),
#              cum_pct_optimal = score(runs[[nm]]))
# }))

## ----plot, echo = TRUE--------------------------------------------------------
res <- readRDS("vignette_results.rds")$results

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  res$family <- ifelse(grepl("TS", res$policy), "Thompson Sampling family",
                       "UCB family")
  res$variant <- ifelse(res$hetero, "heterogeneous noise", "standard")
  ggplot(res, aes(consumer, cum_pct_optimal, colour = policy,
                  linetype = variant)) +
    geom_line(linewidth = 0.6) +
    facet_wrap(~ family) +
    labs(x = "Consumers", y = "Cumulative revenue (% of true optimal)",
         colour = NULL, linetype = NULL,
         title = "All algorithms on the same 1,000 Beta(2,9) consumers") +
    coord_cartesian(ylim = c(0, 100)) +
    theme_minimal() +
    theme(legend.position = "bottom")
} else {
  final <- res[res$consumer == 1000, c("label", "cum_pct_optimal")]
  final[order(-final$cum_pct_optimal), ]
}

## ----table, echo = FALSE------------------------------------------------------
final <- res[res$consumer == 1000, c("label", "cum_pct_optimal")]
final <- final[order(-final$cum_pct_optimal), ]
knitr::kable(final, digits = 1, row.names = FALSE,
             col.names = c("Algorithm", "% of optimal (cumulative, 1000 consumers)"))

## ----diag, eval = FALSE-------------------------------------------------------
# attr(out_gpts_m, "diagnostics")

