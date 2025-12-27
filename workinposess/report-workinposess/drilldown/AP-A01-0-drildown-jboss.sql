SELECT
  ap.txtype,
  ap.txdate,
IF
  ( apdetail.detailorderno = 100, ap.txno, '' ) AS txno,
IF
  (
    ap.FLOW_REFDOCTYPE = 'po',
    po.TXDATE,
  IF
    (
      ap.FLOW_REFDOCTYPE = 'ib',
      ib.TXDATE,
    IF
    ( ap.FLOW_REFDOCTYPE = 'ib5', ib.TXDATE, '' ))) AS flow_refdocdate,
  ap.flow_refdocno,
  ap.duedate,
  ap.document_categoryCode,
  ap.deposit_after_vat,
  ap.prepaid_amount,
  matgroup.CODE AS materialgroupcode,
  matgroup.NAME AS materialgroupname,
  matgroup.materialtypecode AS materialtypecode,
  matgroup.materialtypename AS materialtypename,
IF
  ( ap.movementtypecode IS NULL, '', ap.movementtypecode ) AS movcode,
IF
  ( ap.movementtypename IS NULL, '', ap.movementtypename ) AS movname,
IF
  ( vendor.CODE IS NULL, '', vendor.CODE ) AS vendorcode,
IF
  ( vendor.NAME IS NULL, '', vendor.NAME ) AS vendorname,
  ap.refdocno,
  ap.refdocdate,
  ap.STATUS,
  ap.remark,
IF
  ( branch.CODE IS NULL, '', branch.CODE ) AS branchcode,
IF
  ( branch.NAME IS NULL, '', branch.NAME ) AS branchname,
IF
  ( mat.CODE IS NULL, '', mat.CODE ) AS materialcode,
IF
  ( mat.NAME IS NULL, '', mat.NAME ) AS materialname,
IF
  ( uom.NAME IS NULL, '', uom.NAME ) AS uom,
  branch_cost.branch_costhiearchy,
  branch_cost.branch_costname,
  depart_cost.depart_costhiearchy,
  depart_cost.depart_costname,
  apdetail.QUANTITY,
  apdetail.price_per_unit AS price,
  apdetail.amount AS amount,
  apdetail.discount_amount AS discount_amount,
  ap.netamount_after_vat,
IF
  (
    ap.vat_type = 1,(
      apdetail.netamount_before_vat -(
        apdetail.adjust_amount - round(
          apdetail.adjust_amount * round( apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2 )/(
          100+round ( apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2 )),
          5 
        ))),
    apdetail.netamount_before_vat - apdetail.adjust_amount 
  ) AS netamount_before_vat,
IF
  (
    ap.vat_type = 1,(
      apdetail.vat_amount - round(
        apdetail.adjust_amount * round( apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2 )/(
        100+round ( apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2 )),
        5 
      )),(
    apdetail.vat_amount - round( apdetail.adjust_amount *( round( apdetail.vat_amount / apdetail.netamount_after_vat, 2 )), 5 ))) AS vat_amount,
IF
  (
    ap.vat_type = 1,
    apdetail.netamount_after_vat - apdetail.adjust_amount,(
    apdetail.netamount_after_vat - round( apdetail.adjust_amount *( 1+round ( apdetail.vat_amount / apdetail.netamount_after_vat, 2 )), 5 ))) AS netamount,
IF
  (
    $P { sort_order1 }= 'txtype',
    ap.txtype,
  IF
    (
      $P { sort_order1 }= 'status',
      ap.STATUS,
    IF
      (
        $P { sort_order1 }= 'movcode',
        ap.movementtypecode,
      IF
        (
          $P { sort_order1 }= 'txdate',
          DATE_FORMAT( ap.txdate, '%Y-%m-%d' ),
        IF
          ((
              $P { sort_order1 }= 'branchname' 
              OR $P { sort_order1 }= 'branchcode' 
              ),
            branch.NAME,
          IF
          (( $P { sort_order1 }= 'vendorname' OR $P { sort_order1 }= 'vendorcode' ), vendor.NAME, '' )))))) AS sort_field1,
IF
  (
    $P { sort_order2 }= 'txtype',
    ap.txtype,
  IF
    (
      $P { sort_order2 }= 'status',
      ap.STATUS,
    IF
      (
        $P { sort_order2 }= 'movcode',
        ap.movementtypecode,
      IF
        (
          $P { sort_order2 }= 'txdate',
          DATE_FORMAT( ap.txdate, '%Y-%m-%d' ),
        IF
          ((
              $P { sort_order2 }= 'branchname' 
              OR $P { sort_order2 }= 'branchcode' 
              ),
            branch.NAME,
          IF
          (( $P { sort_order2 }= 'vendorname' OR $P { sort_order2 }= 'vendorcode' ), vendor.NAME, '' )))))) AS sort_field2 
FROM
  apap AS ap
  LEFT JOIN view_apapmaterialitem_report AS apdetail ON ap.id = apdetail.apid
  LEFT JOIN materialmaterial AS mat ON apdetail.materialid = mat.id
  LEFT JOIN materialgroupmaterialgroup AS matgroup ON matgroup.id = mat.materialgroupid
  LEFT JOIN unitofmeasureunitofmeasure uom ON apdetail.order_unitid = uom.id
  LEFT JOIN businesspartnerbusinesspartner AS vendor ON ap.businesspartnerid = vendor.id
  LEFT JOIN branchbranch AS branch ON ap.branchid = branch.id
  LEFT JOIN ( SELECT ap.id, ib.txdate FROM inbounddeliveryinbounddelivery AS ib LEFT JOIN apap AS ap ON ap.flow_refdocno = ib.txno ) AS ib ON ap.id = ib.id 
  AND ap.FLOW_REFDOCTYPE IN ( 'ib', 'ib5' )
  LEFT JOIN ( SELECT ap.id, po.txdate FROM popo AS po LEFT JOIN apap AS ap ON ap.flow_refdocno = po.txno ) AS po ON ap.id = po.id 
  AND ap.FLOW_REFDOCTYPE = 'po'
  LEFT JOIN (
  SELECT
    a.NAME AS costcenterview,
    c.map_key,
    d.id AS branchid,
    d.CODE AS branchcode,
    ifnull( f.CODE, b.CODE ) AS branch_costhiearchy,
    ifnull( f.NAME, b.NAME ) AS branch_costname 
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
    ifnull( f.CODE, b.CODE ) AS depart_costhiearchy,
    ifnull( f.NAME, b.NAME ) AS depart_costname 
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
  ap.txtype = 'AP1' $P !{ ExternalWhereClause } 
ORDER BY
  $P !{ sort_order1 },
  $P !{ sort_order2 },
  ap.txno,
  apdetail.detailorderno