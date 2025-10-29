old <- options(ffm_query_language = "cql")
on.exit(options(old))

str_count <- function(pattern, text) {
  sum(gregexpr(pattern, text, fixed = TRUE)[[1]] > 0)
}

test_that("filter validation works", {
  expect_error(wfs_filter("a"), "Invalid filter query")
  expect_error(wfs_filter("a" == "test"), "column in the output")
})


test_that("objects do what they should", {
  expect_null(new_filter(NULL))
  expect_output(print(new_filter("test = 'a'")), "test = 'a'", fixed = TRUE)
})


# CQL ----
test_that("cql filters works with vectors", {
  expect_equal(unclass(wfs_filter(test == "a")), "test = 'a'")
  expect_equal(unclass(wfs_filter(test %in% "a")), "test IN 'a'")
  expect_equal(unclass(wfs_filter(test > 1)), "test > 1")
  expect_equal(unclass(wfs_filter(test < 1)), "test < 1")
  expect_equal(unclass(wfs_filter(test >= 2)), "test >= 2")
  expect_equal(unclass(wfs_filter(test <= 2)), "test <= 2")
  expect_equal(unclass(wfs_filter(test %LIKE% "a")), "test LIKE 'a'")
  expect_equal(unclass(wfs_filter(test %ILIKE% "a")), "test ILIKE 'a'")
  expect_error(wfs_filter(test && 1), "not supported")

  vec <- c("a", "b")
  expect_equal(unclass(wfs_filter(test == vec)), "test = ('a', 'b')")
})


test_that("cql filters can do spatial predicates", {
  bbox <- sf::st_bbox(c(xmin = 1, xmax = 2, ymin = 3, ymax = 4))
  fl1 <- wfs_filter(bbox = bbox)
  fl2 <- wfs_filter(poly = sf::st_as_sfc(bbox))
  expect_match(fl1, "1 3, 2 3, 2 4, 1 4, 1 3", fixed = TRUE)
  expect_match(fl2, "1 3, 2 3, 2 4, 1 4, 1 3", fixed = TRUE)

  fl3 <- wfs_filter(bbox = bbox, predicate = "equals")
  expect_match(fl3, "equals(", fixed = TRUE)

  expect_match(
    wfs_filter(bbox = bbox, geom_property = "geometry"),
    "geometry",
    fixed = TRUE
  )

  expect_match(
    wfs_filter(poly = sf::st_set_crs(sf::st_as_sfc(bbox), 3035), default_crs = 4326),
    "-29.08683 12.9936",
    fixed = TRUE
  )

  expect_error(wfs_filter(bbox = c(1,2,3,4)), "not a valid bbox")
})


test_that("cql filters can do multiple filters", {
  bbox <- sf::st_bbox(c(xmin = 1, xmax = 2, ymin = 3, ymax = 4))

  fl1 <- wfs_filter(test == "a", bbox = bbox)
  fl2 <- wfs_filter(test == "a", poly = sf::st_as_sfc(bbox))
  fl3 <- wfs_filter(bbox = bbox, poly = sf::st_as_sfc(bbox))
  expect_match(fl1, "'a' AND intersects", fixed = TRUE)
  expect_match(fl2, "'a' AND intersects", fixed = TRUE)
  expect_match(fl3, "1 3))) AND intersects", fixed = TRUE)
})


# XML ----
old <- options(ffm_query_language = "xml")
on.exit(options(old))

