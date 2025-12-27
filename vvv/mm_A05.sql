SELECT
    aj.txtype AS txtype,
    aj.txdate AS txdate,
    aj.txno   AS txno,

    IF(aj.flow_refdoctype LIKE '%tso%', tso.txdate,
       IF(aj.flow_refdoctype LIKE '%cst%', cst.txdate, '')
    ) AS flow_refdocdate,

    aj.branchcode               AS branch,

    ajdetail.materialgroupcode  AS materialgroupcode,
    ajdetail.materialgroupname  AS materialgroupname,
    ajdetail.materialtypecode   AS materialtypecode,
    ajdetail.materialtypename   AS materialtypename,

    IF(aj.storagelocationcode IS NULL, '', aj.storagelocationcode) AS storagelocationcode,
    IF(aj.storagelocationname IS NULL, '', aj.storagelocationname) AS storagelocationname,

    aj.flow_refdocno            AS flow_refdocno,
    aj.refdocdate               AS refdocdate,
    aj.refdocno                 AS refdocno,
    aj.status                   AS status,
    aj.remark                   AS remark,

    IFNULL(aj.document_categoryname, '') AS itemcat,
    IFNULL(aj.movementtypename, '')      AS movementtype,

    IF(aj.movementtypecode IS NULL, '', aj.movementtypecode) AS movcode,
    IF(aj.movementtypename IS NULL, '', aj.movementtypename) AS movname,

    IF(aj.branchcode IS NULL, '', aj.branchcode)   AS branchcode,
    IF(aj.branchname IS NULL, '', aj.branchname)   AS branchname,

    IF(ajdetail.materialcode IS NULL, '', ajdetail.materialcode)   AS materialcode,
    IF(ajdetail.materialname IS NULL, '', ajdetail.materialname)   AS materialname,
    IF(ajdetail.order_unitname IS NULL, '', ajdetail.order_unitname) AS uomname,

    IF(uom2.name IS NULL, '', uom2.name) AS uom2name,

    IF(aj.storagelocationcode IS NULL, '', aj.storagelocationcode) AS storagelocationcode2,
    IF(aj.storagelocationname IS NULL, '', aj.storagelocationname) AS storagelocationname2,

    ajdetail.quantity           AS quantity,
    ajdetail.quantity2          AS quantity2,
    ajdetail.standard_sale_price AS fix_amount,
    ajdetail.batchnumberCode    AS batchnumberCode,
    ajdetail.serialnumberCode   AS serialnumberCode,
    ajdetail.stockstatusCode    AS stockstatusCode,
    ajdetail.stockstatusName    AS stockstatusName,

    -- SORT_FIELD1
    IF($P{sort_order1} = 'movcode', aj.movementtypecode,
    IF($P{sort_order1} = 'status',  aj.status,
    IF($P{sort_order1} = 'txdate',  DATE_FORMAT(aj.txdate, '%Y-%m-%d'),
    IF($P{sort_order1} IN ('branchname','branchcode'),         aj.branchcode,
    IF($P{sort_order1} IN ('storagelocationname','storagelocationcode'), aj.storagelocationname,
    IF($P{sort_order1} IN ('materialtype','materialtypecode'), ajdetail.materialtypename,
       ''  -- default กรณีไม่เข้าเงื่อนไขใดเลย
    )))))) AS sort_field1,

    -- SORT_FIELD2
    IF($P{sort_order2} = 'movcode', aj.movementtypecode,
    IF($P{sort_order2} = 'status',  aj.status,
    IF($P{sort_order2} = 'txdate',  DATE_FORMAT(aj.txdate, '%Y-%m-%d'),
    IF($P{sort_order2} IN ('branchname','branchcode'),         aj.branchcode,
    IF($P{sort_order2} IN ('storagelocationname','storagelocationcode'), aj.storagelocationname,
    IF($P{sort_order2} IN ('materialtype','materialtypecode'), ajdetail.materialtypename,
       ''  -- default
    )))))) AS sort_field2,

    ajdetail.stocktypecode AS stocktypecode

FROM
    view_mm_aj_header   AS aj
    LEFT JOIN view_mm_aj_material AS ajdetail
           ON aj.id = ajdetail.adjuststockid
    LEFT JOIN unitofmeasureunitofmeasure uom2
           ON ajdetail.order_unit2id = uom2.id
    LEFT JOIN (
        SELECT aj.id, cst.txdate
        FROM adjuststockadjuststock AS aj
        LEFT JOIN countstockdatacountstockdata AS cst
               ON aj.flow_refdocno = cst.txno
    ) AS cst ON aj.id = cst.id
    LEFT JOIN (
        SELECT aj.id, tso.txdate
        FROM adjuststockadjuststock AS aj
        LEFT JOIN transferstocktransferstock AS tso
               ON aj.flow_refdocno = tso.txno
    ) AS tso ON aj.id = tso.id
WHERE
    1 = 1
    $P!{ExternalWhereClause}
ORDER BY
    $P!{sort_order1},
    $P!{sort_order2},
    aj.txno;
