select ifnull(mat.code,'') as mat_code, ifnull(mat.name,'') as mat_name
, ifnull(storage.code,'') as storage_code, ifnull(storage.name,'') as storage_name
, ifnull(stkstatus.code,'') as stockstatus_code
, ifnull(stkstatus.name,'') as stockstatus_name
, ifnull(batch.code,'') as batch_code, 
ifnull(batch.name,'') as batch_name, 
(sum.open_qty) as unit_open

, mov.txdate as txdate
, sum.processmonth as pmonth
, sum.processyear as pyear
,mov.txno as flow
,mov.txtype as flow_type

	,SUM(IF(sc.moving_type='receive',(mov.qty),0)) as unit_receive

	,SUM(IF( (sc.moving_type='receive_back' or sc.moving_type='receive_back_consign') ,(mov.qty),0)) as unit_receive_back

	,SUM(IF( (sc.moving_type='trans_in' or sc.moving_type='trans_in_consign'),(mov.qty),0)) as unit_trans_in

	,SUM(IF(  (sc.moving_type='trans_out'  or sc.moving_type='trans_out_consign'),(mov.qty*-1),0)) as unit_trans_out

	,SUM(IF( (sc.moving_type='send' or sc.moving_type='send_consign'),(mov.qty*-1),0)) as unit_send

	,SUM(IF(sc.moving_type='send_back',(mov.qty*-1),0)) as unit_send_back

,SUM(IF(sc.moving_type='adjust', (mov.qty) , 0 )) as unit_adjust

	,SUM(IF( sc.moving_type='in_produce', (mov.qty) , 0 )) as unit_product
	,SUM(IF( sc.moving_type='out_produce', (mov.qty*-1) , 0 )) as unit_withdraw_product
	,0 as open_macost_amount
	,0 as amount_receive
	,0 as amount_trans_in
	,0 as amount_trans_out
	,0 as amount_send
	,0 as amount_adjust
	,0 as amount_product
	,0 as amount_withdraw_product
	,0 as open_macost_per_unit

	,$P!{field_property_1} as p1
	,$P!{field_property_2} as p2
	,$P!{field_property_3} as p3
from poststockpoststocksummary as sum
	 left join poststockpoststockmovement as mov on sum.material = mov.material and sum.storagelocation = mov.storagelocation and sum.stockstatus = mov.stockstatus and sum.batchnumber = mov.batchnumber
	and mov.txdate>=$P{filter_todate_before} and mov.txdate<=$P{filter_todate_after} and mov.status='P'
	 left join grgr gr on gr.txno = mov.txno
	 left join gigi gi on gi.txno = mov.txno
	 left join gdgd gd on gd.txno = mov.txno
	 left join adjuststockadjuststock aj on aj.txno = mov.txno
	 left join materialmaterial as mat on sum.material=mat.id
	 left join materialgroupmaterialgroup as mgroup on mat.materialgroupid  = mgroup.id
	 left join materialtypematerialtype as mtype on mgroup.materialtypeid = mtype.id
	 left join storagelocationstoragelocation as storage on sum.storagelocation=storage.id
	 left join stockstatusstockstatus as stkstatus on sum.stockstatus=stkstatus.id
	 left join batchnumberbatchnumber as batch on sum.batchnumber=batch.id
	 left join materialmaterial_property as pp on mat.id=pp.materialid

left join serialnumberconfigserialnumberconfig sc on ( (gr.txno is not null and gr.movementtypecode=sc.movementtypecode) or (gi.txno is not null and gi.movementtypecode=sc.movementtypecode) or (gd.txno is not null and gd.movementtypecode=sc.movementtypecode) or (aj.txno is not null and aj.movementtypecode=sc.movementtypecode and sc.itemcategorycode = 'IC_036'))

where true and $P!{ExternalWhereClause}
group by   sum.material ,mov.txno, sum.storagelocation,sum.stockstatus
order by  sum.storagelocation , sum.material ,mov.txdate,sum.stockstatus, sum.processyear,sum.processmonth,mov.txno