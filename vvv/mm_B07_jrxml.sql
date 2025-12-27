SELECT *
FROM
(
    /* -----------------------------------------
       RAW MATERIAL (ISSUE)
    ----------------------------------------- */
    SELECT 
        wip.txno AS txno,
        wip.txdate AS txdate,
        wip.fg_issue_txdate AS fg_issue_txdate,
        wip.rm_issue_txdate AS rm_issue_txdate,
        wip.refdocno AS refdocno,
        'Raw Mat' AS material_category,

        wip.movementtypecode AS movcode,
        wip.movementtypename AS movname,
        wip.status AS status,
        wip.workinprocesslistname AS workinprocesslistname,

        wip.storagelocation_fromcode AS storagelocation_fromcode,
        wip.storagelocation_fromname AS storagelocation_fromname,
        wip.storagelocation_tocode AS storagelocation_tocode,
        wip.storagelocation_toname AS storagelocation_toname,

        issue.detailorderno AS detailorderno,
        issue.actual_detailorderno AS actual_detailorderno,

        issue.materialtypecode AS materialtypecode,
        issue.materialtypename AS materialtypename,

        /* FG / DE / LO QUANTITY */
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.quantity, 0)) AS FG_actual_quantity,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity, 0)) AS DE_actual_quantity,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity, 0)) AS LO_actual_quantity,

        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.quantity2, 0)) AS FG_actual_quantity2,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity2, 0)) AS DE_actual_quantity2,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), issue.quantity2, 0)) AS LO_actual_quantity2,

        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), issue.cost_amount, 0)) AS FG_actual_cost_amount,
        SUM(IF(issue.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), issue.cost_amount, 0)) AS DE_actual_cost_amount,
        SUM(IF(issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND issue.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), issue.cost_amount, 0)) AS LO_actual_cost_amount,

        /* Sort field 1 */
        CASE 
            WHEN $P{sort_order1}='movcode' THEN wip.movementtypecode
            WHEN $P{sort_order1}='status' THEN wip.status
            WHEN $P{sort_order1}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order1}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order1}='to_storagelocation' THEN wip.storagelocation_toname
            WHEN $P{sort_order1} IN ('materialtype','materialtypecode') THEN issue.materialtypename
            ELSE ''
        END AS sort_field1,

        /* Sort field 2 */
        CASE 
            WHEN $P{sort_order2}='movcode' THEN wip.movementtypecode
            WHEN $P{sort_order2}='status' THEN wip.status
            WHEN $P{sort_order2}='txdate' THEN DATE_FORMAT(wip.txdate,'%Y-%m-%d')
            WHEN $P{sort_order2}='from_storagelocation' THEN wip.storagelocation_fromname
            WHEN $P{sort_order2}='to_storagelocation' THEN wip.storagelocation_toname
            WHEN $P{sort_order2} IN ('materialtype','materialtypecode') THEN issue.materialtypename
            ELSE ''
        END AS sort_field2

    FROM view_mm_wip_header wip
    LEFT JOIN view_mm_wip_material_issue issue 
        ON wip.id = issue.workinprocessid

    WHERE 1=1
        $P!{ExternalWhereClause}

    GROUP BY wip.txno


    UNION ALL


    /* -----------------------------------------
       FG (RECEIVE)
    ----------------------------------------- */
    SELECT 
        wip.txno AS txno,
        wip.txdate AS txdate,
        wip.fg_issue_txdate AS fg_issue_txdate,
        wip.rm_issue_txdate AS rm_issue_txdate,
        wip.refdocno AS refdocno,
        'FG' AS material_category,

        wip.movementtypecode AS movcode,
        wip.movementtypename AS movname,
        wip.status AS status,
        wip.workinprocesslistname AS workinprocesslistname,

        wip.storagelocation_fromcode AS storagelocation_fromcode,
        wip.storagelocation_fromname AS storagelocation_fromname,
        wip.storagelocation_tocode AS storagelocation_tocode,
        wip.storagelocation_toname AS storagelocation_toname,

        receive.detailorderno AS detailorderno,
        receive.actual_detailorderno AS actual_detailorderno,
        receive.materialtypecode AS materialtypecode,
        receive.materialtypename AS materialtypename,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.quantity, 0)) AS FG_actual_quantity,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity, 0)) AS DE_actual_quantity,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity, 0)) AS LO_actual_quantity,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.quantity2, 0)) AS FG_actual_quantity2,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity2, 0)) AS DE_actual_quantity2,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), receive.quantity2, 0)) AS LO_actual_quantity2,

        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus}, '%'), receive.cost_amount, 0)) AS FG_actual_cost_amount,
        SUM(IF(receive.storagelocationcode LIKE CONCAT($P{storagestatus2}, '%'), receive.cost_amount, 0)) AS DE_actual_cost_amount,
        SUM(IF(receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus}, '%')
           AND receive.storagelocationcode NOT LIKE CONCAT($P{storagestatus2}, '%'), receive.cost_amount, 0)) AS LO_actual_cost_amount,

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

    FROM view_mm_wip_header wip
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
