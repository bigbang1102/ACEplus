WITH params AS (
  SELECT
    $P{txno} AS txno,
    IFNULL($P{row_count},0) AS row_count
)
SELECT t.*,
       COUNT(*) OVER () AS total_rows
FROM (
    SELECT
        c.NAME AS createby,
        IFNULL(pv.movementtypename,'')      AS movementtypename,
        IFNULL(pv.document_categoryname,'') AS document_categoryname,
        pv.txno,
        pv.txdate,
        IFNULL(pv.refdocno,'')              AS refdocno,
        pv.refdocdate,
        pv.duedate,
        IFNULL(pvdetail.flow_refdocno,'')   AS flow_refdocno,
        pv.payee_businesspartnercode        AS payee_businesspartnerCode,
        pv.payee_businesspartnername        AS payee_businesspartnername,
        pv.payee_address                    AS address,
        pv.payee_city                       AS city,
        pv.payee_country                    AS country,
        pv.payee_zipcode                    AS zipcode,
        pv.payee_taxid                      AS taxid,
        pv.payee_branchno                   AS branchno,
        pv.payee_branchname                 AS branchname,

        pv.status                           AS st,
        pv.txtype                           AS tx,
        pv.createbyname                     AS createbyname,

        IFNULL(wht.witholdingtax,'')        AS witholdingtax,
        IFNULL(wht.count_witholdingtax,0)   AS count_witholdingtax,
        IFNULL(wht.count_witholdingtax,0)   AS count_witholdingtax2,
        IFNULL(flowAgg.count_flow_refdocno,0) AS count_flow_refdocno,
        pvf.purchase_discount_amount        AS additional_discount,
        pvf.total_positive_negative_adjust  AS adjust_discount,
        pvf.netamount_before_vat            AS netamount_before_vat,
        pvf.vat_amount                      AS vat_amount,
        pvf.netamount_after_vat             AS netamount_after_vat,
        pvf.remark                          AS remark,
        IFNULL(pay.payment,'')              AS payment,
        IFNULL(pm.paymentcode,'')           AS paymentcode,
        IFNULL(pm.paymentname,'')           AS paymentname,
        IFNULL(pm.paymedium_code,'')        AS paymedium_code,
        pm.paymedium_date                   AS paymedium_date,
        IFNULL(pm.paymenttocode,'')         AS paymenttocode,
        IFNULL(pm.paycode,'')               AS paycode,
        IFNULL(pm.payname,'')               AS payname,
        IFNULL(pm.amount,0)                 AS amount,

        IFNULL(payAgg.row_count,0)          AS row_count,
        IFNULL(payAgg.amount_total,0)       AS amount_total,
        IFNULL(payAgg.other_discount,0)     AS other_discount,
        IFNULL(payAgg.netamount_before_vat,0) AS netamount_before_vat2,
        IFNULL(payAgg.vat_amount,0)         AS vat_amount2,
        IFNULL(payAgg.netamount_after_vat,0) AS netamount_after_vat2,
        IFNULL(payAgg.remark,'')            AS remark2,
        IFNULL(payAgg.additional_discount,0) AS additional_discount2,
        IFNULL(payAgg.adjust_discount,0)     AS adjust_discount2,

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
    FROM params
    JOIN view_pv_pv_header pv
      ON pv.txno = params.txno

    LEFT JOIN (
        SELECT pvid, MIN(flow_refdocno) AS flow_refdocno
        FROM view_pv_ap_material
        GROUP BY pvid
    ) pvdetail ON pvdetail.pvid = pv.id

    LEFT JOIN employeeemployee c ON c.id = pv.createbyid
    LEFT JOIN view_pvpv_form pvf ON pvf.txno = pv.txno

    LEFT JOIN (
        SELECT pvid, COUNT(DISTINCT flow_refdocno) AS count_flow_refdocno
        FROM view_pv_pv_material
        WHERE flow_refdocno IS NOT NULL AND flow_refdocno <> ''
        GROUP BY pvid
    ) flowAgg ON flowAgg.pvid = pv.id

    LEFT JOIN (
        SELECT
            A.txno AS txno,
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
                SEPARATOR ','
            ) AS witholdingtax,
            COUNT(B.witholdingtax_book_no) AS count_witholdingtax
        FROM pvpv A
        LEFT JOIN pvpvwitholdingtaxitem B ON A.id = B.pvid
        GROUP BY A.txno
    ) wht ON wht.txno = pv.txno

    LEFT JOIN (
        SELECT
            pvid,
            GROUP_CONCAT(
                CONCAT(
                    IFNULL(PAYMENTMETHODNAME,''),'  ',
                    IFNULL(PAYMEDIUM_CODE,''),'  ',
                    IFNULL(CONVERT(PAYMEDIUM_DATE,CHAR(100)),''),'  ',
                    IFNULL(FORMAT(MEDIUM_AMOUNT,2),''),'  ',
                    IFNULL(PAYEENAME,'')
                )
                SEPARATOR ','
            ) AS payment
        FROM view_pv_pm_material
        GROUP BY pvid
    ) pay ON pay.pvid = pv.id

    LEFT JOIN (
        SELECT *
        FROM (
            SELECT
                a.id AS pvid,
                b.PAYMENTMETHODCODE AS paymentcode,
                b.PAYMENTMETHODNAME AS paymentname,
                b.PAYMEDIUM_CODE    AS paymedium_code,
                b.PAYMEDIUM_DATE    AS paymedium_date,
                a.remark            AS paymenttocode,
                b.PAYEECODE         AS paycode,
                b.PAYEENAME         AS payname,
                b.MEDIUM_AMOUNT     AS amount,
                ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY b.PAYMEDIUM_DATE, b.PAYMEDIUM_CODE) AS rn
            FROM view_pvpv_form a
            LEFT JOIN view_pv_pm_material b ON a.id = b.PVID
        ) x
        JOIN params ON 1=1
        WHERE x.rn = (params.row_count + 1)
    ) pm ON pm.pvid = pv.id
