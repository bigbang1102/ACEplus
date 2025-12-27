SELECT * FROM 
(select 'RM' as type,
wip.txno,
wip.txdate,
wip.plan_txdate as
 plan_txdate,
 wip.refdocno
,ifnull(wip.storagelocation_fromcode,'') as storagelocation_fromcode,ifnull(wip.storagelocation_tocode,'') as storagelocation_tocode
,ifnull(mattype.code,'') as plan_materialtypecode,
ifnull(mattype.name,'') as plan_materialtypename
,ifnull(issue.materialcode,'') as plan_materialcode
,ifnull(issue.materialname,'') as plan_materialname
,ifnull(issue.quantity,0) as plan_qty,
ifnull(actualissue.quantity,0) as actual_qty
,ifnull(if(actualissue.cost_amount>0,actualissue.cost_amount/actualissue.quantity,0),0) as actual_cost_per_unit
,actualissue.cost_amount as actual_cost_amount
, '' as fg_percent, 0 as fg_count
,wip.external_refdocno as std_time
,'' as fg_txdate, 0 as over_due
, if($P{sort_order1}='movcode',wip.MOVEMENTTYPECODE
,if($P{sort_order1}='status',wip.status
,if($P{sort_order1}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order1}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order1}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order1}='materialtype' or $P{sort_order1}='materialtypecode'),mattype.name,'')))))) as sort_field1
, if($P{sort_order2}='movcode',wip.MOVEMENTTYPECODE
,if($P{sort_order2}='status',wip.status
,if($P{sort_order2}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order2}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order2}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order2}='materialtype' or $P{sort_order2}='materialtypecode'),mattype.name,'')))))) as sort_field2
from workinprocessworkinprocess as wip left join workinprocessworkinprocessissueitem as issue on wip.id = issue.workinprocessid left join workinprocessworkinprocessactualissueitem as actualissue on wip.id = actualissue.workinprocessid
left join materialmaterial as mat on issue.materialid = mat.id and actualissue.materialid = mat.id left join materialgroupmaterialgroup as matgroup on mat.materialgroupid = matgroup.id left join materialtypematerialtype as mattype on matgroup.materialtypeid = mattype.id
where 1=1 $P!{ExternalWhereClause} and mattype.code<>''

union all

select 'FG' as type,wip.txno,wip.txdate,'' as plan_txdate,wip.refdocno
,gr.STORAGELOCATIONCODE as fg_storagelocationcode, '' as storagelocation_tocode
,'' as plan_materialtypecode,'' as plan_materialtypename
,receive.MATERIALCODE as fg_materialcode,receive.MATERIALNAME as fg_materialname
,receive.QUANTITY as fg_plan_qty , actualreceive.QUANTITY as fg_actual_qty
,0 as actual_cost_per_unit
,actualreceive.cost_amount as fg_cost
, ifnull(ROUND((actualreceive.QUANTITY/receive.QUANTITY)*100,2),0.00) as fg_percent
,CONCAT(ROUND(actualreceive.DETAILORDERNO/100,0),'/',c_gr35.c_gr35) as fg_count
,wip.external_refdocno as std_time
,gr.txdate as fg_txdate
, IF((DATEDIFF(gr.txdate,ADDDATE(wip.plan_txdate, CAST(wip.external_refdocno AS UNSIGNED))))<0,0,(DATEDIFF(gr.txdate,ADDDATE(wip.plan_txdate, CAST(wip.external_refdocno AS UNSIGNED))))) as over_due
, if($P{sort_order1}='movcode',wip.MOVEMENTTYPECODE
,if($P{sort_order1}='status',wip.status
,if($P{sort_order1}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order1}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order1}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order1}='materialtype' or $P{sort_order1}='materialtypecode'),mattype.name,'')))))) as sort_field1
, if($P{sort_order2}='movcode',wip.MOVEMENTTYPECODE
,if($P{sort_order2}='status',wip.status
,if($P{sort_order2}='txdate',DATE_FORMAT(wip.txdate,'%Y-%m-%d')
,if(($P{sort_order2}='from_storagelocation'),wip.storagelocation_fromname
,if(($P{sort_order2}='to_storagelocation'),wip.storagelocation_toname
,if(($P{sort_order2}='materialtype' or $P{sort_order2}='materialtypecode'),mattype.name,'')))))) as sort_field2
from workinprocessworkinprocess as wip
left join workinprocessworkinprocessreceiveitem as receive on wip.id = receive.workinprocessid
left join workinprocessworkinprocessactualreceiveitem as actualreceive on wip.id = actualreceive.workinprocessid
left join grgr gr on gr.txno=actualreceive.FLOW_REFDOCNO
left join (select a.id ,count(a.txno) as c_gr35 from workinprocessworkinprocess a INNER JOIN grgr b on a.txno=b.FLOW_REFDOCNO where b.MOVEMENTTYPECODE='GR-35' and a.txno='WIP2:M01-2112-00020' GROUP BY a.txno) as c_gr35 on c_gr35.id=wip.id
left join materialmaterial as mat on receive.MATERIALID = mat.id and actualreceive.MATERIALID = mat.id
left join materialgroupmaterialgroup as matgroup on mat.MATERIALGROUPID = matgroup.id
left join materialtypematerialtype as mattype on matgroup.materialtypeid = mattype.id
where 1=1 $P!{ExternalWhereClause} ) as b
ORDER BY b.sort_field1,b.sort_field2,b.txno ASC,b.type DESC,b.fg_count