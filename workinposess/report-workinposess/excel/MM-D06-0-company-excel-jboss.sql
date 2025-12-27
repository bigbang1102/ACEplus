SELECT
  ifnull( mat.CODE, '' ) AS mat_code,
  ifnull( mat.NAME, '' ) AS mat_name,
  'companystock' AS storage_code,
  'companystock' AS storage_name,
  ifnull( stkstatus.CODE, '' ) AS stockstatus_code,
  ifnull( stkstatus.NAME, '' ) AS stockstatus_name,
  mov.txdate AS txdate,
  stu.flow_refdocno AS flow_refdocno,
  stu.flow_refdoctype AS flow_refdoctype,
  mov.txno /* -- รวมจำนวนที่ใช้ของบิลก่อนหน้า ifnull(mov_use.sum_cr, 0.00) as sum_cr, ifnull(mov_use.sum_dr, 0.00) as sum_dr, -- รวมแต่ละบิล ใช้ะไรไปเท่าไหร่ mov_stock.sumcr, mov_stock.sumdr, */
  ,
  format((
      sum.opendr - sum.opencr 
      ) + ifnull( mov_use.sum_dr, 0 ) - ifnull( mov_use.sum_cr, 0 ),
    0 
  ) AS balance_stock,
  format( mov_stock.sumdr - mov_stock.sumcr, 0 ) AS add_stock,
  format(((
        sum.opendr - sum.opencr 
        ) + ifnull( mov_use.sum_dr, 0 ) - ifnull( mov_use.sum_cr, 0 ) + ifnull( mov_stock.sumdr, 0 )) - ifnull( mov_stock.sumcr, 0 ),
    0 
  ) AS balance_qty,
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
  $P !{ field_property_3 } AS p3 
