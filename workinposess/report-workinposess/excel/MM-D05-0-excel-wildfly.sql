SELECT
  m.id,
  mg.name AS materialgroupname,
  m.code AS materialcode,
  m.name AS materialname,
  sl.code AS storagelocationcode,
  sl.name AS storagelocationname,

  v.total_stock,
  v.reserve_po,
  v.reserve_so,
  v.reserve_tso,
  v.available
FROM view_mm_inventory_available v
INNER JOIN materialmaterial m
  ON v.materialid = m.id
INNER JOIN materialgroupmaterialgroup mg
  ON m.materialgroupid = mg.id
INNER JOIN storagelocationstoragelocation sl
  ON v.storagelocationid = sl.id
LEFT JOIN materialmaterial_property mp
  ON mp.materialid = m.id
WHERE 1=1
  $P!{ExternalWhereClause}

