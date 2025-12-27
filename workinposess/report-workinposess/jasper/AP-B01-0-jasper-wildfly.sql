SELECT
  ap.txtype,
  ap.txdate,
  ap.txno,
  ap.outstanding,
  IF(ap.businesspartnercode IS NULL, '', ap.businesspartnercode) AS vendorcode,
  IF(ap.businesspartnername IS NULL, '', ap.businesspartnername) AS vendorname,
  ap.refdocno,
  ap.STATUS,
  ap.remark,
  ap.duedate,
  ap.remain_amount,
  IF(ap.movementtypecode IS NULL, '', ap.movementtypecode) AS movcode,
  IF(ap.movementtypename IS NULL, '', ap.movementtypename) AS movname,
  IF(ap.branchcode IS NULL, '', ap.branchcode) AS branchcode,
  IF(ap.branchname IS NULL, '', ap.branchname) AS branchname,
  IF(apdetail.materialgroupcode IS NULL, '', apdetail.materialgroupcode) AS matgroupcode,
  IF(apdetail.materialgroupname IS NULL, '', apdetail.materialgroupname) AS matgroupname,
  IF(apdetail.materialcode IS NULL, '', apdetail.materialcode) AS materialcode,
  IF(apdetail.materialname IS NULL, '', apdetail.materialname) AS materialname,
  IF(apdetail.name IS NULL, '', apdetail.name) AS uom,
  ap.prepaid_amount AS prepaid_amount,
  sum(apdetail.price_per_unit) AS price,
  sum(apdetail.amount) AS apdetail,
  sum(apdetail.pay_amount) AS pay_amount,
  sum(apdetail.vat_amount) AS vat_amount,
  sum(apdetail.netamount_after_vat) AS netamount,
  apreftax.cn_balance AS cn_balance,
  apdetail.netamount_before_vat AS netamount_before_vat,
(
  IFNULL(ap.positive_adjust, 0) + 
  IFNULL(ap.positive_adjust_from_exchangerate, 0) + 
  IFNULL(ap.positive_adjust_from_other, 0) - 
  IFNULL(ap.negative_adjust, 0) - 
  IFNULL(ap.negative_adjust_from_exchangerate, 0) - 
  IFNULL(ap.negative_adjust_from_other, 0)
) AS adjust_amount,
  sum(
    IF(
      ap.vat_type = 1,
      apdetail.netamount_after_vat - apdetail.adjust_amount,
      (
        apdetail.netamount_after_vat - round(apdetail.adjust_amount * (1+round (apdetail.vat_amount / apdetail.netamount_after_vat, 2)), 5)
      )
    )
  ) AS netamount_after_vat,
  ap.amount AS amount,
  ap.deposit_after_vat AS deposit_after_vat,
  ap.arap_netamount_after_vat AS arap_netamount_after_vat,
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
          $P{sort_order1}= 'txdate',
          DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P{sort_order1}= 'branchname' OR $P{sort_order1}= 'branchcode'),
            ap.movementtypecode,
            IF(($P{sort_order1}= 'vendorname' OR $P{sort_order1}= 'vendorcode'), ap.businesspartnercode, '')
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
          $P{sort_order2}= 'txdate',
          DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P{sort_order2}= 'branchname' OR $P{sort_order2}= 'branchcode'),
            ap.branchcode,
            IF(($P{sort_order2}= 'vendorname' OR $P{sort_order2}= 'vendorcode'), ap.businesspartnercode, '')
          )
        )
      )
    )
  ) AS sort_field2
FROM
  view_ap_ap1_header AS ap
  LEFT JOIN view_ap_ap_material AS apdetail ON ap.id = apdetail.apid
  LEFT JOIN apapreferencetaxinvoiceitem AS apreftax ON ap.id = apreftax.apid

WHERE
  ap.txtype = 'AP1' $P!{ExternalWhereClause}
GROUP BY
  ap.txno
ORDER BY
  $P!{sort_order1},
  $P!{sort_order2},
  ap.txno