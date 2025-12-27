SELECT
    *
FROM
(

    SELECT
        wip.txno,
        wip.txdate,
        wip.fg_issue_txdate,
        wip.rm_issue_txdate,
        wip.refdocno,
        'Raw Mat' AS material_category,

        IFNULL(wip.movementtypecode,'')   AS movcode,
        IFNULL(wip.movementtypename,'')   AS movname,
        wip.status                        AS status,
        IFNULL(wip.workinprocesslistname,'') AS workinprocesslistname,

        IFNULL(wip.storagelocation_fromcode,'') AS storagelocation_fromcode,
        IFNULL(wip.storagelocation_fromname,'') AS storagelocation_fromname,
        IFNULL(wip.storagelocation_tocode,'')   AS storagelocation_tocode,
        IFNULL(wip.storagelocation_toname,'')   AS storagelocation_toname,

        IFNULL(issue.detailorderno,0)           AS detailorderno,
        IFNULL(issue.actual_detailorderno,0)    AS actual_detailorderno,

        IFNULL(issue.materialtypecode,'')   AS materialtypecode,
        IFNULL(issue.materialtypename,'')   AS materialtypename,

        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.quantity, 0)) AS FG_actual_quantity,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity, 0)) AS DE_actual_quantity,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            issue.quantity, 0)) AS LO_actual_quantity,

        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.quantity2, 0)) AS FG_actual_quantity2,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity2, 0)) AS DE_actual_quantity2,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            issue.quantity2, 0)) AS LO_actual_quantity2,

        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.cost_amount, 0)) AS FG_actual_cost_amount,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.cost_amount, 0)) AS DE_actual_cost_amount,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            issue.cost_amount, 0)) AS LO_actual_cost_amount,

        CASE
            WHEN $P{sort_order1}='movcode'    THEN wip.movementtypecode
            WHEN $P{sort_order1}='status'     THEN wip.status
            WHEN $P{sort_order1}='txdate'     THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order1}='to_storagelocation'   THEN wip.storagelocation_toname
            WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN issue.materialtypename
            ELSE ''
        END AS sort_field1,

        CASE
            WHEN $P{sort_order2}='movcode'    THEN wip.movementtypecode
            WHEN $P{sort_order2}='status'     THEN wip.status
            WHEN $P{sort_order2}='txdate'     THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order2}='to_storagelocation'   THEN wip.storagelocation_toname
            WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN issue.materialtypename
            ELSE ''
        END AS sort_field2

    FROM
        view_mm_wip_header wip
        LEFT JOIN view_mm_wip_material_issue issue
            ON wip.id = issue.workinprocessid
    WHERE 1=1
        $P!{ExternalWhereClause}

    GROUP BY wip.txno


    UNION ALL


    SELECT
        wip.txno,
        wip.txdate,
        wip.fg_issue_txdate,
        wip.rm_issue_txdate,
        wip.refdocno,
        'FG' AS material_category,

        IFNULL(wip.movementtypecode,'')   AS movcode,
        IFNULL(wip.movementtypename,'')   AS movname,
        wip.status                        AS status,
        IFNULL(wip.workinprocesslistname,'') AS workinprocesslistname,

        IFNULL(wip.storagelocation_fromcode,'') AS storagelocation_fromcode,
        IFNULL(wip.storagelocation_fromname,'') AS storagelocation_fromname,
        IFNULL(wip.storagelocation_tocode,'')   AS storagelocation_tocode,
        IFNULL(wip.storagelocation_toname,'')   AS storagelocation_toname,

        IFNULL(receive.detailorderno,0)        AS detailorderno,
        IFNULL(receive.actual_detailorderno,0) AS actual_detailorderno,

        IFNULL(receive.materialtypecode,'')   AS materialtypecode,
        IFNULL(receive.materialtypename,'')   AS materialtypename,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.quantity, 0)) AS FG_actual_quantity,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity, 0)) AS DE_actual_quantity,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            receive.quantity, 0)) AS LO_actual_quantity,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.quantity2, 0)) AS FG_actual_quantity2,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity2, 0)) AS DE_actual_quantity2,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            receive.quantity2, 0)) AS LO_actual_quantity2,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.cost_amount, 0)) AS FG_actual_cost_amount,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.cost_amount, 0)) AS DE_actual_cost_amount,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
            AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'),
            receive.cost_amount, 0)) AS LO_actual_cost_amount,

        CASE
            WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
            WHEN $P{sort_order1}='status' THEN wip.status
            WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
            WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN receive.materialtypename
            ELSE ''
        END AS sort_field1,

        CASE
            WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
            WHEN $P{sort_order2}='status' THEN wip.status
            WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
            WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN receive.materialtypename
            ELSE ''
        END AS sort_field2

    FROM
        view_mm_wip_header wip
        LEFT JOIN view_mm_wip_material_receive receive
            ON wip.id = receive.workinprocessid

    WHERE 1=1
        $P!{ExternalWhereClause}

    GROUP BY wip.txno
) AS wip

ORDER BY
    $P!{sort_order1},
    $P!{sort_order2},
    txno,
    material_category DESC;
