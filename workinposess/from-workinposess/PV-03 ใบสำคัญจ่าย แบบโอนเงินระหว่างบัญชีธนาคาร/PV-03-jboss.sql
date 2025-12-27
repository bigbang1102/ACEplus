-- pv_1.jrxml
SELECT
c.name as vat_businesspartner_name,ifnull(A.movementtypename,'') as movementtypename,ifnull(A.document_categoryname,'') as document_categoryname,
A.txno as txno,A.txdate as txdate,ifnull(A.refdocno,'') as refdocno,A.refdocdate as refdocdate,ifnull(B.flow_refdocno,'') as flow_refdocno,A.duedate as duedate
,A.status as st,A.txtype as tx,A.createbyname as createbyname
,ifnull(GROUP_CONCAT(distinct B.flow_refdocno),'') as group_flow_refdocno
,count(distinct B.flow_refdocno) as count_flow_refdocno
,(select group_concat(B.witholdingtax_book_no,'  ' ,CONVERT(B.witholdingtax_date, CHAR(100)) ,'  ',B.witholdingtax_vendorname ,'  ',format(B.pay_amount_before_vat,2) ,'  ',B.witholdingtax_rate ,'  ',format(B.witholdingtax_amount,2) ,'  ',B.witholdingtaxname )
from view_pvpv_form A left join pvpvwitholdingtaxitem B on A.id = B.pvid
where A.txno = $P{txno} ) as group_witholdingtax
,(select count(B.witholdingtax_book_no)
from view_pvpv_form A left join pvpvwitholdingtaxitem B on A.id = B.pvid
where A.txno = $P{txno} ) as count_witholdingtax
FROM view_pvpv_form A
left join view_pvpvmaterialitem_form B on A.id = B.pvid
left join employeeemployee C on C.id = A.createbyid
WHERE A.txno= $P{txno}

-- pv_vendor.jrxml
select
a.payee_businesspartnerCode,a.payee_businesspartnername,b.address
,b.city,b.country,b.zipcode,b.taxid,b.branchno,b.branchname
from pvpv a,businesspartnerbusinesspartner b
where a.PAYEE_BUSINESSPARTNERCODE=b.CODE and
a.txno = $P{txno}


-- pv_sub_product_1.jrxml
select
count(pvpay.detailorderno) as row_count
,sum(round(pvpay.medium_amount,2)) as amount_total
,pv.purchase_discount_amount as additional_discount
,pv.total_positive_negative_adjust as adjust_discount
,round(sum(round(pvpay.medium_amount,2))-pv.netamount_after_vat,2) as other_discount
,pv.netamount_before_vat as netamount_before_vat
,pv.vat_amount as vat_amount
,pv.netamount_after_vat as netamount_after_vat
,pv.remark as remark
from view_pvpv_form pv
left join view_pvpvmaterialitem_form pvitem on pv.id = pvitem.pvid
left join view_pvpvpaymentitem_form pvpay on pv.id = pvpay.pvid
where pv.txno = $P{txno}

-- pv_sub_product_sub.jrxml
select
b.paymentmethodcode as paymentcode
,b.paymentmethodname as paymentname
,b.paymedium_code as paymedium_code
,b.paymedium_date as paymedium_date
,a.remark as paymenttocode
,b.payeecode as paycode
,b.payeename as payname
,b.medium_amount as amount
from view_pvpv_form a
left join view_pvpvpaymentitem_form b on a.id = b.pvid
where a.txno = $P{txno}
limit $P{row_display},1



-- pv_sub_taxtx_sub.jrxml
select concat(B.witholdingtax_book_no,'  ',B.witholdingtax_no,'  ',B.witholdingtax_date
,'  ',B.witholdingtax_vendorname
,'  ',format(B.pay_amount_before_vat,2)
,'  ',B.witholdingtax_rate
,'  ',format(B.witholdingtax_amount,2)
,'  ',B.witholdingtaxname) as witholdingtax
,count(B.witholdingtax_book_no) as count_witholdingtax
from pvpv A left join pvpvwitholdingtaxitem B on A.id = B.pvid
where A.txno = $P{pvtxno}
limit 0,1


-- pv_sub_payment.jrxml
SELECT
round(A.netamount_after_vat,2) as netamount_after_vat
,round(A.unpaid_amount,2)as  unpaid_amount
,round(A.outstanding,2) as outstanding
,round(A.creditnote_amount,2)as creditnote_amount
#,round(A.deposit_after_vat,2) as deposit_after_vat
,ifnull(round(sum(pvdep.netamount_after_vat),2),0) as deposit_after_vat
,round(A.prepaid_amount,2)as prepaid_amount
,round(A.pay_amount,2)as pay_amount
,round(A.witholdingtax_amount,2)as witholdingtax_amount
,round(A.total_positive_negative_adjust+A.purchase_discount_amount,2) as total_positive_negative_adjust
,round(A.extra_discount_amount,2)as extra_discount_amount,ap.prepaid_remain_amount as prepaid_remain_amount
,round(A.payment_medium_amount,2) as payment_medium_amount
from view_pvpv_form A left join view_pvpvdeposititem_form pvdep on A.id = pvdep.pvid left join view_apap_form ap on A.flow_refdocno = ap.txno
WHERE  A.txno = $P{txno}


-- pv_sub_payment_sub.jrxml
SELECT concat(B.paymentmethodname,'  ',B.paymedium_code,'  ',B.paymedium_date,'  ',format(B.medium_amount,2),'  ',B.payeename) as payment
FROM view_pvpv_form A left join pvpvpaymentitem B on A.id = B.pvid
WHERE A.txno = $P{txno} #group by B.payeename