LEFT JOIN (
    SELECT
        pv.id AS pvid,
        IFNULL(pmagg.row_count,0) AS row_count,
        IFNULL(pmagg.amount_total,0) * IFNULL(itemAgg.item_count,1) AS amount_total,
        pv.purchase_discount_amount            AS additional_discount,
        pv.total_positive_negative_adjust      AS adjust_discount,
        ROUND(
          (IFNULL(pmagg.amount_total,0) * IFNULL(itemAgg.item_count,1)) - pv.netamount_after_vat
        , 2) AS other_discount,
        pv.netamount_before_vat                AS netamount_before_vat,
        pv.vat_amount                          AS vat_amount,
        pv.netamount_after_vat                 AS netamount_after_vat,
        pv.remark                              AS remark
    FROM params
    JOIN view_pvpv_form pv
      ON pv.txno = params.txno

    LEFT JOIN (
        SELECT
            PVID AS pvid,
            COUNT(*) AS row_count,
            SUM(ROUND(MEDIUM_AMOUNT,2)) AS amount_total
        FROM view_pv_pm_material
        GROUP BY PVID
    ) pmagg ON pmagg.pvid = pv.id


    LEFT JOIN (
        SELECT
            pvid,
            COUNT(*) AS item_count
        FROM view_pv_ap_material
        GROUP BY pvid
    ) itemAgg ON itemAgg.pvid = pv.id
) payAgg ON payAgg.pvid = pv.id


    LEFT JOIN (
        SELECT
            A.txno AS txno,
            ROUND(A.netamount_after_vat,2)   AS netamount_after_vat,
            ROUND(A.unpaid_amount,2)         AS unpaid_amount,
            ROUND(A.outstanding,2)           AS outstanding,
            ROUND(A.creditnote_amount,2)     AS creditnote_amount,
            IFNULL(ROUND(SUM(pvdep.netamount_after_vat),2),0) AS deposit_after_vat,
            ROUND(A.prepaid_amount,2)        AS prepaid_amount,
            ROUND(A.pay_amount,2)            AS pay_amount,
            ROUND(A.witholdingtax_amount,2)  AS witholdingtax_amount,
            ROUND(A.total_positive_negative_adjust + A.purchase_discount_amount,2)
                                            AS total_positive_negative_adjust,
            ROUND(A.extra_discount_amount,2) AS extra_discount_amount,
            ap.prepaid_remain_amount         AS prepaid_remain_amount,
            ROUND(A.payment_medium_amount,2) AS payment_medium_amount
        FROM view_pvpv_form A
        LEFT JOIN view_pvpvdeposititem_form pvdep ON A.id = pvdep.pvid
        LEFT JOIN view_apap_form ap ON A.flow_refdocno = ap.txno
        GROUP BY A.txno
    ) pvsum ON pvsum.txno = pv.txno

) t;
