SELECT t.*, 

  COUNT(*) OVER () AS total_rows 

FROM (

SELECT 
  c.NAME AS createby,
  IFNULL(pv.movementtypename, '') AS movementtypename,
  IFNULL(pv.document_categoryname, '') AS document_categoryname,
  pv.txno AS txno,
  pv.txdate AS txdate,
  IFNULL(pv.refdocno, '') AS refdocno,
  pv.refdocdate AS refdocdate,
  pv.duedate AS duedate,
  IFNULL(pvdetail.flow_refdocno, '') AS flow_refdocno,
  pv.payee_businesspartnercode AS payee_businesspartnerCode,
  pv.payee_businesspartnername AS payee_businesspartnername,
  pv.payee_address AS address,
  pv.payee_city AS city,
  pv.payee_country AS country,
  pv.payee_zipcode AS zipcode,
  pv.payee_taxid AS taxid,
  pv.payee_branchno AS branchno,
  pv.payee_branchname AS branchname,
  pv.STATUS AS st,
  pv.txtype AS tx,
  pv.createbyname AS createbyname,
IFNULL(wht.witholdingtax,'') AS witholdingtax,
IFNULL(wht.count_witholdingtax,0) AS count_witholdingtax2,

  aprefAgg.row_count AS row_count,
  aprefAgg.amount_total AS amount_total,
  IFNULL(pvdep.netamount_after_vat, 0) AS deposit,
  pvf.purchase_discount_amount AS additional_discount,
  pvf.total_positive_negative_adjust AS adjust_discount,
  ROUND(ROUND(aprefAgg.amount_total, 2) - IFNULL(pvdep.netamount_after_vat, 0) - (pvf.netamount_after_vat), 2) AS other_discount,
  IFNULL(pvdep.netamount_before_vat, 0) AS deposit_netamount_before_vat,
  IFNULL(pvdep.vat_amount, 0) AS deposit_vat_amount,
  IFNULL(pvdep.netamount_after_vat, 0) AS deposit_netamount_after_vat,
  pvf.netamount_before_vat AS netamount_before_vat,
  pvf.vat_amount AS vat_amount,
  pvf.remark AS remark,
  IFNULL(pay.payment,'') AS payment,
  aprefAgg.quantity AS quantity, 
  IFNULL(GROUP_CONCAT(DISTINCT pvdetail.flow_refdocno), '') AS group_flow_refdocno,
  COUNT(DISTINCT pvdetail.flow_refdocno) AS count_flow_refdocno, 
  pvdetail.materialcode AS materialcode,
  pvdetail.materialname AS materialname,
  pvdetail.apref_quantity AS qty,
  pvdetail.order_unitname AS uom,
  pvdetail.price_per_unit AS price_per_unit,
IFNULL(pvsum.netamount_after_vat,0)            AS pv_netamount_after_vat,
IFNULL(pvsum.unpaid_amount,0)                  AS unpaid_amount,
IFNULL(pvsum.outstanding,0)                    AS outstanding,
IFNULL(pvsum.creditnote_amount,0)              AS creditnote_amount,
IFNULL(pvsum.deposit_after_vat,0)              AS deposit_after_vat2,
IFNULL(pvsum.prepaid_amount,0)                 AS prepaid_amount,
IFNULL(pvsum.pay_amount,0)                     AS pay_amount,
IFNULL(pvsum.witholdingtax_amount,0)           AS witholdingtax_amount,
IFNULL(pvsum.total_positive_negative_adjust,0) AS total_positive_negative_adjust2,
IFNULL(pvsum.extra_discount_amount,0)          AS extra_discount_amount,
IFNULL(pvsum.prepaid_remain_amount,0)          AS prepaid_remain_amount,
IFNULL(pvsum.payment_medium_amount,0)          AS payment_medium_amount,
  IF(pvdetail.discount_value = '', 0.00000, pvdetail.discount_value) AS discount,
  pvdetail.netamount_after_vat AS netamount_after_vat,
  pvdetail.amount_before_previous_discount AS total,
  IF(
    LENGTH(pvdetail.materialcode) <= 41,
    CONCAT(SUBSTR(pvdetail.materialcode, 1, 23), ' ', SUBSTR(pvdetail.materialcode, 24, 17)),
    CONCAT(SUBSTR(pvdetail.materialcode, 1, 23), ' ', SUBSTR(pvdetail.materialcode, 24, 17), '...')
  ) AS length_matcode,
  SUBSTR(pvdetail.materialcode, 41) AS length_matcode1,
  IF(
    (LENGTH(pvdetail.materialname) + LENGTH(SUBSTR(pvdetail.materialcode, 41))) - 6 <= 85,
    SUBSTR(pvdetail.materialname, 1, (85-LENGTH (SUBSTR(pvdetail.materialcode, 41))) - 4),
    CONCAT(SUBSTR(pvdetail.materialname, 1, (85-LENGTH (SUBSTR(pvdetail.materialcode, 41))) - 6), '...')
  ) AS length_matname, 
  (
    SELECT
      GROUP_CONCAT(
        b.witholdingtax_book_no,
        ' ',
        CONVERT(b.witholdingtax_date, CHAR(100)),
        ' ',
        b.witholdingtax_vendorname,
        ' ',
        FORMAT(b.pay_amount_before_vat, 2),
        ' ',
        b.witholdingtax_rate,
        ' ',
        FORMAT(b.witholdingtax_amount, 2),
        ' ',
        b.witholdingtaxname
      )
    FROM
      view_pvpv_form a
      LEFT JOIN pvpvwitholdingtaxitem b ON a.id = b.pvid
    WHERE
      a.txno = $P{txno}
  ) AS group_witholdingtax,
  (
    SELECT
      COUNT(b.witholdingtax_book_no)
    FROM
      view_pvpv_form a
      LEFT JOIN pvpvwitholdingtaxitem b ON a.id = b.pvid
    WHERE
      a.txno = $P{txno}
  ) AS count_witholdingtax
FROM
  view_pv_pv_header pv
  LEFT JOIN view_pv_ap_material pvdetail ON pv.id = pvdetail.pvid
  LEFT JOIN employeeemployee c ON c.id = pv.createbyid
  LEFT JOIN view_pvpv_form pvf ON pvf.txno = pv.txno
  LEFT JOIN (
    SELECT
      pvdep.pvid,
      IFNULL(SUM(pvdep.netamount_after_vat), 0) AS netamount_after_vat,
      SUM(pvdep.vat_amount) AS vat_amount,
      SUM(pvdep.netamount_before_vat) AS netamount_before_vat
    FROM
      view_pvpv_form pv
      LEFT JOIN view_pvpvdeposititem_form pvdep ON pv.id = pvdep.pvid
    WHERE
      pv.txno = $P{txno}
    GROUP BY
      pvdep.pvid
  ) AS pvdep ON pvf.id = pvdep.pvid
  LEFT JOIN (
    SELECT
      pv.id AS id,
      SUM(ROUND(apref.netamount_after_vat, 2)) AS amount_total,
      COUNT(apref.detailorderno) AS row_count,
      SUM(apref.quantity) AS quantity
    FROM
      view_pvpv_form pv
      LEFT JOIN view_pvpvmaterialitem_form pvitem ON pv.id = pvitem.pvid
      LEFT JOIN view_apap_form ap ON pvitem.flow_refdocno = ap.txno
      LEFT JOIN view_apapmaterialitem_form apitem ON ap.id = apitem.apid
      AND pvitem.flow_refdetailorderno = apitem.detailorderno
      LEFT JOIN view_apapreferenceitem_form apref ON ap.id = apref.apid
      AND apitem.detailorderno = apref.material_detailorderno
    WHERE
      pv.txno = $P{txno}
    GROUP BY
      pv.id
  ) AS aprefAgg ON pvf.id = aprefAgg.id
  LEFT JOIN (
    SELECT
      A.txno AS txno,
      GROUP_CONCAT(
        CONCAT(
          IFNULL(B.witholdingtax_book_no, ''),
          ' ',
          IFNULL(B.witholdingtax_no, ''),
          ' ',
          IFNULL(CONVERT(B.witholdingtax_date, CHAR(100)), ''),
          ' ',
          IFNULL(B.witholdingtax_vendorname, ''),
          ' ',
          IFNULL(FORMAT(B.pay_amount_before_vat, 2), ''),
          ' ',
          IFNULL(B.witholdingtax_rate, ''),
          ' ',
          IFNULL(FORMAT(B.witholdingtax_amount, 2), ''),
          ' ',
          IFNULL(B.witholdingtaxname, '')
        ) SEPARATOR ','
      ) AS witholdingtax,
      COUNT(B.witholdingtax_book_no) AS count_witholdingtax
    FROM
      pvpv A
      LEFT JOIN pvpvwitholdingtaxitem B ON A.id = B.pvid
    WHERE
      A.txno = $P{txno}
    GROUP BY
      A.txno
  ) wht ON wht.txno = pv.txno

  LEFT JOIN (
    SELECT
        A.txno AS txno,
        GROUP_CONCAT(
            CONCAT(
                IFNULL(B.paymentmethodname,''),'  ',
                IFNULL(B.paymedium_code,''),'  ',
                IFNULL(CONVERT(B.paymedium_date,CHAR(100)),''),'  ',
                IFNULL(FORMAT(B.medium_amount,2),''),'  ',
                IFNULL(B.payeename,'')
            )
            SEPARATOR ','
        ) AS payment
    FROM view_pvpv_form A
    LEFT JOIN pvpvpaymentitem B ON A.id = B.pvid
    WHERE A.txno = $P{txno}
    GROUP BY A.txno
) pay ON pay.txno = pv.txno
LEFT JOIN (
    SELECT
        A.txno AS txno,
        ROUND(A.netamount_after_vat,2)  AS netamount_after_vat,
        ROUND(A.unpaid_amount,2)        AS unpaid_amount,
        ROUND(A.outstanding,2)          AS outstanding,
        ROUND(A.creditnote_amount,2)    AS creditnote_amount,
        IFNULL(ROUND(SUM(pvdep.netamount_after_vat),2),0) AS deposit_after_vat,
        ROUND(A.prepaid_amount,2)       AS prepaid_amount,
        ROUND(A.pay_amount,2)           AS pay_amount,
        ROUND(A.witholdingtax_amount,2) AS witholdingtax_amount,
        ROUND(A.total_positive_negative_adjust + A.purchase_discount_amount,2)
                                      AS total_positive_negative_adjust,
        ROUND(A.extra_discount_amount,2) AS extra_discount_amount,
        ap.prepaid_remain_amount        AS prepaid_remain_amount,
        ROUND(A.payment_medium_amount,2) AS payment_medium_amount
    FROM view_pvpv_form A
    LEFT JOIN view_pvpvdeposititem_form pvdep ON A.id = pvdep.pvid
    LEFT JOIN view_apap_form ap ON A.flow_refdocno = ap.txno
    WHERE A.txno = $P{txno}
    GROUP BY A.txno
) pvsum ON pvsum.txno = pv.txno

WHERE pv.txno = $P{txno}
) t;
