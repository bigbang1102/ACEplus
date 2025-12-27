SELECT
    wip_all.txno,
    wip_all.txdate,
    wip_all.refdocno,
    wip_all.material_category,
    wip_all.movcode,
    wip_all.movname,
    wip_all.status,
    wip_all.workinprocesslistname,
    wip_all.storagelocation_fromcode,
    wip_all.storagelocation_fromname,
    wip_all.storagelocation_tocode,
    wip_all.storagelocation_toname,
    wip_all.remark,
    wip_all.detailorderno,
    wip_all.actual_detailorderno,
    wip_all.materialtypecode,
    wip_all.materialtypename,
    wip_all.materialcode,
    wip_all.materialname,
    wip_all.quantity,
    wip_all.order_unitcode,
    wip_all.order_unitname,
    wip_all.cost_per_unit,
    wip_all.cost_amount,
    wip_all.quantity2,
    wip_all.order_unit2code,
    wip_all.order_unit2name,
    wip_all.actual_quantity,
    wip_all.actual_order_unitcode,
    wip_all.actual_order_unitname,
    wip_all.actual_cost_per_unit,
    wip_all.actual_cost_amount,
    wip_all.actual_quantity2,
    wip_all.actual_order_unit2code,
    wip_all.actual_order_unit2name,
    wip_all.storagelocationcode,
    wip_all.storagelocationname,
    wip_all.sort_field1,
    wip_all.sort_field2