FROM
  poststockcompanypoststockcompanysummary AS sum
  LEFT JOIN poststockcompanypoststockcompanymovement AS mov ON sum.material = mov.material 
  AND sum.stockstatus = mov.stockstatus 
  AND sum.batchnumber = mov.batchnumber 
  AND sum.serialnumber = mov.serialnumber 
  AND mov.txdate >= $P { filter_todate_before } 
  AND mov.txdate <= $P { filter_todate_after }
  LEFT JOIN stockcompanyupdatestockcompanyupdate stu ON mov.txtype = stu.txtype 
  AND mov.txno = stu.txno
  LEFT JOIN grgr gr ON gr.txno = stu.parent_refdocno
  LEFT JOIN gigi gi ON gi.txno = stu.parent_refdocno
  LEFT JOIN gdgd gd ON gd.txno = stu.parent_refdocno
  LEFT JOIN adjuststockadjuststock aj ON aj.txno = stu.flow_refdocno
  LEFT JOIN materialmaterial AS mat ON sum.material = mat.id
  LEFT JOIN materialgroupmaterialgroup AS mgroup ON mat.materialgroupid = mgroup.id
  LEFT JOIN materialtypematerialtype AS mtype ON mgroup.materialtypeid = mtype.id
  LEFT JOIN stockstatusstockstatus AS stkstatus ON sum.stockstatus = stkstatus.id
  LEFT JOIN batchnumberbatchnumber AS batch ON sum.batchnumber = batch.id
  LEFT JOIN materialmaterial_property AS pp ON mat.id = pp.materialid
  LEFT JOIN serialnumberconfigserialnumberconfig sc ON ((
      gr.txno IS NOT NULL 
      AND gr.movementtypecode = sc.movementtypecode 
      ) 
    OR ( gi.txno IS NOT NULL AND gi.movementtypecode = sc.movementtypecode ) 
    OR ( gd.txno IS NOT NULL AND gd.movementtypecode = sc.movementtypecode ) 
  OR ( aj.txno IS NOT NULL AND aj.movementtypecode = sc.movementtypecode AND sc.itemcategorycode = 'IC_036' ))
  LEFT JOIN (
  SELECT
    txno,
    sum( sum_cr ) AS sum_cr,
    sum( sum_dr ) AS sum_dr,
    a.material 
  FROM
    (
    SELECT
      a.txno,
      b.txno AS b_txno,
    IF
      (
        a.txno > b.txno,
        b.mov_cr,
      IF
      ( stu.txdate > b.txdate, b.mov_cr, 0 )) AS sum_cr,
    IF
      (
        a.txno > b.txno,
        b.mov_dr,
      IF
      ( stu.txdate > b.txdate, b.mov_dr, 0 )) AS sum_dr,
      a.material 
    FROM
      poststockcompanypoststockcompanymovement a
      LEFT JOIN stockcompanyupdatestockcompanyupdate stu ON a.txtype = stu.txtype 
      AND a.txno = stu.txno
      LEFT JOIN (
      SELECT
        mov.txno,
        sum( mov.dr ) AS mov_dr,
        sum( mov.cr ) AS mov_cr,
        mov.material,
        mov.detailorderno,
        mov.processtime,
        mov.txdate,
        stu.flow_refdocno,
        stu.id 
      FROM
        poststockcompanypoststockcompanymovement mov
        LEFT JOIN stockcompanyupdatestockcompanyupdate stu ON mov.txtype = stu.txtype 
        AND mov.txno = stu.txno 
      WHERE
        mov.txdate >= $P { filter_todate_before } 
        AND mov.txdate <= $P { filter_todate_after } 
        AND mov.stockstatus <> 76700004 
      GROUP BY
        txno,
        material 
      ORDER BY
        txdate,
        txno,
        material 
        ) b ON ((
          a.txno > b.txno 
        ) 
      OR ( a.txdate > b.txdate )) 
      AND a.material = b.material 
      AND a.txdate >= b.txdate 
    WHERE
      a.txdate >= $P { filter_todate_before } 
      AND a.txdate <= $P { filter_todate_after } 
      AND stockstatus <> 76700004 
      AND b.txno IS NOT NULL 
    GROUP BY
      a.txno,
      b.txno,
      a.material 
    ORDER BY
      a.txdate,
      a.txno,
      a.processtime 
    ) AS a 
  GROUP BY
    txno,
    material 
  ) AS mov_use ON mov_use.txno = mov.txno 
  AND mov_use.material = mov.material
  LEFT JOIN (
  SELECT
    a.txno,
    sum(
    ifnull( b.cr, 0.00 )) AS sumcr,
    sum(
    ifnull( b.dr, 0.00 )) AS sumdr,
    a.material 
  FROM
    poststockcompanypoststockcompanymovement a
    LEFT JOIN (
    SELECT
      txno,
      dr,
      cr,
      material,
      processtime 
    FROM
      poststockcompanypoststockcompanymovement 
    WHERE
      txdate >= $P { filter_todate_before } 
      AND txdate <= $P { filter_todate_after } 
      AND stockstatus <> 76700004 
    GROUP BY
      txno,
      material 
    ORDER BY
      txdate,
      txno,
      processtime 
    ) b ON a.txno = b.txno 
    AND a.material = b.material 
    AND a.processtime >= b.processtime 
  WHERE
    txdate >= $P { filter_todate_before } 
    AND txdate <= $P { filter_todate_after } 
    AND stockstatus <> 76700004 
  GROUP BY
    txno,
    a.material 
  ORDER BY
    txdate,
    a.txno,
    a.processtime 
  ) AS mov_stock ON mov_stock.txno = mov.txno 
  AND mov_stock.material = mov.material 
WHERE
  TRUE $P !{ ExternalWhereClause } 
GROUP BY
  mov.txno,
  sum.material,
  sum.stockstatus,
  stu.txno 
ORDER BY
  sum.material,
  mov.txdate,
  sum.stockstatus,
  sum.processyear,
  sum.processmonth,
  mov.txno;