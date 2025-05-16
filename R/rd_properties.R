rd_properties_list <- function(..., case = "lower", extra = NULL) {
  args <- rlang::enquos(...)
  prop_names <- vapply(
    unname(args),
    function(x) rlang::expr_deparse(rlang::quo_get_expr(x)),
    character(1)
  )
  props_documented <- prop_names %in% names(rd_properties)

  if (!all(props_documented)) {
    not_docd <- prop_names[!props_documented]
    cli::cli_abort("Some properties are undocumented: {not_docd}")
  }

  props_duped <- duplicated(names(rd_properties))
  if (any(props_duped)) {
    duped <- prop_names[props_duped]
    cli::cli_abort("Some properties are documented more than once: {duped}")
  }

  props <- rd_properties[prop_names]
  props <- c(props, extra)
  prop_names <- names(props)
  if (identical(case, "upper")) {
    prop_names <- toupper(prop_names)
  }
  items <- sprintf("\\item{\\code{%s}}: %s", prop_names, props)
  items <- paste(items, collapse = "\n")
  sprintf("\\itemize{\n%s\n}", items)
}


rd_properties <- list(
  objid = "Unique object identifier",
  beginn = "Date at which the dataset was last added or changed",
  agz = "Type of border. Can be one of \\itemize{
    \\item{1: National border}
    \\item{2: State border}
    \\item{3: Governmental district border}
    \\item{4: District border}
    \\item{5: Administrative association border}
    \\item{6: Municipality border}
    \\item{9: Coastline}
  }",
  ade = "Integer representing the administrative level. Can
    be one of \\itemize{
      \\item{1: Germany}
      \\item{2: Federal state}
      \\item{3: Governmental district}
      \\item{4: District}
      \\item{5: Administrative association}
      \\item{6: Municipality}
    }",
  gf = "Integer representing the geofactor; whether an area is
    \"structured\" or not. Land is structured if it is part of a state or other
    administrative unit but is not further divided into administrative units.
    Can be one of \\itemize{
      \\item{1: Unstructured, waterbody}
      \\item{2: Structured, waterbody}
      \\item{3: Unstructured, land}
      \\item{4: Structured, land}
    }",
  bsg = "Special areas, can be 1 (Germany) or 9 (Lake Constance)",
  ars = "Official regional key (Amtlicher Regionalschlüssel).
    The ARS is stuctured hierarchically as follows: \\itemize{
      \\item{Position 1-2: Federal state}
      \\item{Position 3: Government region}
      \\item{Position 4-5: District}
      \\item{Position 6-9: Administrative association}
      \\item{Position 10-12: Municipality}
    }",
  ags = "Official municipality key (Amtlicher Gemeindeschlüssel).
    Related to the ARS but shortened to omit position 6 to 9. Structured as
    follows: \\itemize{
      \\item{Position 1-2: Federal state}
      \\item{Position 3: Government region}
      \\item{Position 4-5: District}
      \\item{Position 6-8: Municipality}
    }",
  sdv_ars = "ARS of the seat of administration",
  gen = "Geographical name",
  bez = "Label of the administrative unit",
  ibz = "Identifier of the label",
  bem = "Comment on the label",
  nbd = "Formation of the geographical name. Can be \"ja\" if
    the label is part of the name or \"nein\" otherwise.",
  nuts = "NUTS identifier based on the Eurostat regional
    classification",
  ars_0 = "ARS identifier with trailing zeroes",
  ags_0 = "AGS identifier with trailing zeroes",
  wsk = "Legally relevant date for the effectiveness of administrative changes",
  sn_l = "Country component of the ARS",
  sn_r = "Governmental district component of the ARS",
  sn_k = "District component of the ARS",
  sn_v1 = "First part of the administrative association component of the ARS",
  sn_v2 = "Second part of the administrative association component of the ARS",
  sn_g = "Municipality component of the ARS",
  fk_3 = "Purpose of the third key position. If \\code{\"R\"}, indicates the
    government region, if \\code{\"K\"}, indicates the district",
  dkm_id = "Identifier in the digital landscape model (DLM250)",
  ewz = "Number of inhabitants",
  ewzger = "Computed number of inhabitants",
  kfl = "Land register area in square kilometers",
  rdg = "Legal definition of a border. Can be 1 (determined),
    2 (not determined) or 9 (coastline)",
  gm5 = "Border characteristic of administrative association
    borders (AGZ 5). Used to describe the purpose of these borders. Can
    be 0 (characteristics by AGZ) or 8 (non-association border)",
  gmk = "Border characteristic by coast/ocean. Specifies whether
    a border runs a long a waterbody. Can be one of \\itemize{
      \\item{7: borders on the ocean}
      \\item{8: auxiliary borders on the ocean}
      \\item{9: borders at the coastline}
      \\item{0: no characteristics}
    }",
  dlm_id = "Identifier in the digital landscape model (DLM250)",
  otl = "Name of the locality in the digital landscale model (DLM250)",
  lon_dez = "Decimal longitude",
  lat_dez = "Decimal latitude",
  lon_gms = "Geographical longitude",
  lat_gms = "Geographical latitude",
  nuts_level = "NUTS level. Can be one of \\itemize{
      \\item{1: NUTS-1; federal states}
      \\item{2: NUTS-2; inconsistent, somewhere between government regions and
        federal states}
      \\item{3: NUTS-3; districts}
    }",
  nuts_code = "Hierarchical key of the NUTS region. Can have a different number
    of characters depending on the NUTS level: \\itemize{
      \\item{NUTS-1: three digits}
      \\item{NUTS-2: four digits}
      \\item{NUTS-3: five digits}
    }",
  nuts_name = "Geographical name of the NUTS region",
  inspire = "INSPIRE identifier of a grid cell",
  x_sw = "X coordinate of the South-West corner of a grid cell",
  y_sw = "Y coordinate of the South-West corner of a grid cell",
  f_staat = "State area in the grid cell in square meters",
  f_land = "Land area in the grid cell in square meters",
  f_wasser = "Water area in the grid cell in square meters",
  p_staat = "Share of state area in the grid cell",
  p_land = "Share of land area in the grid cell",
  p_wasser = "Share of water area in the grid cell",
  debkgid = "Identifier in the digital landscape model DLM250",
  nnid = "National name identifier",
  name = "Name of the geographical object",
  oba = "Name of the ATKIS object type",
  kfz = "Vehicle registration area code, comma-separated in case of multiple codes",
  geola = "Geographical longitude",
  geobr = "Geographical latitude",
  geoLaenge = "Geographical longitude",
  geoBreite = "Geographical latitude",
  gkre = "Gauß-Krüger easting",
  gkho = "Gauß-Krüger northing",
  utmre = "UTM easting",
  utmho = "UTM northing",
  hoehe = "Elevation above sea level",
  hoeheger = "Computed elevation above sea level",
  groesse = "Undocumented, but I guess this relates to the suggested print
    size of the labels",
  landesCode = "Country identifier; 276 is Germany.",
  beschreibung = "Optional details",
  gemteil = "Whether the place is part of a municipality",
  virtuell = "Whether the place is a real or virtual locality",
  geschlecht = "If applicable, the grammatical gender of a geographical name"
)


ffm_run_examples <- function() {
  isTRUE(as.logical(Sys.getenv("FFM_RUN_EXAMPLES", FALSE)))
}
