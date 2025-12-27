SELECT
    prc.txtype     AS txtype,
    prc.txdate     AS txdate,
    IF (prcdetail.detailorderno = 100, prc.txno, '') AS txno,
    IF (
        prc.flow_refdoctype LIKE '%ib%',
        ib.txdate,
        IF (
            prc.flow_refdoctype LIKE '%aj%',
            aj.txdate,
            IF (prc.flow_refdoctype LIKE '%ap%', ap.txdate, '')
        )
    ) AS flow_refdocdate,
    prc.flow_refdocno AS flow_refdocno,
    prc.movementtypecode AS movcode,
    prcdetail.materialgroupcode AS materialgroupcode,
    prcdetail.materialgroupname AS materialgroupname,
    prcdetail.materialtypecode AS materialtypecode,
    prcdetail.materialtypename AS materialtypename,
    IF (prcdetail.storagelocationcode IS NULL, '', prcdetail.storagelocationcode) AS storagelocationcode,
    IF (prcdetail.storagelocationname IS NULL, '', prcdetail.storagelocationname) AS storagelocationname,
    prc.refdocdate AS refdocdate,
    prc.refdocno AS refdocno,
    prc.status AS status,
    prc.remark AS remark,
    IFNULL(prc.document_categoryname, '') AS itemcat,
    IFNULL(prc.movementtypename, '') AS movementtype,
    IFNULL(prcdetail.storagelocationname, '') AS storagelocationName,
    IF (prc.branchcode IS NULL, '', prc.branchcode) AS branchcode,
    IF (prc.branchname IS NULL, '', prc.branchname) AS branchname,
    IF (prcdetail.materialcode IS NULL, '', prcdetail.materialcode) AS materialcode,
    IF (prcdetail.materialname IS NULL, '', prcdetail.materialname) AS materialname,
    IF (prcdetail.order_unitname IS NULL, '', prcdetail.order_unitname) AS uomname,
    IF (uom2.NAME IS NULL, '', uom2.NAME) AS uom2name,
    IF (prcdetail.storagelocationcode IS NULL, '', prcdetail.storagelocationcode) AS storagelocation,
    IF (prcdetail.storagelocationname IS NULL, '', prcdetail.storagelocationname) AS storagelocation,
    ROUND(prcdetail.quantity,2) AS quantity,
    prcdetail.batchnumbercode AS batchnumbercode,
    prcdetail.serialnumbercode AS serialnumbercode,
    prcdetail.stockstatuscode AS stockstatuscode,
    prcdetail.stockstatusname AS stockstatusname,
    ROUND(prcdetail.cost_per_unit,2) AS cost_per_unit,
    ROUND(prcdetail.cost_amount,2) AS cost_amount,

    -- SORT FIELD 1
    IF (
        $P{sort_order1} = 'movcode',
        prc.movementtypename,
        IF (
            $P{sort_order1} = 'status',
            prc.status,
            IF (
                $P{sort_order1} = 'txdate',
                DATE_FORMAT(prc.txdate, '%Y-%m-%d'),
                IF (
                    (
                        $P{sort_order1} = 'branchname' 
                        OR $P{sort_order1} = 'branchcode' 
                    ),
                    prc.branchname,
                    IF (
                        (
                            $P{sort_order1} = 'storagelocationname' 
                            OR $P{sort_order1} = 'storagelocationcode'
                        ),
                        prc.storagelocationname,
                        ''
                    )
                )
            )
        )
    ) AS sort_field1,

    -- SORT FIELD 2
    IF (
        $P{sort_order2} = 'movcode',
        prc.movementtypename,
        IF (
            $P{sort_order2} = 'status',
            prc.status,
            IF (
                $P{sort_order2} = 'txdate',
                DATE_FORMAT(prc.txdate, '%Y-%m-%d'),
                IF (
                    (
                        $P{sort_order2} = 'branchname' 
                        OR $P{sort_order2} = 'branchcode' 
                    ),
                    prc.branchname,
                    IF (
                        (
                            $P{sort_order2} = 'storagelocationname' 
                            OR $P{sort_order2} = 'storagelocationcode'
                        ),
                        prc.storagelocationname,
                        ''
                    )
                )
            )
        )
    ) AS sort_field2,

    prcdetail.stocktypecode AS stocktypecode
FROM view_mm_prc_header AS prc
LEFT JOIN view_mm_prc_material AS prcdetail ON prc.id = prcdetail.pricechangeid
LEFT JOIN materialmaterial AS mat ON prcdetail.materialid = mat.id
LEFT JOIN unitofmeasureunitofmeasure uom2 ON mat.order_unit2id = uom2.id
LEFT JOIN (SELECT prc.id, aj.txdate FROM pricechangepricechange AS prc LEFT JOIN adjuststockadjuststock AS aj ON prc.flow_refdocno = aj.txno) AS aj ON prc.id = aj.id
LEFT JOIN (SELECT prc.id, ap.txdate  FROM pricechangepricechange AS prc LEFT JOIN apap AS ap ON prc.flow_refdocno = ap.txno) AS ap ON prc.id = ap.id
LEFT JOIN (SELECT prc.id, ib.txdate FROM pricechangepricechange AS prc LEFT JOIN inbounddeliveryinbounddelivery AS ib ON prc.flow_refdocno = ib.txno) AS ib ON prc.id = ib.id
WHERE
    1 = 1
    $P!{ExternalWhereClause}
ORDER BY
    prc.txno,
    prcdetail.detailorderno
