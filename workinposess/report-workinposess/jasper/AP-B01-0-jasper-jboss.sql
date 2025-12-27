SELECT
  ap.txtype,
  ap.txdate,
  ap.txno,
  ap.outstanding,
  IF(vendor.CODE IS NULL, '', vendor.CODE) AS vendorcode,
  IF(vendor.NAME IS NULL, '', vendor.NAME) AS vendorname,
  ap.refdocno,
  ap.STATUS,
  ap.remark,
  ap.duedate,
  ap.remain_amount,
  IF(mov.CODE IS NULL, '', mov.CODE) AS movcode,
  IF(mov.NAME IS NULL, '', mov.NAME) AS movname,
  IF(branch.CODE IS NULL, '', branch.CODE) AS branchcode,
  IF(branch.NAME IS NULL, '', branch.NAME) AS branchname,
  IF(matgroup.CODE IS NULL, '', matgroup.CODE) AS matgroupcode,
  IF(matgroup.NAME IS NULL, '', matgroup.NAME) AS matgroupname,
  IF(mat.CODE IS NULL, '', mat.CODE) AS materialcode,
  IF(mat.NAME IS NULL, '', mat.NAME) AS materialname,
  IF(uom.NAME IS NULL, '', uom.NAME) AS uom,
  ap.prepaid_amount AS prepaid_amount,
  sum(apdetail.price_per_unit) AS price,
  sum(apdetail.amount) AS apdetail,
  sum(apdetail.pay_amount) AS pay_amount,
  sum(apdetail.vat_amount) AS vat_amount,
  sum(apdetail.netamount_after_vat) AS netamount,
  apreftax.cn_balance AS cn_balance,
  ap.netamount_before_vat AS netamount_before_vat,
  (ap.positive_adjust + ap.positive_adjust_from_exchangerate + ap.positive_adjust_from_other - ap.negative_adjust - ap.negative_adjust_from_exchangerate - ap.negative_adjust_from_other) AS adjust_amount,
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
    $P { sort_order1 }= 'txtype',
    ap.txtype,
    IF(
      $P { sort_order1 }= 'status',
      ap.STATUS,
      IF(
        $P { sort_order1 }= 'movcode',
        mov.CODE,
        IF(
          $P { sort_order1 }= 'txdate',
          DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P { sort_order1 }= 'branchname' OR $P { sort_order1 }= 'branchcode'),
            branch.CODE,
            IF(($P { sort_order1 }= 'vendorname' OR $P { sort_order1 }= 'vendorcode'), vendor.CODE, '')
          )
        )
      )
    )
  ) AS sort_field1,
  IF(
    $P { sort_order2 }= 'txtype',
    ap.txtype,
    IF(
      $P { sort_order2 }= 'status',
      ap.STATUS,
      IF(
        $P { sort_order2 }= 'movcode',
        mov.CODE,
        IF(
          $P { sort_order2 }= 'txdate',
          DATE_FORMAT(ap.txdate, '%Y-%m-%d'),
          IF(
            ($P { sort_order2 }= 'branchname' OR $P { sort_order2 }= 'branchcode'),
            branch.CODE,
            IF(($P { sort_order2 }= 'vendorname' OR $P { sort_order2 }= 'vendorcode'), vendor.CODE, '')
          )
        )
      )
    )
  ) AS sort_field2
FROM
  apap AS ap
  LEFT JOIN view_apapmaterialitem_report AS apdetail ON ap.id = apdetail.apid
  LEFT JOIN apapreferencetaxinvoiceitem AS apreftax ON ap.id = apreftax.apid
  LEFT JOIN materialmaterial AS mat ON apdetail.materialid = mat.id
  LEFT JOIN materialgroupmaterialgroup AS matgroup ON mat.materialgroupid = matgroup.id
  LEFT JOIN materialtypematerialtype AS mattype ON matgroup.materialtypeid = mattype.id
  LEFT JOIN unitofmeasureunitofmeasure uom ON apdetail.order_unitid = uom.id
  LEFT JOIN businesspartnerbusinesspartner AS vendor ON ap.businesspartnerid = vendor.id
  LEFT JOIN movementtypemovementtype AS mov ON ap.movementtypeid = mov.id
  LEFT JOIN branchbranch AS branch ON ap.branchid = branch.id
  LEFT JOIN vendorgroupvendorgroup AS vendorgroup ON vendor.vendorgroupid = vendorgroup.id
WHERE
  ap.txtype = 'AP1' $P !{ ExternalWhereClause }
GROUP BY
  ap.txno
ORDER BY
  $P !{ sort_order1 },
  $P !{ sort_order2 },
  ap.txno