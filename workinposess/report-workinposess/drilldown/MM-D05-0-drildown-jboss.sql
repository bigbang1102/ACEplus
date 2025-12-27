select a.id, a.materialgroupname, a.materialcode, a.materialname
, a.storagelocationcode, a.storagelocationname
, sum(a.total_stock) as total_stock
, sum(a.reserve_po) as reserve_po
, sum(a.reserve_so) as reserve_so
, sum(a.reserve_tso) as reserve_tso
, sum(a.total_stock+a.reserve_po-a.reserve_so+a.reserve_tso) as available
from (
	select m.id, c.name as materialgroupname, m.code as materialcode, m.name as materialname
	, d.code as storagelocationcode, d.name as storagelocationname
	, (a.open_qty+a.qty) as total_stock
	, 0 as reserve_po
	, 0 as reserve_so
	, 0 as reserve_tso
	from poststockpoststocksummary a
	inner join materialmaterial m on a.material = m.id
	inner join materialgroupmaterialgroup c on m.materialgroupid = c.id
	inner join storagelocationstoragelocation d on a.storagelocation = d.id
	left join materialmaterial_property mp on m.id = mp.materialid
	where (a.processyear=year(curdate()) and a.processmonth=month(curdate()))

	union

	select m.id, c.name as materialgroupname, m.code as materialcode, m.name as materialname
	, d.code as storagelocationcode, d.name as storagelocationname
	,0 as total_stock
	,a.qty*-1 as reserve_po
	,0 as reserve_so
	,0 as reserve_tso
	from outstanding_po_summary a
	inner join materialmaterial m on a.materialid = m.id
	inner join materialgroupmaterialgroup c on m.materialgroupid = c.id
	inner join storagelocationstoragelocation d on a.storagelocationid = d.id
	left join materialmaterial_property mp on m.id=mp.materialid

	union

	select m.id, c.name as materialgroupname, m.code as materialcode, m.name as materialname
	, d.code as storagelocationcode, d.name as storagelocationname
	,0 as total_stock
	,0 as reserve_po
	,a.qty as reserve_so
	,0 as reserve_tso
	from outstanding_so_summary a
	inner join materialmaterial m on a.materialid = m.id
	inner join materialgroupmaterialgroup c on m.materialgroupid = c.id
	inner join storagelocationstoragelocation d on a.storagelocationid = d.id
	left join materialmaterial_property mp on m.id=mp.materialid

	union

	select m.id, c.name as materialgroupname, m.code as materialcode, m.name as materialname
	, d.code as storagelocationcode, d.name as storagelocationname
	,0 as total_stock
	,0 as reserve_po
	,0 as reserve_so
	,a.qty as reserve_tso
	from outstanding_tso_summary a
	inner join materialmaterial m on a.materialid = m.id
	inner join materialgroupmaterialgroup c on m.materialgroupid = c.id
	inner join storagelocationstoragelocation d on a.storagelocationid = d.id
	left join materialmaterial_property mp on m.id = mp.materialid

) a
where true $P!{ExternalWhereClause}
group by a.materialcode,a.storagelocationcode