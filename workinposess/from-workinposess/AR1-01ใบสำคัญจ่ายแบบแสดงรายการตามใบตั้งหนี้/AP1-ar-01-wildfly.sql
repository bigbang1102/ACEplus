SELECT t.*,
       COUNT(*) OVER () AS total_rows
FROM (
    SELECT
        /* ===== HEADER ===== */
        c.NAME AS createby,
        pv.movementtypename,
        pv.document_categoryname,
        pv.txno,
        pv.txdate,
        pv.refdocno,
        pv.refdocdate,
        pv.duedate,

        /* payee */
        pv.payee_businesspartnercode AS payee_businesspartnerCode,
        pv.payee_businesspartnername,
        pv.payee_address  AS address,
        pv.payee_city     AS city,
        pv.payee_country  AS country,
        pv.payee_zipcode  AS zipcode,
        pv.payee_taxid    AS taxid,
        pv.payee_branchno AS branchno,
        pv.payee_branchname AS branchname,

        pv.status AS st,
        pv.txtype AS tx,
        pv.createbyname,

        IFNULL(wht.witholdingtax,'')        AS witholdingtax,
        IFNULL(wht.count_witholdingtax,0)  AS count_witholdingtax2,

        ar.materialcode,
        ar.materialname,
        ar.quantity            AS qty,
        ar.order_unitname      AS uom,
        ar.price_per_unit,
        IF(ar.discount_value='',0.00000,ar.discount_value) AS discount,
        ar.netamount_after_vat AS total,

        /* format */
        IF(LENGTH(ar.materialcode)<=41,
            CONCAT(SUBSTR(ar.materialcode,1,23),' ',SUBSTR(ar.materialcode,24,17)),
            CONCAT(SUBSTR(ar.materialcode,1,23),' ',SUBSTR(ar.materialcode,24,17),'...')
        ) AS length_matcode,
        SUBSTR(ar.materialcode,41) AS length_matcode1,
        IF(
            (LENGTH(ar.materialname)+LENGTH(SUBSTR(ar.materialcode,41)))-6 <=85,
            SUBSTR(ar.materialname,1,(85-LENGTH(SUBSTR(ar.materialcode,41)))-4),
            CONCAT(SUBSTR(ar.materialname,1,(85-LENGTH(SUBSTR(ar.materialcode,41)))-6),'...')
        ) AS length_matname,

        ar.flow_refdocno,
        IFNULL(flowAgg.count_flow_refdocno,0) AS count_flow_refdocno,

        IFNULL(pay.payment,'') AS payment,

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
        IFNULL(pvsum.payment_medium_amount,0)          AS payment_medium_amount

    FROM view_pv_pv_header pv
    LEFT JOIN view_pv_ar_material ar
           ON pv.id = ar.pvid
    LEFT JOIN employeeemployee c
           ON c.id = pv.createbyid
    LEFT JOIN (
        SELECT A.txno,
               GROUP_CONCAT(
                   CONCAT(
                       IFNULL(B.witholdingtax_book_no,''),' ',
                       IFNULL(B.witholdingtax_no,''),' ',
                       IFNULL(CONVERT(B.witholdingtax_date,CHAR(100)),''),' ',
                       IFNULL(B.witholdingtax_vendorname,''),' ',
                       IFNULL(FORMAT(B.pay_amount_before_vat,2),''),' ',
                       IFNULL(B.witholdingtax_rate,''),' ',
                       IFNULL(FORMAT(B.witholdingtax_amount,2),''),' ',
                       IFNULL(B.witholdingtaxname,'')
                   )
               ) AS witholdingtax,
               COUNT(B.witholdingtax_book_no) AS count_witholdingtax
        FROM pvpv A
        LEFT JOIN pvpvwitholdingtaxitem B ON A.id=B.pvid
        WHERE A.txno=$P{txno}
        GROUP BY A.txno
    ) wht ON wht.txno=pv.txno

    LEFT JOIN (
        SELECT A.txno,
               GROUP_CONCAT(
                   CONCAT(
                       IFNULL(B.paymentmethodname,''),' ',
                       IFNULL(B.paymedium_code,''),' ',
                       IFNULL(CONVERT(B.paymedium_date,CHAR(100)),''),' ',
                       IFNULL(FORMAT(B.medium_amount,2),''),' ',
                       IFNULL(B.payeename,'')
                   )
               ) AS payment
        FROM view_pvpv_form A
        LEFT JOIN pvpvpaymentitem B ON A.id=B.pvid
        WHERE A.txno=$P{txno}
        GROUP BY A.txno
    ) pay ON pay.txno=pv.txno
    LEFT JOIN (
 	 SELECT
    pvid,
    COUNT(DISTINCT flow_refdocno) AS count_flow_refdocno
  FROM view_pv_pv_material
  WHERE flow_refdocno IS NOT NULL AND flow_refdocno <> ''
  GROUP BY pvid
) flowAgg ON flowAgg.pvid = pv.id

    LEFT JOIN (
        SELECT
            A.txno,
            ROUND(A.netamount_after_vat,2) AS netamount_after_vat,
            ROUND(A.unpaid_amount,2)       AS unpaid_amount,
            ROUND(A.outstanding,2)         AS outstanding,
            ROUND(A.creditnote_amount,2)   AS creditnote_amount,
            IFNULL(ROUND(SUM(pvdep.netamount_after_vat),2),0) AS deposit_after_vat,
            ROUND(A.prepaid_amount,2)      AS prepaid_amount,
            ROUND(A.pay_amount,2)          AS pay_amount,
            ROUND(A.witholdingtax_amount,2) AS witholdingtax_amount,
            ROUND(A.total_positive_negative_adjust + A.purchase_discount_amount,2)
                                            AS total_positive_negative_adjust,
            ROUND(A.extra_discount_amount,2) AS extra_discount_amount,
            ap.prepaid_remain_amount,
            ROUND(A.payment_medium_amount,2) AS payment_medium_amount
        FROM view_pvpv_form A
        LEFT JOIN view_pvpvdeposititem_form pvdep ON A.id=pvdep.pvid
        LEFT JOIN view_apap_form ap ON A.flow_refdocno=ap.txno
        WHERE A.txno=$P{txno}
        GROUP BY A.txno
    ) pvsum ON pvsum.txno=pv.txno

    WHERE pv.txno=$P{txno}
) t;
