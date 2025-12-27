SELECT *
FROM (

	SELECT
		'RM' AS type,
		wip.txno AS txno,
		wip.txdate AS txdate,
		wip.plan_txdate AS plan_txdate,
		wip.refdocno AS refdocno,
		wip.storagelocation_fromcode AS storagelocation_fromcode,
		wip.storagelocation_tocode AS storagelocation_tocode,

		issue.materialtypecode AS plan_materialtypecode,
		issue.materialtypename AS plan_materialtypename,

		issue.materialcode AS plan_materialcode,
		issue.materialname AS plan_materialname,

		issue.quantity AS plan_qty,
		issue.actual_quantity AS actual_qty,

		IF(issue.actual_cost_amount > 0 AND issue.actual_quantity > 0,
			issue.actual_cost_amount / issue.actual_quantity, 0) AS actual_cost_per_unit,
		issue.actual_cost_amount,

		'' AS fg_percent,
		0 AS fg_count,

		wip.external_refdocno AS std_time,
		'' AS fg_txdate,
		0 AS over_due,

		IF($P{sort_order1}='movcode', wip.movementtypecode,
		IF($P{sort_order1}='status', wip.status,
		IF($P{sort_order1}='txdate', DATE_FORMAT(wip.txdate,'%Y-%m-%d'),
		IF($P{sort_order1}='from_storagelocation', wip.storagelocation_fromname,
		IF($P{sort_order1}='to_storagelocation', wip.storagelocation_toname,
		IF($P{sort_order1} IN ('materialtype','materialtypecode'), issue.materialtypename, '')
		)))) ) AS sort_field1,


		IF($P{sort_order2}='movcode', wip.movementtypecode,
		IF($P{sort_order2}='status', wip.status,
		IF($P{sort_order2}='txdate', DATE_FORMAT(wip.txdate,'%Y-%m-%d'),
		IF($P{sort_order2}='from_storagelocation', wip.storagelocation_fromname,
		IF($P{sort_order2}='to_storagelocation', wip.storagelocation_toname,
		IF($P{sort_order2} IN ('materialtype','materialtypecode'), issue.materialtypename, '')
		)))) ) AS sort_field2

	FROM view_mm_wip_header wip
	LEFT JOIN view_mm_wip_material_issue issue
		ON wip.id = issue.workinprocessid
	WHERE 1=1
	$P!{ExternalWhereClause}

	UNION ALL

	SELECT
		'FG' AS type,
		wip.txno AS txno,
		wip.txdate AS txdate,
		'' AS plan_txdate,
		wip.refdocno AS refdocno,

		receive.storagelocationcode AS fg_storagelocationcode,
		'' AS storagelocation_tocode,

		'' AS plan_materialtypecode,
		'' AS plan_materialtypename,

		receive.materialcode AS fg_materialcode,
		receive.materialname AS fg_materialname,

		receive.quantity AS fg_plan_qty,
		receive.actual_quantity AS fg_actual_qty,

		0 AS actual_cost_per_unit,
		receive.actual_cost_amount AS fg_cost,

		IF(receive.quantity > 0,
			ROUND((receive.actual_quantity / receive.quantity) * 100, 2),
		0.00) AS fg_percent,

		CONCAT(ROUND(receive.actual_detailorderno / 100,0),'/', c.count_gr35) AS fg_count,

		wip.external_refdocno AS std_time,

		gr.txdate AS fg_txdate,


		IF(
			DATEDIFF(gr.txdate, ADDDATE(wip.plan_txdate, CAST(wip.external_refdocno AS UNSIGNED))) < 0,
			0,
			DATEDIFF(gr.txdate, ADDDATE(wip.plan_txdate, CAST(wip.external_refdocno AS UNSIGNED)))
		) AS over_due,

		IF($P{sort_order1}='movcode', wip.movementtypecode,
		IF($P{sort_order1}='status', wip.status,
		IF($P{sort_order1}='txdate', DATE_FORMAT(wip.txdate,'%Y-%m-%d'),
		IF($P{sort_order1}='from_storagelocation', wip.storagelocation_fromname,
		IF($P{sort_order1}='to_storagelocation', wip.storagelocation_toname,
		IF($P{sort_order1} IN ('materialtype','materialtypecode'), receive.materialtypename, '')
		)))) ) AS sort_field1,


		IF($P{sort_order2}='movcode', wip.movementtypecode,
		IF($P{sort_order2}='status', wip.status,
		IF($P{sort_order2}='txdate', DATE_FORMAT(wip.txdate,'%Y-%m-%d'),
		IF($P{sort_order2}='from_storagelocation', wip.storagelocation_fromname,
		IF($P{sort_order2}='to_storagelocation', wip.storagelocation_toname,
		IF($P{sort_order2} IN ('materialtype','materialtypecode'), receive.materialtypename, '')
		)))) ) AS sort_field2

	FROM view_mm_wip_header wip
	LEFT JOIN view_mm_wip_material_receive receive
		ON wip.id = receive.workinprocessid

	LEFT JOIN grgr gr
		ON gr.txno = receive.flow_refdocno

	LEFT JOIN (
		SELECT a.id, COUNT(*) AS count_gr35
		FROM workinprocessworkinprocess a
		INNER JOIN grgr b ON a.txno = b.flow_refdocno
		WHERE b.movementtypecode = 'GR-35'
		GROUP BY a.id
	) c ON c.id = wip.id

	WHERE 1=1
	$P!{ExternalWhereClause}

) AS b

ORDER BY
	b.sort_field1,
	b.sort_field2,
	b.txno ASC,
	b.type DESC,
	b.fg_count;
