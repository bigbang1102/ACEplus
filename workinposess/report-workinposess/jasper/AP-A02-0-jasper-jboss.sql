select ap.txtype, ap.txdate, ap.txno, ap.duedate, ap.document_categoryCode, ap.deposit_after_vat, ap.prepaid_amount
, IF(ap.movementtypecode is null,'',ap.movementtypecode) as movcode
, IF(ap.movementtypename is null,'',ap.movementtypename) as movname
, if(vendor.code is null,'',vendor.code) as vendorcode
, if(vendor.name is null,'',vendor.name) as vendorname
, ap.refdocno, ap.status, ap.remark
, if(branch.code is null,'',branch.code) as branchcode
, if(branch.name is null,'',branch.name) as branchname
, if(mat.code is null,'',mat.code) as materialcode
, if(mat.name is null,'',mat.name) as materialname
, if(uom.name is null,'',uom.name) as uom
, if(dep.code is null,'',dep.code) as depcode
, if(dep.name is null,'',dep.name) as depname
#, if(warehouse.code is null,'',warehouse.code) as warehousecode
#, if(warehouse.name is null,'',warehouse.name) as warehousename
, apdetail.quantity
, apdetail.price_per_unit as price
, apdetail.amount as amount
, apdetail.discount_amount as discount_amount

, ap.netamount_after_vat
, if(ap.vat_type = 1
,(apdetail.netamount_before_vat-(apdetail.adjust_amount-rounda(apdetail.adjust_amount*round(apdetail.vat_amount*100/apdetail.netamount_before_vat,2)/(100+round(apdetail.vat_amount*100/apdetail.netamount_before_vat,2)),5)))
,apdetail.netamount_before_vat- apdetail.adjust_amount) as netamount_before_vat

, if(ap.vat_type = 1
,(apdetail.vat_amount-round(apdetail.adjust_amount*round(apdetail.vat_amount*100/apdetail.netamount_before_vat,2)/(100+round(apdetail.vat_amount*100/apdetail.netamount_before_vat,2)),5))
,(apdetail.vat_amount-round(apdetail.adjust_amount*(round(apdetail.vat_amount/apdetail.netamount_after_vat,2)),5))) as vat_amount


, if(ap.vat_type = 1
,apdetail.netamount_after_vat- apdetail.adjust_amount
,(apdetail.netamount_after_vat-round(apdetail.adjust_amount*(1+round(apdetail.vat_amount/apdetail.netamount_after_vat,2)),5))
) as netamount

, if($P{sort_order1}='txtype',ap.txtype
,if($P{sort_order1}='status',ap.status
,if($P{sort_order1}='movcode',ap.movementtypecode
,if($P{sort_order1}='depcode',dep.code
,if($P{sort_order1}='txdate',DATE_FORMAT(ap.txdate,'%Y-%m-%d')
,if(($P{sort_order1}='branchname' or $P{sort_order1}='branchcode'),branch.name
,if(($P{sort_order1}='vendorname' or $P{sort_order1}='vendorcode'),vendor.name,''))))))) as sort_field1
, if($P{sort_order2}='txtype',ap.txtype
,if($P{sort_order2}='status',ap.status
,if($P{sort_order2}='movcode',ap.movementtypecode
,if($P{sort_order2}='depcode',dep.code
,if($P{sort_order2}='txdate',DATE_FORMAT(ap.txdate,'%Y-%m-%d')
,if(($P{sort_order2}='branchname' or $P{sort_order2}='branchcode'),branch.name
,if(($P{sort_order2}='vendorname' or $P{sort_order2}='vendorcode'),vendor.name,''))))))) as sort_field2
from apap as ap left join view_apapmaterialitem_report as apdetail on ap.id=apdetail.apid left join materialmaterial as mat on apdetail.materialid=mat.id
left join materialgroupmaterialgroup as matgroup on matgroup.id=mat.materialgroupid
left join unitofmeasureunitofmeasure uom on apdetail.order_unitid=uom.id
#left join warehousewarehouse warehouse on apdetail.warehouseid=warehouse.id
#left join employeeemployee as emp on ap.purchase_personid=emp.id
left join departmentdepartment as dep on ap.departmentid=dep.id
left join businesspartnerbusinesspartner as vendor on ap.businesspartnerid=vendor.id
left join branchbranch as branch on ap.branchid=branch.id
#left join deliveryplacedeliveryplace as deli on ap.deliveryplaceid=deli.id
where ap.txtype='AP2' $P!{ExternalWhereClause}
order by $P!{sort_order1}, $P!{sort_order2},ap.txno