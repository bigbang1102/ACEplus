SELECT * 
FROM (

SELECT 
    'WIP' AS type,
    wip.txno,
    wip.txdate,
    wip.refdocno,
    map.display AS status,

    IFNULL(wip.storagelocation_fromcode,'') AS storagelocation_fromcode,
    IFNULL(wip.storagelocation_tocode,'')   AS storagelocation_tocode,

    wip.remark,
    0 AS actual_rm,
    receive.overhead_amount AS expend_insource,
    0 AS expend_outsource,
    0 AS st_cost_fg,

    wip.txno AS wip_txno,

    CASE 
        WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order1}='status' THEN wip.status
        WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field1,

    CASE 
        WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order2}='status' THEN wip.status
        WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field2

FROM 
    view_mm_wip_header wip
    LEFT JOIN view_mm_wip_material_receive receive ON wip.id = receive.workinprocessid
    INNER JOIN wfdisplaymap map 
        ON wip.status = map.value 
        AND map.doctype='Workinprocess'
        AND map.displaygroup='status'
WHERE 1=1
    $P!{ExternalWhereClause}


UNION ALL
SELECT
    'GI33' AS type,
    gi.txno,
    gi.txdate,
    gi.refdocno,
    map.display AS status,

    IFNULL(gi.storagelocationcode,'') AS storagelocation_fromcode,
    '' AS storagelocation_tocode,

    gi.remark,
    gi.cost_amount AS actual_rm,
    0 AS expend_insource,
    0 AS expend_outsource,
    0 AS st_cost_fg,
    wip.txno AS wip_txno,

    CASE 
        WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order1}='status' THEN wip.status
        WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field1,

    CASE 
        WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order2}='status' THEN wip.status
        WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field2

FROM 
    view_mm_wip_header wip
    LEFT JOIN gigi gi ON gi.flow_refdocno = wip.txno
    LEFT JOIN view_mm_wip_material_receive receive ON wip.id = receive.workinprocessid
    INNER JOIN wfdisplaymap map 
        ON gi.status = map.value 
        AND map.doctype='Gi'
        AND map.displaygroup='status'
WHERE gi.movementtypecode='GI-33'
    AND gi.status <> 'cancel'
    $P!{ExternalWhereClause}


UNION ALL
SELECT
    'IB' AS type,
    ib.txno,
    ib.txdate,
    ib.refdocno,
    map.display AS status,

    IFNULL(ib.storagelocationcode,'') AS storagelocation_fromcode,
    '' AS storagelocation_tocode,

    ib.remark,
    ib.netamount_before_vat AS actual_rm,
    0 AS expend_insource,
    0 AS expend_outsource,
    0 AS st_cost_fg,
    wip.txno AS wip_txno,

    CASE 
        WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order1}='status' THEN wip.status
        WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field1,

    CASE 
        WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order2}='status' THEN wip.status
        WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field2

FROM 
    view_mm_wip_header wip
    LEFT JOIN inbounddeliveryinbounddelivery ib ON ib.flow_refdocno = wip.txno
    LEFT JOIN view_mm_wip_material_receive receive ON wip.id = receive.workinprocessid
    INNER JOIN wfdisplaymap map 
        ON ib.status = map.value 
        AND map.doctype='Inbounddelivery'
        AND map.displaygroup='status'
WHERE ib.txno IS NOT NULL
    AND ib.status <> 'cancel'
    $P!{ExternalWhereClause}


UNION ALL
SELECT
    'AP7' AS type,
    ap.txno,
    ap.txdate,
    ap.refdocno,
    map.display AS status,

    '' AS storagelocation_fromcode,
    '' AS storagelocation_tocode,

    ap.remark,
    0 AS actual_rm,
    0 AS expend_insource,
    ap.netamount_after_vat AS expend_outsource,
    0 AS st_cost_fg,
    wip.txno AS wip_txno,

    CASE 
        WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order1}='status' THEN wip.status
        WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field1,

    CASE 
        WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order2}='status' THEN wip.status
        WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field2

FROM 
    view_mm_wip_header wip
    LEFT JOIN apap ap ON ap.flow_refdocno = wip.txno
    LEFT JOIN view_mm_wip_material_receive receive ON wip.id = receive.workinprocessid
    INNER JOIN wfdisplaymap map 
        ON ap.status = map.value 
        AND map.doctype='Ap'
        AND map.displaygroup='status'
WHERE ap.txno IS NOT NULL
    AND ap.status <> 'cancel'
    $P!{ExternalWhereClause}


UNION ALL
SELECT
    'GR35' AS type,
    gr.txno,
    gr.txdate,
    gr.refdocno,
    map.display AS status,

    IFNULL(gr.storagelocationcode,'') AS storagelocation_fromcode,
    '' AS storagelocation_tocode,

    gr.remark,
    0 AS actual_rm,
    0 AS expend_insource,
    0 AS expend_outsource,
    gr.netamount_after_vat AS st_cost_fg,
    wip.txno AS wip_txno,

    /* sort fields */
    CASE 
        WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order1}='status' THEN wip.status
        WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field1,

    CASE 
        WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
        WHEN $P{sort_order2}='status' THEN wip.status
        WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
        WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
        WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
        WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
        ELSE '' END AS sort_field2

FROM
    view_mm_wip_header wip
    LEFT JOIN grgr gr ON gr.flow_refdocno = wip.txno
    LEFT JOIN view_mm_wip_material_receive receive ON wip.id = receive.workinprocessid
    INNER JOIN wfdisplaymap map 
        ON gr.status = map.value 
        AND map.doctype='Gr'
        AND map.displaygroup='status'
WHERE gr.movementtypecode='GR-35'
    AND gr.status <> 'cancel'
    $P!{ExternalWhereClause}

) AS a
ORDER BY a.wip_txno;
