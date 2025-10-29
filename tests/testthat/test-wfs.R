skip_on_cran()
skip_if_offline(httr2::url_parse(sgx_base())$hostname)

test_that("wfs endpoints return valid outputs", {
  res <- list()
  res[[1]] <- bkg_admin(max = 1)
  res[[2]] <- bkg_ags(max = 1)
  res[[3]] <- bkg_ars(max = 1)
  res[[4]] <- bkg_area_codes(max = 1)
  res[[5]] <- bkg_authorities("job_centers", max = 1)
  res[[6]] <- bkg_kfz(max = 1)
  res[[7]] <- bkg_dlm("Bahnstrecke", shape = "line", max = 1)
  res[[8]] <- bkg_geonames(names = FALSE, max = 1)
  res[[9]] <- bkg_endonyms(max = 1)
  res[[10]] <- bkg_kilometrage(max = 1)
  res[[11]] <- bkg_airports(max = 1)
  res[[12]] <- bkg_crossings(max = 1)
  res[[13]] <- bkg_heliports(max = 1)
  res[[14]] <- bkg_seaports(max = 1)
  res[[15]] <- bkg_stations(max = 1)
  res[[16]] <- bkg_trauma_centers(max = 1)
  res[[17]] <- bkg_clc(max = 1)

  for (i in seq_along(res)) {
    expect_equal(nrow(res[[!!i]]), 1)
  }
})


test_that("download server can be queried", {
  nuts <- bkg_nuts(scale = "5000")
  expect_gt(nrow(nuts), 10)
})
