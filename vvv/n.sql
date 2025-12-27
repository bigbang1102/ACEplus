select wip.txno,
wip.txdate,
wip.refdocno,
'FG' as material_category
,ifnull(wip.movementtypecode,'') as movcode
,ifnull(wip.movementtypename,'') as movname,wip.status,ifnull(wiplist.name,'') as workinprocesslistname
,ifnull(wip.storagelocation_fromcode,'') as storagelocation_fromcode
,ifnull(wip.storagelocation_fromname,'') as storagelocation_fromname
,ifnull(wip.storagelocation_tocode,'') as storagelocation_tocode
,ifnull(wip.storagelocation_toname,'') as storagelocation_toname,wip.remark
,ifnull(receive.detailorderno,0) as detailorderno
,ifnull(actualreceive.detailorderno,0) as actual_detailorderno
,ifnull(mattype.code,'') as materialtypecode
,ifnull(mattype.name,'') as materialtypename
,ifnull(receive.materialcode,'') as materialcode
,ifnull(receive.materialname,'') as materialname
,ifnull(receive.quantity,0) as quantity
,ifnull(receive.order_unitcode,'') as order_unitcode
,ifnull(receive.order_unitname,'') as order_unitname
,ifnull(if(receive.cost_amount>0,receive.cost_amount/receive.quantity,0),0) as cost_per_unit
,receive.cost_amount as cost_amount
,ifnull(receive.quantity2,0) as quantity2
,ifnull(receive.order_unit2code,'') as order_unit2code
,ifnull(receive.order_unit2name,'') as order_unit2name
,ifnull(actualreceive.quantity,0) as actual_quantity
,ifnull(actualreceive.order_unitcode,'') as actual_order_unitcode
,ifnull(actualreceive.order_unitname,'') as actual_order_unitname
,ifnull(if(actualreceive.cost_amount>0,actualreceive.cost_amount/actualreceive.quantity,0),0) as actual_cost_per_unit
,actualreceive.cost_amount as actual_cost_amount
,ifnull(actualreceive.quantity2,0) as actual_quantity2
,ifnull(actualreceive.order_unit2code,'') as actual_order_unit2code
,ifnull(actualreceive.order_unit2name,'') as actual_order_unit2name
,ifnull(actualreceive.storagelocationcode,'') as storagelocationcode
,ifnull(actualreceive.storagelocationname,'') as storagelocationname
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
left join workinprocessworkinprocessreceiveitem as receive on wip.id = receive.workinprocessid
left join workinprocessworkinprocessactualreceiveitem as actualreceive on wip.id = actualreceive.workinprocessid
left join workinprocesslistworkinprocesslist as wiplist on wip.workinprocesslistid= wiplist.id
left join materialmaterial as mat on receive.materialid = mat.id and actualreceive.materialid = mat.id
left join materialgroupmaterialgroup as matgroup on mat.materialgroupid = matgroup.id
left join materialtypematerialtype as mattype on matgroup.materialtypeid = mattype.id
left join movementtypemovementtype as mov on wip.movementtypeid = mov.id
left join storagelocationstoragelocation storagelocation on receive.storagelocationid=storagelocation.id and actualreceive.storagelocationid=storagelocation.id
where 1=1 $P!{ExternalWhereClause}