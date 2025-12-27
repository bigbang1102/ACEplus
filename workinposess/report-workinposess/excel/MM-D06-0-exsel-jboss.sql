SELECT
  ifnull( mat.CODE, '' ) AS mat_code,
  ifnull( mat.NAME, '' ) AS mat_name,
  ifnull( STORAGE.CODE, '' ) AS storage_code,
  ifnull( STORAGE.NAME, '' ) AS storage_name,
  ifnull( stkstatus.CODE, '' ) AS stockstatus_code,
  ifnull( stkstatus.NAME, '' ) AS stockstatus_name,
  mov.txdate AS txdate,
  stu.flow_refdocno AS flow_refdocno,
  stu.flow_refdoctype AS flow_refdoctype,(
    sum.opendr - sum.opencr 
  ) AS unit_open,
  SUM(
  IF
  ( sc.moving_type = 'receive',( mov.dr - mov.cr ), 0 )) AS unit_receive,
  SUM(
  IF
  ( ( sc.moving_type = 'receive_back' OR sc.moving_type = 'receive_back_consign' ),( mov.dr - mov.cr ), 0 )) AS unit_receive_back,
  SUM(
  IF
  ( ( sc.moving_type = 'trans_in' OR sc.moving_type = 'trans_in_consign' ),( mov.dr - mov.cr ), 0 )) AS unit_trans_in,
  SUM(
  IF
  ( ( sc.moving_type = 'trans_out' OR sc.moving_type = 'trans_out_consign' ),( mov.cr - mov.dr ), 0 )) AS unit_trans_out,
  SUM(
  IF
  ( ( sc.moving_type = 'send' OR sc.moving_type = 'send_consign' ),( mov.cr - mov.dr ), 0 )) AS unit_send,
  SUM(
  IF
  ( sc.moving_type = 'send_back',( mov.cr - mov.dr ), 0 )) AS unit_send_back,
  SUM(
  IF
  ( sc.moving_type = 'adjust', ( mov.dr - mov.cr ), 0 )) AS unit_adjust,
  SUM(
  IF
  ( sc.moving_type = 'in_produce', ( mov.dr - mov.cr ), 0 )) AS unit_product,
  SUM(
  IF
  ( sc.moving_type = 'out_produce', ( mov.cr - mov.dr ), 0 )) AS unit_withdraw_product,
  $P !{ field_property_1 } AS p1,
  $P !{ field_property_2 } AS p2,
  $P !{ field_property_3 } AS p3,
IF
  ((
      SUM(
      IF
        ( sc.moving_type = 'receive',( mov.dr - mov.cr ), 0 ))+ SUM(
      IF
      ( ( sc.moving_type = 'receive_back' OR sc.moving_type = 'receive_back_consign' ),( mov.dr - mov.cr ), 0 )) 
      )+ SUM(
    IF
      ( ( sc.moving_type = 'trans_in' OR sc.moving_type = 'trans_in_consign' ),( mov.dr - mov.cr ), 0 ))+ SUM(
    IF
      ( sc.moving_type = 'adjust', ( mov.dr - mov.cr ), 0 ))-(
      SUM(
      IF
        ( ( sc.moving_type = 'send' OR sc.moving_type = 'send_consign' ),( mov.cr - mov.dr ), 0 ))+ SUM(
      IF
      ( sc.moving_type = 'send_back',( mov.cr - mov.dr ), 0 )))- SUM(
    IF
      ( ( sc.moving_type = 'trans_out' OR sc.moving_type = 'trans_out_consign' ),( mov.cr - mov.dr ), 0 ))+ 0.0 = 0,
    0.0,(
      SUM(
      IF
        ( sc.moving_type = 'receive',( mov.dr - mov.cr ), 0 ))+ SUM(
      IF
      ( ( sc.moving_type = 'receive_back' OR sc.moving_type = 'receive_back_consign' ),( mov.dr - mov.cr ), 0 )) 
      )+ SUM(
    IF
      ( ( sc.moving_type = 'trans_in' OR sc.moving_type = 'trans_in_consign' ),( mov.dr - mov.cr ), 0 ))+ SUM(
    IF
      ( stu.flow_refdoctype = 'AJ', ( mov.dr - mov.cr ), 0 ))-(
      SUM(
      IF
        ( ( sc.moving_type = 'send' OR sc.moving_type = 'send_consign' ),( mov.cr - mov.dr ), 0 ))+ SUM(
      IF
      ( sc.moving_type = 'send_back',( mov.cr - mov.dr ), 0 )))- SUM(
    IF
    ( ( sc.moving_type = 'trans_out' OR sc.moving_type = 'trans_out_consign' ),( mov.cr - mov.dr ), 0 ))+ 0.0 
  ) AS balance 
FROM
  poststockpoststocksummary AS sum
  LEFT JOIN poststockpoststockmovement AS mov ON sum.material = mov.material 
  AND sum.storagelocation = mov.storagelocation 
  AND sum.stockstatus = mov.stockstatus 
  AND sum.batchnumber = mov.batchnumber 
  AND sum.serialnumber = mov.serialnumber 
  AND mov.txdate >= $P { filter_todate_before } 
  AND mov.txdate <= $P { filter_todate_after }
  LEFT JOIN stockupdatestockupdate stu ON mov.txtype = stu.txtype 
  AND mov.txno = stu.txno
  LEFT JOIN grgr gr ON gr.txno = stu.parent_refdocno
  LEFT JOIN gigi gi ON gi.txno = stu.parent_refdocno
  LEFT JOIN gdgd gd ON gd.txno = stu.parent_refdocno
  LEFT JOIN adjuststockadjuststock aj ON aj.txno = stu.flow_refdocno
  LEFT JOIN materialmaterial AS mat ON sum.material = mat.id
  LEFT JOIN materialgroupmaterialgroup AS mgroup ON mat.materialgroupid = mgroup.id
  LEFT JOIN materialtypematerialtype AS mtype ON mgroup.materialtypeid = mtype.id
  LEFT JOIN storagelocationstoragelocation AS STORAGE ON sum.storagelocation = STORAGE.id
  LEFT JOIN stockstatusstockstatus AS stkstatus ON sum.stockstatus = stkstatus.id
  LEFT JOIN batchnumberbatchnumber AS batch ON sum.batchnumber = batch.id
  LEFT JOIN materialmaterial_property AS pp ON mat.id = pp.materialid
  LEFT JOIN serialnumberconfigserialnumberconfig sc ON (
    ( gr.txno IS NOT NULL AND gr.movementtypecode = sc.movementtypecode ) 
    OR ( gi.txno IS NOT NULL AND gi.movementtypecode = sc.movementtypecode ) 
    OR ( gd.txno IS NOT NULL AND gd.movementtypecode = sc.movementtypecode ) 
  OR ( aj.txno IS NOT NULL AND aj.movementtypecode = sc.movementtypecode AND sc.itemcategorycode = 'IC_036' )) 
WHERE
  TRUE $P !{ ExternalWhereClause } 
GROUP BY
  sum.material,
  sum.storagelocation,
  sum.stockstatus,
  stu.txno 
ORDER BY
  sum.storagelocation,
  sum.material,
  mov.txdate,
  sum.stockstatus,
  sum.processyear,
  sum.processmonth,
  mov.txno