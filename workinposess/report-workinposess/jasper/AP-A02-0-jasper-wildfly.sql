SELECT
  ap.txtype,
  ap.txdate,
  ap.txno,
  ap.duedate,
  ap.document_categoryCode,
  ap.deposit_after_vat,
  ap.prepaid_amount,
  IF(ap.movementtypecode IS NULL, '', ap.movementtypecode) AS movcode,
  IF(ap.movementtypename IS NULL, '', ap.movementtypename) AS movname,
  IF(ap.businesspartnercode IS NULL, '', ap.businesspartnercode) AS vendorcode,
  IF(ap.businesspartnername IS NULL, '', ap.businesspartnername) AS vendorname,
  ap.refdocno,
  ap.STATUS,
  ap.remark,
  IF(ap.branchcode IS NULL, '', ap.branchcode) AS branchcode,
  IF(ap.branchname IS NULL, '', ap.branchname) AS branchname,
  IF(apdetail.materialcode IS NULL, '', apdetail.materialcode) AS materialcode,
  IF(apdetail.materialname IS NULL, '', apdetail.materialname) AS materialname,
  IF(apdetail.NAME IS NULL, '', apdetail.NAME) AS uom,
  IF(ap.departmentcode IS NULL, '', ap.departmentcode) AS depcode,
  IF(ap.departmentname IS NULL, '', ap.departmentname) AS depname,

  apdetail.quantity,
  apdetail.price_per_unit AS price,
  apdetail.amount AS amount,
  apdetail.discount_amount AS discount_amount,
  apdetail.netamount_after_vat,
  IF(
    ap.vat_type = 1,
    (
      apdetail.netamount_before_vat - (
        apdetail.adjust_amount - ROUND(
          apdetail.adjust_amount * ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / (100 + ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)),
          5
        )
      )
    ),
    apdetail.netamount_before_vat - apdetail.adjust_amount
  ) AS netamount_before_vat,
  IF(
    ap.vat_type = 1,
    (
      apdetail.vat_amount - ROUND(
        apdetail.adjust_amount * ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2) / (100 + ROUND(apdetail.vat_amount * 100 / apdetail.netamount_before_vat, 2)),
        5
      )
    ),
    (
      apdetail.vat_amount - ROUND(apdetail.adjust_amount * (ROUND(apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5)
    )
  ) AS vat_amount,
  IF(
    ap.vat_type = 1,
    apdetail.netamount_after_vat - apdetail.adjust_amount,
    (
      apdetail.netamount_after_vat - ROUND(apdetail.adjust_amount * (1 + ROUND(apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5)
    )
  ) AS netamount,
  IF(
    $P{sort_order1} = 'txtype',
    ap.txtype,
    IF(
      $P{sort_order1} = 'status',
      ap.STATUS,
      IF(
        $P{sort_order1} = 'movcode',
        ap.movementtypecode,
        IF(
          $P{sort_order1} = 'depcode',
          ap.departmentcode,
          IF(
            $P{sort_order1} = 'txdate',
            DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
            IF(
              ($P{sort_order1} = 'branchname' OR $P{sort_order1} = 'branchcode'),
              ap.branchname,
              IF(
                ($P{sort_order1} = 'vendorname' OR $P{sort_order1} = 'vendorcode'),
                ap.businesspartnername,
                ''
              )
            )
          )
        )
      )
    )
  ) AS sort_field1,
  IF(
    $P{sort_order2} = 'txtype',
    ap.txtype,
    IF(
      $P{sort_order2} = 'status',
      ap.STATUS,
      IF(
        $P{sort_order2} = 'movcode',
        ap.movementtypecode,
        IF(
          $P{sort_order2} = 'depcode',
          ap.departmentcode,
          IF(
            $P{sort_order2} = 'txdate',
            DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
            IF(
              ($P{sort_order2} = 'branchname' OR $P{sort_order2} = 'branchcode'),
              ap.branchname,
              IF(
                ($P{sort_order2} = 'vendorname' OR $P{sort_order2} = 'vendorcode'),
                ap.businesspartnername,
                ''
              )
            )
          )
        )
      )
    )
  ) AS sort_field2
FROM
  view_ap_ap2_header AS ap
  LEFT JOIN view_ap_ap_material AS apdetail ON ap.id = apdetail.apid
WHERE
  ap.txtype = 'AP2' $P!{ExternalWhereClause}
ORDER BY
  $P!{sort_order1},
  $P!{sort_order2},
  ap.txno;
