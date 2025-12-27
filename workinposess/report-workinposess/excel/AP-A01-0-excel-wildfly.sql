SELECT  
  ap.txtype, 
  ap.txdate, 
  ap.txno,
   ap.flow_refdoctype, 
  IF(
    ap.flow_refdoctype = 'po', po.TXDATE,
    IF(
      ap.flow_refdoctype = 'ib', ib.TXDATE,
    IF(
      ap.flow_refdoctype = 'ib5', ib.TXDATE, ''
    ))) AS flow_refdocdate,
  ap.flow_refdocno,
  ap.duedate,
  ap.document_categoryCode,
  ap.deposit_after_vat,
  ap.prepaid_amount,
  apdetail.materialgroupcode ,
  apdetail.materialgroupname,
  apdetail.materialtypecode,
  apdetail.materialtypename,
  IF(
    ap.movementtypecode IS NULL, '', ap.movementtypecode
  ) AS movcode,
  IF(
    ap.movementtypename IS NULL, '', ap.movementtypename
  ) AS movname,
  ap.businesspartnercode,
  ap.businesspartnername,
  ap.refdocno,
  ap.refdocdate,
  ap.STATUS,
  ap.remark,
  IF(
    ap.branchcode IS NULL, '', ap.branchcode
  ) AS branchcode,
  IF(
    ap.branchname IS NULL, '', ap.branchname
  ) AS branchname,
  apdetail.materialcode,
  apdetail.materialname,
  IF(
    apdetail.name IS NULL, '', apdetail.name
  ) AS uom,
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
        apdetail.adjust_amount - ROUND(
          apdetail.adjust_amount * ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / 
          (100 + ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)), 5
        )
      )
    ),
    apdetail.netamount_before_vat - apdetail.adjust_amount
  ) AS netamount_before_vat,
  IF(
    ap.vat_type = 1,
    (
      apdetail.vat_amount - ROUND(
        apdetail.adjust_amount * ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / 
        (100 + ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)), 5
      )
    ),
    (
      apdetail.vat_amount - ROUND(
        apdetail.adjust_amount * (ROUND(apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5
      )
    )
  ) AS vat_amount,
  IF(
    ap.vat_type = 1,
    apdetail.netamount_after_vat - apdetail.adjust_amount,
    (
      apdetail.netamount_after_vat - ROUND(
        apdetail.adjust_amount * (1 + ROUND(apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5
      )
    )
  ) AS netamount,
  IF(
    $P{sort_order1} = 'txtype', ap.txtype,
    IF(
      $P{sort_order1} = 'status', ap.STATUS,
      IF(
        $P{sort_order1} = 'movcode', ap.movementtypecode,
        IF(
          $P{sort_order1} = 'txdate', DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P{sort_order1} = 'branchname' OR $P{sort_order1} = 'branchcode'), ap.branchname,
            IF(
              ($P{sort_order1} = 'vendorname' OR $P{sort_order1} = 'vendorcode'), ap.businesspartnername, ''
            )
          )
        )
      )
    )
  ) AS sort_field1,
  IF(
    $P{sort_order2} = 'txtype', ap.txtype,
    IF(
      $P{sort_order2} = 'status', ap.STATUS,
      IF(
        $P{sort_order2} = 'movcode', ap.movementtypecode,
        IF(
          $P{sort_order2} = 'txdate', DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P{sort_order2} = 'branchname' OR $P{sort_order2} = 'branchcode'), ap.branchname,
            IF(
              ($P{sort_order2} = 'vendorname' OR $P{sort_order2} = 'vendorcode'), ap.businesspartnername, ''
            )
          )
        )
      )
    )
  ) AS sort_field2
FROM view_ap_ap1_header AS ap
LEFT JOIN view_ap_ap_material AS apdetail ON ap.id = apdetail.apid

LEFT JOIN (
  SELECT ap.id, ib.txdate 
  FROM inbounddeliveryinbounddelivery AS ib 
  LEFT JOIN view_ap_ap1_header AS ap ON ap.flow_refdocno = ib.txno
) AS ib ON ap.id = ib.id AND flow_refdoctype IN ('ib', 'ib5')
LEFT JOIN (
  SELECT ap.id, po.txdate 
  FROM popo AS po 
  LEFT JOIN view_ap_ap1_header AS ap ON ap.flow_refdocno = po.txno
) AS po ON ap.id = po.id AND flow_refdoctype = 'po'
LEFT JOIN (
  SELECT 
    a.NAME AS costcenterview,
    c.map_key,
    b1.id AS branchid,
    b2.CODE AS branchcode,
    IFNULL(f.CODE, b2.CODE) AS branch_costhiearchy,
    IFNULL(f.NAME, b2.NAME) AS branch_costname
  FROM costcenterviewcostcenterview a
  LEFT JOIN costcenterhierarchycostcenterhierarchy b1 ON a.costcentergroup_rootid = b1.id
  LEFT JOIN costcenterkeycostcenterkey c ON b1.costcenterkeyid = c.id
  LEFT JOIN branchbranch b2 ON b2.usagestatus = 'release' AND b2.removestatus <> 'remove'
  LEFT JOIN costcenterhierarchyindexmap e ON e.map_key = 'branch' AND b2.id = e.map_value
  LEFT JOIN costcenterhierarchycostcenterhierarchy f ON e.costcenterhierarchyid = f.id
  WHERE a.usagestatus = 'release' AND a.removestatus <> 'remove' AND c.map_key = 'branch'
) branch_cost ON ap.branchid = branch_cost.branchid
LEFT JOIN (
  SELECT 
    a.NAME AS costcenterview,
    c.map_key,
    d.id AS departmentid,
    d.CODE AS departmentcode,
    IFNULL(f.CODE, b.CODE) AS depart_costhiearchy,
    IFNULL(f.NAME, b.NAME) AS depart_costname
  FROM costcenterviewcostcenterview a
  LEFT JOIN costcenterhierarchycostcenterhierarchy b ON a.costcentergroup_rootid = b.id
  LEFT JOIN costcenterkeycostcenterkey c ON b.costcenterkeyid = c.id
  LEFT JOIN departmentdepartment d ON d.usagestatus = 'release' AND d.removestatus <> 'remove'
  LEFT JOIN costcenterhierarchyindexmap e ON e.map_key = 'department' AND d.id = e.map_value
  LEFT JOIN costcenterhierarchycostcenterhierarchy f ON e.costcenterhierarchyid = f.id
  WHERE a.usagestatus = 'release' AND a.removestatus <> 'remove' AND c.map_key = 'department'
) depart_cost ON ap.departmentid = depart_cost.departmentid
WHERE ap.txtype = 'AP1' 
$P!{ExternalWhereClause}
ORDER BY $P!{sort_order1}, $P!{sort_order2}, ap.txno;
