select length(a.refdocno) as length_ref,
ifnull(a.parent_refdocno,'') as parent_refdocno,
c.txdate as parent_refdocdate
,(select b.name from transferstocktransferstock as a left join employeeemployee as b on a.createbyid = b.id where a.txno = $P{txno}) as vat_businesspartner_name,
ifnull((b.departmentname),'') as departmentname
,a.txtype as txtype
,a.branchname as branchname
,a.movementtypecode as movementtypecode
,a.movementtypename as movementtypename
,a.document_categoryCode as document_categoryCode
,a.document_categoryname as document_categoryname
,a.txno as txno
,a.txdate as txdate
,a.storagelocation_fromname as storagelocation_fromname
,a.storagelocation_toname as storagelocation_toname
,a.flow_refdocno as flow_refdocno
,a.external_refdocno as external_refdocno
,a.external_refdocdate as external_refdocdate
,a.txdate as ref_txdate
,a.createbyname as name
,(select ib.status from transferstocktransferstock as ib where ib.txno = $P{txno}) as st
,(select ib.txtype from transferstocktransferstock as ib where ib.txno = $P{txno}) as tx

,(select ifnull(employee.name,'')
from transferstocktransferstock x
left join wfpiwfdilink on x.txno=wfpiwfdilink.wfditxno
left join wfpi on wfpiwfdilink.wfpiid = wfpi.id
left join wfti on wfpi.id=wfti.wfpiid and wfti.state='[COMPLETE]'
and wfti.flowid in (2,4,6,7,9,10,11,16,17)
left join users on wfti.userid=users.id
left join employeeemployee as employee on users.user_name=employee.username
where x.txno=$P{txno} order by endtime DESC limit 1 ) as approveby_1

,(select ifnull(employee.name,'')
from transferstocktransferstock x
left join wfpiwfdilink on x.txno=wfpiwfdilink.wfditxno
left join wfpi on wfpiwfdilink.wfpiid = wfpi.id
left join wfti on wfpi.id=wfti.wfpiid and wfti.state='[COMPLETE]'
and wfti.flowid in (4,7,9,10,11,16)
left join users on wfti.userid=users.id
left join employeeemployee as employee on users.user_name=employee.username
where x.txno=$P{txno} order by endtime DESC limit 1 ) as approveby_2

,length(a.movementtypename) as len_mn
,length(a.document_categoryname) as len_dn

from transferstocktransferstock as a
left join employeeemployee b on a.createbyid=b.id
left join transferstockrequesttransferstockrequest c on a.parent_refdocno = c.txno
where a.txno = $P{txno}