FROM
(

    SELECT
        wip.txno AS txno,
        wip.txdate AS txdate,
        wip.refdocno AS refdocno,
        'Raw Mat' AS material_category,
        IFNULL(wip.movementtypecode,'')      AS movcode,
        IFNULL(wip.movementtypename,'')      AS movname,
        wip.status AS status,
        IFNULL(wip.workinprocesslistname,'') AS workinprocesslistname,
        IFNULL(wip.storagelocation_fromcode,'') AS storagelocation_fromcode,
        IFNULL(wip.storagelocation_fromname,'') AS storagelocation_fromname,
        IFNULL(wip.storagelocation_tocode,'')   AS storagelocation_tocode,
        IFNULL(wip.storagelocation_toname,'')   AS storagelocation_toname,
        wip.remark AS remark,

        IFNULL(issue.detailorderno,0)           AS detailorderno,
        IFNULL(issue.actual_detailorderno,0)    AS actual_detailorderno,
        IFNULL(issue.materialtypecode,'')       AS materialtypecode,
        IFNULL(issue.materialtypename,'')       AS materialtypename,
        IFNULL(issue.materialcode,'')           AS materialcode,
        IFNULL(issue.materialname,'')           AS materialname,
        IFNULL(issue.quantity,0)                AS quantity,
        IFNULL(issue.order_unitcode,'')         AS order_unitcode,
        IFNULL(issue.order_unitname,'')         AS order_unitname,
        IFNULL(IF(issue.quantity > 0,
                  issue.cost_amount / issue.quantity, 0),0) AS cost_per_unit,
        issue.cost_amount                     AS cost_amount,
        IFNULL(issue.quantity2,0)             AS quantity2,
        IFNULL(issue.order_unit2code,'')      AS order_unit2code,
        IFNULL(issue.order_unit2name,'')      AS order_unit2name,

        IFNULL(issue.actual_quantity,0)       AS actual_quantity,
        IFNULL(issue.actual_order_unitcode,'') AS actual_order_unitcode,
        IFNULL(issue.actual_order_unitname,'') AS actual_order_unitname,
        IFNULL(IF(issue.actual_quantity > 0,
                  issue.actual_cost_amount / issue.actual_quantity, 0),0) AS actual_cost_per_unit,
        issue.actual_cost_amount             AS actual_cost_amount,
        IFNULL(issue.actual_quantity2,0)     AS actual_quantity2,
        IFNULL(issue.actual_order_unit2code,'') AS actual_order_unit2code,
        IFNULL(issue.actual_order_unit2name,'') AS actual_order_unit2name,

        IFNULL(issue.storagelocationcode,'') AS storagelocationcode,
        IFNULL(issue.storagelocationname,'') AS storagelocationname,

        /* sort_field1 */
        CASE 
            WHEN $P{sort_order1} = 'movcode'
                THEN wip.movementtypecode
            WHEN $P{sort_order1} = 'status'
                THEN wip.status
            WHEN $P{sort_order1} = 'txdate'
                THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order1} = 'from_storagelocation'
                THEN wip.storagelocation_fromname
            WHEN $P{sort_order1} = 'to_storagelocation'
                THEN wip.storagelocation_toname
            WHEN $P{sort_order1} IN ('materialtype','materialtypecode')
                THEN issue.materialtypename
            ELSE ''
        END AS sort_field1,

        /* sort_field2 */
        CASE 
            WHEN $P{sort_order2} = 'movcode'
                THEN wip.movementtypecode
            WHEN $P{sort_order2} = 'status'
                THEN wip.status
            WHEN $P{sort_order2} = 'txdate'
                THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order2} = 'from_storagelocation'
                THEN wip.storagelocation_fromname
            WHEN $P{sort_order2} = 'to_storagelocation'
                THEN wip.storagelocation_toname
            WHEN $P{sort_order2} IN ('materialtype','materialtypecode')
                THEN issue.materialtypename
            ELSE ''
        END AS sort_field2

    FROM view_mm_wip_header wip
    LEFT JOIN view_mm_wip_material_issue issue
           ON wip.id = issue.workinprocessid
    WHERE 1 = 1
      $P!{ExternalWhereClause}

    UNION


    SELECT
        wip.txno AS txno,
        wip.txdate AS txdate,
        wip.refdocno AS refdocno,
        'FG' AS material_category,
        IFNULL(wip.movementtypecode,'')      AS movcode,
        IFNULL(wip.movementtypename,'')      AS movname,
        wip.status AS status,
        IFNULL(wip.workinprocesslistname,'') AS workinprocesslistname,
        IFNULL(wip.storagelocation_fromcode,'') AS storagelocation_fromcode,
        IFNULL(wip.storagelocation_fromname,'') AS storagelocation_fromname,
        IFNULL(wip.storagelocation_tocode,'')   AS storagelocation_tocode,
        IFNULL(wip.storagelocation_toname,'')   AS storagelocation_toname,
        wip.remark AS remark,

        IFNULL(receive.detailorderno,0)        AS detailorderno,
        IFNULL(receive.actual_detailorderno,0) AS actual_detailorderno,
        IFNULL(receive.materialtypecode,'')    AS materialtypecode,
        IFNULL(receive.materialtypename,'')    AS materialtypename,
        IFNULL(receive.materialcode,'')        AS materialcode,
        IFNULL(receive.materialname,'')        AS materialname,
        IFNULL(receive.quantity,0)             AS quantity,
        IFNULL(receive.order_unitcode,'')      AS order_unitcode,
        IFNULL(receive.order_unitname,'')      AS order_unitname,
        IFNULL(IF(receive.quantity > 0,
                  receive.cost_amount / receive.quantity, 0),0) AS cost_per_unit,
        receive.cost_amount                  AS cost_amount,
        IFNULL(receive.quantity2,0)          AS quantity2,
        IFNULL(receive.order_unit2code,'')   AS order_unit2code,
        IFNULL(receive.order_unit2name,'')   AS order_unit2name,

        IFNULL(receive.actual_quantity,0)    AS actual_quantity,
        IFNULL(receive.actual_order_unitcode,'') AS actual_order_unitcode,
        IFNULL(receive.actual_order_unitname,'') AS actual_order_unitname,
        IFNULL(IF(receive.actual_quantity > 0,
                  receive.actual_cost_amount / receive.actual_quantity, 0),0) AS actual_cost_per_unit,
        receive.actual_cost_amount          AS actual_cost_amount,
        IFNULL(receive.actual_quantity2,0)  AS actual_quantity2,
        IFNULL(receive.actual_order_unit2code,'') AS actual_order_unit2code,
        IFNULL(receive.actual_order_unit2name,'') AS actual_order_unit2name,

        IFNULL(receive.storagelocationcode,'') AS storagelocationcode,
        IFNULL(receive.storagelocationname,'') AS storagelocationname,

        /* sort_field1 */
        CASE 
            WHEN $P{sort_order1} = 'movcode'
                THEN wip.movementtypecode
            WHEN $P{sort_order1} = 'status'
                THEN wip.status
            WHEN $P{sort_order1} = 'txdate'
                THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order1} = 'from_storagelocation'
                THEN wip.storagelocation_fromname
            WHEN $P{sort_order1} = 'to_storagelocation'
                THEN wip.storagelocation_toname
            WHEN $P{sort_order1} IN ('materialtype','materialtypecode')
                THEN receive.materialtypename
            ELSE ''
        END AS sort_field1,

        /* sort_field2 */
        CASE 
            WHEN $P{sort_order2} = 'movcode'
                THEN wip.movementtypecode
            WHEN $P{sort_order2} = 'status'
                THEN wip.status
            WHEN $P{sort_order2} = 'txdate'
                THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order2} = 'from_storagelocation'
                THEN wip.storagelocation_fromname
            WHEN $P{sort_order2} = 'to_storagelocation'
                THEN wip.storagelocation_toname
            WHEN $P{sort_order2} IN ('materialtype','materialtypecode')
                THEN receive.materialtypename
            ELSE ''
        END AS sort_field2

    FROM view_mm_wip_header wip
    LEFT JOIN view_mm_wip_material_receive receive
           ON wip.id = receive.workinprocessid
    WHERE 1 = 1
      $P!{ExternalWhereClause}
) wip_all
ORDER BY
    $P!{sort_order1},
    $P!{sort_order2},
    txno,
    material_category DESC,
    detailorderno,
    actual_detailorderno;
