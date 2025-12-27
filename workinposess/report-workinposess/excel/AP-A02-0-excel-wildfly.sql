SELECT
  ap.txtype,
  ap.txdate,
  ap.txno,
  IF(
    ap.FLOW_REFDOCTYPE = 'po',
    po.TXDATE,
    IF(ap.FLOW_REFDOCTYPE = 'ib', ib.TXDATE, IF(ap.FLOW_REFDOCTYPE = 'ib5', ib.TXDATE, ''))
  ) AS flow_refdocdate,
  ap.flow_refdocno,
  ap.duedate,
  ap.document_categoryCode,
  ap.deposit_after_vat,
  ap.prepaid_amount,
  IF(ap.movementtypecode IS NULL, '', ap.movementtypecode) AS movcode,
  IF(ap.movementtypename IS NULL, '', ap.movementtypename) AS movname,
  apdetail.materialgroupcode AS materialgroupcode,
  apdetail.materialgroupname AS materialgroupname,
  apdetail.materialtypecode AS materialtypecode,
  apdetail.materialtypename AS materialtypename,
  IF(ap.businesspartnercode IS NULL, '', ap.businesspartnercode) AS vendorcode,
  IF(ap.businesspartnername IS NULL, '', ap.businesspartnername) AS vendorname,
  ap.refdocno,
  ap.refdocdate,
  ap.STATUS,
  ap.remark,
  IF(ap.branchcode IS NULL, '', ap.branchcode) AS branchcode,
  IF(ap.branchname IS NULL, '', ap.branchname) AS branchname,
  IF(apdetail.materialcode IS NULL, '', apdetail.materialcode) AS materialcode,
  IF(apdetail.materialname IS NULL, '', apdetail.materialname) AS materialname,
  IF(apdetail.NAME IS NULL, '', apdetail.NAME) AS uom,
  IF(ap.departmentcode IS NULL, '', ap.departmentcode) AS depcode,
  IF(ap.departmentnameIS NULL, '', ap.departmentname) AS depname,
  branch_cost.branch_costhiearchy,
  branch_cost.branch_costname,
  depart_cost.depart_costhiearchy,
  depart_cost.depart_costname,
  apdetail.QUANTITY,
  apdetail.price_per_unit AS price,
  apdetail.amount AS amount,
  apdetail.discount_amount AS discount_amount,
  apdetail.netamount_after_vat,
  IF(
    ap.vat_type = 1,
    (
      apdetail.netamount_before_vat - (
        apdetail.adjust_amount - round(
          apdetail.adjust_amount * round(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / (100+round (apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)),
          5
        )
      )
    ),
    apdetail.netamount_before_vat - apdetail.adjust_amount
  ) AS netamount_before_vat,
  IF(
    ap.vat_type = 1,
    (
      apdetail.vat_amount - round(
        apdetail.adjust_amount * round(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / (100+round (apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)),
        5
      )
    ),
    (
      apdetail.vat_amount - round(apdetail.adjust_amount * (round(apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5)
    )
  ) AS vat_amount,
  IF(
    ap.vat_type = 1,
    apdetail.netamount_after_vat - apdetail.adjust_amount,
    (
      apdetail.netamount_after_vat - round(apdetail.adjust_amount * (1+round (apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5)
    )
  ) AS netamount,
  IF(
    $P{sort_order1}= 'txtype',
    ap.txtype,
    IF(
      $P{sort_order1}= 'status',
      ap.STATUS,
      IF(
        $P{sort_order1}= 'movcode',
        ap.movementtypecode,
        IF(
          $P{sort_order1}= 'depcode',
          ap.departmentcode,
          IF(
            $P{sort_order1}= 'txdate',
            DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
            IF(
              ($P{sort_order1}= 'branchname' OR $P{sort_order1}= 'branchcode'),
              ap.branchname,
              IF(($P{sort_order1}= 'vendorname' OR $P{sort_order1}= 'vendorcode'), ap.businesspartnername, '')
            )
          )
        )
      )
    )
  ) AS sort_field1,
  IF(
    $P{sort_order2}= 'txtype',
    ap.txtype,
    IF(
      $P{sort_order2}= 'status',
      ap.STATUS,
      IF(
        $P{sort_order2}= 'movcode',
        ap.movementtypecode,
        IF(
          $P{sort_order2}= 'depcode',
          ap.departmentcode,
          IF(
            $P{sort_order2}= 'txdate',
            DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
            IF(
              ($P{sort_order2}= 'branchname' OR $P{sort_order2}= 'branchcode'),
              ap.branchname,
              IF(($P{sort_order2}= 'vendorname' OR $P{sort_order2}= 'vendorcode'), ap.businesspartnername, '')
            )
          )
        )
      )
    )
  ) AS sort_field2
FROM
  view_ap_ap2_header AS ap
  LEFT JOIN view_ap_ap_material AS apdetail ON ap.id = apdetail.apid
  
  LEFT JOIN (SELECT ap.id, ib.txdate FROM inbounddeliveryinbounddelivery AS ib LEFT JOIN view_ap_ap2_header AS ap ON ap.flow_refdocno = ib.txno) AS ib ON ap.id = ib.id
  AND ap.FLOW_REFDOCTYPE IN ('ib', 'ib5')
  LEFT JOIN (SELECT ap.id, po.txdate FROM popo AS po LEFT JOIN view_ap_ap2_header AS ap ON ap.flow_refdocno = po.txno) AS po ON ap.id = po.id
  AND ap.FLOW_REFDOCTYPE = 'po'
  LEFT JOIN (
    SELECT
      a.NAME AS costcenterview,
      c.map_key,
      d.id AS branchid,
      d.CODE AS branchcode,
      ifnull(f.CODE, b.CODE) AS branch_costhiearchy,
      ifnull(f.NAME, b.NAME) AS branch_costname
    FROM
      costcenterviewcostcenterview a
      LEFT JOIN costcenterhierarchycostcenterhierarchy b ON a.costcentergroup_rootid = b.id
      LEFT JOIN costcenterkeycostcenterkey c ON b.costcenterkeyid = c.id
      LEFT JOIN branchbranch d ON d.usagestatus = 'release'
      AND d.removestatus <> 'remove'
      LEFT JOIN costcenterhierarchyindexmap e ON e.map_key = 'branch'
      AND d.id = e.map_value
      LEFT JOIN costcenterhierarchycostcenterhierarchy f ON e.costcenterhierarchyid = f.id
    WHERE
      a.usagestatus = 'release'
      AND a.removestatus <> 'remove'
      AND c.map_key = 'branch'
    ORDER BY
      d.CODE
  ) branch_cost ON ap.BRANCHID = branch_cost.branchid
  LEFT JOIN (
    SELECT
      a.NAME AS costcenterview,
      c.map_key,
      d.id AS departmentid,
      d.CODE AS departmentcode,
      ifnull(f.CODE, b.CODE) AS depart_costhiearchy,
      ifnull(f.NAME, b.NAME) AS depart_costname
    FROM
      costcenterviewcostcenterview a
      LEFT JOIN costcenterhierarchycostcenterhierarchy b ON a.costcentergroup_rootid = b.id
      LEFT JOIN costcenterkeycostcenterkey c ON b.costcenterkeyid = c.id
      LEFT JOIN departmentdepartment d ON d.usagestatus = 'release'
      AND d.removestatus <> 'remove'
      LEFT JOIN costcenterhierarchyindexmap e ON e.map_key = 'department'
      AND d.id = e.map_value
      LEFT JOIN costcenterhierarchycostcenterhierarchy f ON e.costcenterhierarchyid = f.id
    WHERE
      a.usagestatus = 'release'
      AND a.removestatus <> 'remove'
      AND c.map_key = 'department'
    ORDER BY
      d.CODE
  ) depart_cost ON ap.DEPARTMENTID = depart_cost.departmentid
WHERE
  ap.txtype = 'AP2' $P!{ExternalWhereClause}
ORDER BY
  $P!{sort_order1},
  $P!{sort_order2},
  ap.txno