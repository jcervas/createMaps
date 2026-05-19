plot_election_hists <- function(
    map_old,
    map_new,
    lower = 30,
    upper = 70,
    binwidth = 5,
    winsor_range = c(30, 70),
    row_labels = c("Old Map", "New Map"),
    width = 24,
    height = 6,
    save_pdf = FALSE,
    pdf_file = "election_comparison.pdf"
) {

  elections <- names(map_new)[-1]
  brks <- seq(lower, upper, by = binwidth)
  n_elec <- length(elections)

  # ---- winsorize ----
  winsorize <- function(x, lower, upper) {
    x <- x * 100
    x[x < lower] <- lower
    x[x > upper] <- upper
    x
  }

  # ---- histogram counts helper ----
  hist_counts <- function(x) {
    hist(
      winsorize(x, winsor_range[1], winsor_range[2]),
      breaks = brks,
      plot = FALSE,
      include.lowest = TRUE,
      right = FALSE
    )$counts
  }

  # ---- plotting function ----
  draw_hist <- function(x, title = "", ymax = NULL, show_y = FALSE) {

    xw <- winsorize(x, winsor_range[1], winsor_range[2])

    h <- hist(
      xw,
      breaks = brks,
      freq = TRUE,
      include.lowest = TRUE,
      right = FALSE,
      xlim = c(lower, upper),
      ylim = c(0, ymax),
      main = title,
      xlab = "",
      ylab = "",
      xaxt = "n",
      yaxt = "n",
      col = NA,
      border = NA
    )

    # ---- colors + transparency ----
    base_cols <- ifelse(h$mids < 50, "#F0A1A0", "#8CC1EB")

    dist50 <- abs(h$mids - 50)
    alpha_vals <- 0.2 + 0.8 * pmin(1, pmax(0, dist50 / 20))

    cols_rgb <- col2rgb(base_cols)

    bar_cols <- rgb(
      cols_rgb[1, ] / 255,
      cols_rgb[2, ] / 255,
      cols_rgb[3, ] / 255,
      alpha = alpha_vals
    )

    rect(
      h$breaks[-length(h$breaks)],
      0,
      h$breaks[-1],
      h$counts,
      col = bar_cols,
      border = "white"
    )

    # ---- x-axis (ASCII safe) ----
    axis(
      1,
      at = seq(lower, upper, by = 10),
      labels = c(
        paste0(lower, "%-"),
        paste0(seq(lower + 10, upper - 10, by = 10), "%"),
        paste0(upper, "%+")
      ),
      cex.axis = 0.7,
      tck = -0.02
    )

# ---- y-axis only first column ----
if (show_y) {
  axis(2, las = 1, cex.axis = 0.7, tck = -0.02)
}

# ---- faint horizontal reference lines ----
y_ticks <- axTicks(2)

abline(
  h = y_ticks,
  col = rgb(0, 0, 0, alpha = 0.08),
  lwd = 0.8
)

# ---- 50% reference line ----
abline(v = 50, lty = 3, col = "gray50")
  }

  # ---- shared y-scale (district counts) ----
  max_count <- 0

  for (e in elections) {
    max_count <- max(
      max_count,
      hist_counts(map_old[[e]]),
      hist_counts(map_new[[e]])
    )
  }

  # ---- device handling (robust) ----
  dev_id <- NULL

  if (save_pdf) {
    pdf(pdf_file, width = width, height = height)
    on.exit(dev.off(), add = TRUE)
  } else {
    dev.new(width = width, height = height)
  }

  # ---- layout ----
  layout(
    matrix(1:(2 * (n_elec + 1)), nrow = 2, byrow = TRUE),
    widths = c(0.6, rep(1, n_elec))
  )

  par(mar = c(2, 1.5, 2, 1))

  # ---- top label ----
  plot.new()
  text(0.5, 0.5, row_labels[1], srt = 90, cex = 1.1)

  # ---- top row ----
  for (i in seq_along(elections)) {
    draw_hist(
      map_old[[elections[i]]],
      title = elections[i],
      ymax = max_count,
      show_y = (i == 1)
    )
  }

  # ---- bottom label ----
  plot.new()
  text(0.5, 0.5, row_labels[2], srt = 90, cex = 1.1)

  # ---- bottom row ----
  for (i in seq_along(elections)) {
    draw_hist(
      map_new[[elections[i]]],
      ymax = max_count,
      show_y = (i == 1)
    )
  }

  # ---- close device safely ----
  if (!is.null(dev_id)) dev.off()
}

plot_election_hists(
    map_old,
    map_new,
    lower = 35,
    upper = 65,
    binwidth = 5,
    winsor_range = c(35, 65),   # NEW: controls winsorization bounds
    row_labels = c("2022 Map", "2026 Proposed Map"),
    width = 24,
    height = 6,
    save_pdf = T,
    pdf_file = "SC_election_comparison.pdf"
)
