select wip.txno,
wip.txdate,
wip.refdocno,
'Raw Mat' as material_category
,ifnull(wip.movementtypecode,'') as movcode
,ifnull(wip.movementtypename,'') as movname,wip.status,ifnull(wiplist.name,'') as workinprocesslistname
,ifnull(wip.storagelocation_fromcode,'') as storagelocation_fromcode
,ifnull(wip.storagelocation_fromname,'') as storagelocation_fromname
,ifnull(wip.storagelocation_tocode,'') as storagelocation_tocode
,ifnull(wip.storagelocation_toname,'') as storagelocation_toname,wip.remark
,ifnull(issue.detailorderno,0) as detailorderno
,ifnull(actualissue.detailorderno,0) as actual_detailorderno
,ifnull(mattype.code,'') as materialtypecode
,ifnull(mattype.name,'') as materialtypename
,ifnull(issue.materialcode,'') as materialcode
,ifnull(issue.materialname,'') as materialname
,ifnull(issue.quantity,0) as quantity
,ifnull(issue.order_unitcode,'') as order_unitcode
,ifnull(issue.order_unitname,'') as order_unitname
,ifnull(if(issue.quantity>0,issue.cost_amount/issue.quantity,0),0) as cost_per_unit
,issue.cost_amount as cost_amount
,ifnull(issue.quantity2,0) as quantity2
,ifnull(issue.order_unit2code,'') as order_unit2code
,ifnull(issue.order_unit2name,'') as order_unit2name
,ifnull(actualissue.quantity,0) as actual_quantity
,ifnull(actualissue.order_unitcode,'') as actual_order_unitcode
,ifnull(actualissue.order_unitname,'') as actual_order_unitname
,ifnull(if(actualissue.cost_amount>0,actualissue.cost_amount/actualissue.quantity,0),0) as actual_cost_per_unit
,actualissue.cost_amount as actual_cost_amount
,ifnull(actualissue.quantity2,0) as actual_quantity2
,ifnull(actualissue.order_unit2code,'') as actual_order_unit2code
,ifnull(actualissue.order_unit2name,'') as actual_order_unit2name
,ifnull(actualissue.storagelocationcode,'') as storagelocationcode
,ifnull(actualissue.storagelocationname,'') as storagelocationname
, if($P{sort_order1}='movcode',mov.code
,if($P{sort_order1}='status',wip.status
,if($P{sort_order1}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order1}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order1}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order1}='materialtype' or $P{sort_order1}='materialtypecode'),mattype.name,'')))))) as sort_field1
, if($P{sort_order2}='movcode',mov.code
,if($P{sort_order2}='status',wip.status
,if($P{sort_order2}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order2}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order2}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order2}='materialtype' or $P{sort_order2}='materialtypecode'),mattype.name,'')))))) as sort_field2
from workinprocessworkinprocess as wip
left join workinprocessworkinprocessissueitem as issue on wip.id = issue.workinprocessid
left join workinprocessworkinprocessactualissueitem as actualissue on wip.id = actualissue.workinprocessid
left join workinprocesslistworkinprocesslist as wiplist on wip.workinprocesslistid= wiplist.id
left join materialmaterial as mat on issue.materialid = mat.id and actualissue.materialid = mat.id
left join materialgroupmaterialgroup as matgroup on mat.materialgroupid = matgroup.id
left join materialtypematerialtype as mattype on matgroup.materialtypeid = mattype.id
left join movementtypemovementtype as mov on wip.movementtypeid = mov.id
left join storagelocationstoragelocation storagelocation on issue.storagelocationid=storagelocation.id and actualissue.storagelocationid=storagelocation.id
where 1=1 $P!{ExternalWhereClause}