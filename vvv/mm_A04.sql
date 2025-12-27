SELECT
	tso.txtype AS txtype,
	tso.txdate AS txdate,
	tso.txno AS txno,
IF
	( tso.flow_refdoctype LIKE '%ob%', ob.txdate, IF ( tso.flow_refdoctype LIKE '%tsr%', tsr.txdate, '' ) ) AS flow_refdocdate,
	tso.flow_refdocno,
	tso.movementtypecode AS movcode,
	tsodetail.materialgroupcode AS materialgroupcode,
	tsodetail.materialgroupname AS materialgroupname,
	tsodetail.materialtypecode AS materialtypecode,
	tsodetail.materialtypename AS materialtypename,
	ifnull( ( tso.movementtypename ), '' ) AS movementtypename,
	ifnull( ( tso.document_categoryname ), '' ) AS itemcat,
IF
	( tso.storagelocation_toCode IS NULL, '', tso.storagelocation_toCode ) AS storagelocationtocode,
IF
	( tso.storagelocation_toName IS NULL, '', tso.storagelocation_toName ) AS storagelocationtoname,
	tso.refdocdate AS refdocdate,
	tso.refdocno AS refdocno,
	tso.STATUS AS STATUS,
	tso.remark AS remark,
	tso.storagelocation_toCode AS storagelocation_toCode,
	tso.storagelocation_fromCode AS storagelocation_fromCode,
IF
	( tso.storagelocation_fromCode IS NULL, '', tso.storagelocation_fromCode ) AS storagelocationfromcode,
IF
	( tso.storagelocation_fromName IS NULL, '', tso.storagelocation_fromName ) AS storagelocationfromname,
IF
	( tsodetail.materialcode IS NULL, '', tsodetail.materialcode ) AS materialcode,
IF
	( tsodetail.materialname IS NULL, '', tsodetail.materialname ) AS materialname,
IF
	( tsodetail.uomname IS NULL, '', tsodetail.uomname ) AS uomname,
IF
	( uom2.NAME IS NULL, '', uom2.NAME ) AS uom2name,
IF
	( tso.storagelocation_toCode IS NULL, '', tso.storagelocation_toCode ) AS storagelocationto,
IF
	( tso.storagelocation_toName IS NULL, '', tso.storagelocation_toName ) AS storagelocationto,
	tsodetail.quantity AS quantity,
	tsodetail.quantity2 AS quantity2,
	tsodetail.from_batchnumberCode AS from_batchnumberCode,
	tsodetail.to_batchnumberCode AS to_batchnumberCode,
	tsodetail.from_stockstatusCode AS from_stockstatusCode,
	tsodetail.to_stockstatusCode AS to_stockstatusCode,
	tsodetail.from_stockstatusName AS from_stockstatusName,
	tsodetail.to_stockstatusName AS to_stockstatusName,
	tsodetail.from_storagelocationCode AS from_storagelocationCode,
	tsodetail.to_storagelocationCode AS to_storagelocationCode,
IF
	(
		$P{sort_order1}= 'movcode',
		tso.MOVEMENTTYPENAME,
	IF
		(
			$P{sort_order1}= 'status',
			tso.STATUS,
		IF
			(
				$P{sort_order1}= 'txdate',
				DATE_FORMAT( tso.txdate, '%Y-%m-%d' ),
			IF
				((
						$P{sort_order1}= 'storagelocationfromcode' 
						),
					tso.storagelocation_fromname,
				IF
				(($P{sort_order1}= 'storagelocationtocode'), tso.storagelocation_toname, '' ))))) AS sort_field1,
IF
	(
		$P{sort_order2}= 'movcode',
		tso.MOVEMENTTYPENAME,
	IF
		(
			$P{sort_order2}= 'status',
			tso.STATUS,
		IF
			(
				$P{sort_order2}= 'txdate',
				DATE_FORMAT( tso.txdate, '%Y-%m-%d' ),
			IF
				((
						$P{sort_order2}= 'storagelocationfromcode' 
						OR $P{sort_order2}= 'storagelocationfromname' 
						),
					tso.storagelocation_fromname,
				IF
				(($P{sort_order2}= 'storagelocationtocode'), tso.storagelocation_toname, '' ))))) AS sort_field2,
	tsodetail.stocktypecode AS stocktypecode 
FROM view_mm_tso_header AS tso
LEFT JOIN view_mm_tso_material AS tsodetail ON tso.ID = tsodetail.TRANSFERSTOCKID
LEFT JOIN unitofmeasureunitofmeasure uom2 ON tsodetail.order_unit2id = uom2.id
LEFT JOIN outbounddeliveryoutbounddelivery AS ob ON tso.flow_refdocno = ob.txno
LEFT JOIN transferstockrequesttransferstockrequest AS tsr ON tso.flow_refdocno = tsr.txno 
WHERE
	1 = 1 $P!{ExternalWhereClause} 
ORDER BY
	$P!{sort_order1},
	$P!{sort_order2},
	tso.txno