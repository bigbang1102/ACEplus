-- pv_1.jrxml
SELECT
c.name as vat_businesspartner_name,ifnull(A.movementtypename,'') as movementtypename,ifnull(A.document_categoryname,'') as document_categoryname,
A.txno as txno,A.txdate as txdate,ifnull(A.refdocno,'') as refdocno,A.refdocdate as refdocdate,ifnull(B.flow_refdocno,'') as flow_refdocno,A.duedate
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
left join view_arar_form D on D.request_personid = C.id AND B.flow_refdocno = D.txno AND B.flow_refdoctype = D.txtype
WHERE A.txno= $P{txno}

-- pv_pv_vendor.jrxml
select
a.payee_businesspartnerCode,a.payee_businesspartnername,b.address
,b.city,b.country,b.zipcode,b.taxid,b.branchno,b.branchname
from pvpv a,businesspartnerbusinesspartner b
where a.PAYEE_BUSINESSPARTNERCODE=b.CODE and
a.txno = $P{txno}

-- pv_sub_product_1.jrxml
select
arref.row_count as row_count
,arref.amount_total as amount_total
,ifnull(pvdep.netamount_after_vat,0) as deposit
,pv.purchase_discount_amount as additional_discount
,pv.total_positive_negative_adjust as adjust_discount
,round(sum(round(pvitem.netamount_after_vat,2))-ifnull(pvdep.netamount_after_vat,0)-(pv.netamount_after_vat),2) as other_discount
,ifnull(pvdep.netamount_before_vat,0) as deposit_netamount_before_vat
,ifnull(pvdep.vat_amount,0) as deposit_vat_amount
,ifnull(pvdep.netamount_after_vat,0) as deposit_netamount_after_vat
,pv.netamount_before_vat as netamount_before_vat
,pv.vat_amount as vat_amount
,pv.netamount_after_vat as netamount_after_vat
,pv.remark as remark
,arref.quantity as quantity
from view_pvpv_form pv
left join view_pvpvmaterialitem_form pvitem on pv.id = pvitem.pvid
left join ( select pvdep.pvid,ifnull(sum(pvdep.netamount_after_vat),0) as netamount_after_vat,sum(pvdep.vat_amount) as vat_amount, sum(pvdep.netamount_before_vat) as netamount_before_vat  from view_pvpv_form pv
left join view_pvpvdeposititem_form pvdep on pv.id = pvdep.pvid where pv.txno = $P{txno} ) as pvdep on pv.id = pvdep.pvid
left join (select pv.id,sum(round(arref.netamount_after_vat,2)) as amount_total,count(arref.detailorderno) as row_count,sum(arref.quantity) as quantity from view_pvpv_form pv
left join view_pvpvmaterialitem_form pvitem on pv.id = pvitem.pvid
left join view_arar_form ar on pvitem.flow_refdocno=ar.txno
left join view_ararmaterialitem_form aritem on ar.id = aritem.arid and pvitem.flow_refdetailorderno = aritem.detailorderno
left join view_ararreferenceitem_form arref on ar.id=arref.arid and aritem.detailorderno = arref.material_detailorderno
where pv.txno = $P{txno}
) as arref on pv.id = arref.id
where pv.txno = $P{txno}


-- pv_sub_product_sub.jrxml
select
arref.materialcode
, arref.materialname
, arref.quantity as qty
, arref.order_unitname as uom
, arref.price_per_unit as price_per_unit
, if(arref.discount_value ='',0.00000,arref.discount_value) as discount
, arref.netamount_after_vat as total
#, (arref.amount_before_previous_discount) as total
,IF(LENGTH(arref.materialcode)<=41,CONCAT(SUBSTR(arref.materialcode,1,23)," ",SUBSTR(arref.materialcode,24,17)),CONCAT(SUBSTR(arref.materialcode,1,23)," ",SUBSTR(arref.materialcode,24,17),"...")) as length_matcode
,SUBSTR(arref.materialcode,41) as length_matcode1
,IF((LENGTH(arref.materialname)+LENGTH(SUBSTR(arref.materialcode,41)))-6 <=85,CONCAT(SUBSTR(arref.materialname,1,(85-length(SUBSTR(arref.materialcode,41)))-4)),CONCAT(SUBSTR(arref.materialname,1,(85-length(SUBSTR(arref.materialcode,41)))-6),"...")) as length_matname
from view_pvpv_form pv
left join view_pvpvmaterialitem_form pvitem on pv.id = pvitem.pvid
left join view_arar_form ar on pvitem.flow_refdocno=ar.txno
left join view_ararmaterialitem_form aritem on ar.id = aritem.arid and pvitem.flow_refdetailorderno = aritem.detailorderno
left join view_ararreferenceitem_form arref on ar.id=arref.arid and aritem.detailorderno = arref.material_detailorderno
where pv.txno = $P{txno}
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