test_that("xml filters works with vectors", {
  fl1 <- wfs_filter(test == "a")
  fl2 <- wfs_filter(test %in% "a")
  fl3 <- wfs_filter(test > 1)
  fl4 <- wfs_filter(test < 1)
  fl5 <- wfs_filter(test >= 2)
  fl6 <- wfs_filter(test <= 2)
  fl7 <- wfs_filter(test %LIKE% "a")
  expect_error(wfs_filter(test %ILIKE% "a"))

  expect_match(format(fl1), "^<fes:Filter>")
  expect_match(format(fl1), "<fes:PropertyIsEqualTo>")
  expect_match(format(fl2), "<fes:PropertyIsEqualTo>")
  expect_match(format(fl3), "<fes:PropertyIsGreaterThan>")
  expect_match(format(fl4), "<fes:PropertyIsLessThan>")
  expect_match(format(fl5), "<fes:PropertyIsGreaterThanOrEqualTo>")
  expect_match(format(fl6), "<fes:PropertyIsLessThanOrEqualTo>")
  expect_match(format(fl7), "<fes:PropertyIsLike wildCard=\"%\" singleChar=\"_\" escapeChar=\"\\\\\">")

  vec <- c("a", "b")
  fl8 <- wfs_filter(test == vec)

  expect_equal(str_count("PropertyIsEqualTo", format(fl8)), 4)
})


test_that("xml filters can do spatial predicates", {
  bbox <- sf::st_bbox(c(xmin = 1, xmax = 2, ymin = 3, ymax = 4))
  fl1 <- format(wfs_filter(bbox = bbox))
  fl2 <- format(wfs_filter(poly = sf::st_as_sfc(bbox)))
  expect_match(fl1, "<gml:posList>1 3 2 3 2 4 1 4 1 3</gml:posList>", fixed = TRUE)
  expect_match(fl2, "<gml:posList>1 3 2 3 2 4 1 4 1 3</gml:posList>", fixed = TRUE)

  fl3 <- format(wfs_filter(bbox = bbox, predicate = "equals"))
  expect_match(fl3, "<fes:Equals>", fixed = TRUE)

  expect_match(
    format(wfs_filter(bbox = bbox, geom_property = "geometry")),
    "<fes:ValueReference>geometry</fes:ValueReference>",
    fixed = TRUE
  )

  expect_match(
    format(wfs_filter(poly = sf::st_set_crs(sf::st_as_sfc(bbox), 3035), default_crs = 4326)),
    "12.9936038242606 -29.0868349643602",
    fixed = TRUE
  )

  expect_error(wfs_filter(bbox = c(1,2,3,4)), "not a valid bbox")
})


test_that("xml filters can do multiple filters", {
  bbox <- sf::st_bbox(c(xmin = 1, xmax = 2, ymin = 3, ymax = 4))

  fl1 <- format(wfs_filter(test == "a", bbox = bbox))
  fl2 <- format(wfs_filter(test == "a", poly = sf::st_as_sfc(bbox)))
  fl3 <- format(wfs_filter(bbox = bbox, poly = sf::st_as_sfc(bbox)))
  expect_match(fl1, "<fes:And>", fixed = TRUE)
  expect_match(fl1, "<fes:PropertyIsEqualTo>", fixed = TRUE)
  expect_match(fl1, "<fes:Intersects>", fixed = TRUE)
  expect_match(fl2, "<fes:And>", fixed = TRUE)
  expect_match(fl2, "<fes:PropertyIsEqualTo>", fixed = TRUE)
  expect_match(fl2, "<fes:Intersects>", fixed = TRUE)
  expect_equal(str_count("fes:Intersects", format(fl3)), 4)
})


test_that("xml helpers work", {
  expect_equal(format(wfs_filter(filter = "test")), "<fes:Filter>test</fes:Filter>")

  expect_equal(make_node("a", list()), list(list(a = list())))
  expect_null(make_node("a", NULL))
  fl <- xml_filter_single("a", "b", "c")
  expect_named(fl[[1]], "c")

  xml1 <- make_wfs_xml("test")
  expect_s3_class(xml1, c("xml_document", "xml_node"))
  expect_match(as.character(xml1), "typeNames=\"test\"")

  xml2 <- make_wfs_xml("test", properties = "prop")
  expect_match(as.character(xml2), "<wfs:PropertyName>prop</wfs:PropertyName>")
  expect_no_failure(make_wfs_xml("test", filter = list(NULL)))

  xml3 <- make_wfs_xml("prefix:test")
  expect_match(as.character(xml3), "xmlns:prefix")

  fl2 <- wfs_filter(test == "a")
  expect_output(print(fl2), format(fl2))
})
