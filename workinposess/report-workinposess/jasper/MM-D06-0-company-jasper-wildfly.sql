SELECT
  IFNULL( s.materialcode, '' ) AS mat_code,
  IFNULL( s.materialname, '' ) AS mat_name,
  'companystock' AS storage_code,
  'companystock' AS storage_name,
  IFNULL( s.stockstatuscode, '' ) AS stockstatus_code,
  IFNULL( s.stockstatusname, '' ) AS stockstatus_name,
  IFNULL( b.CODE, '' ) AS batch_code,
  IFNULL( b.NAME, '' ) AS batch_name,
  s.open_qty AS unit_open,
  m.txdate AS txdate,
  s.processmonth AS pmonth,
  s.processyear AS pyear,
  m.txno AS flow,
  IFNULL( m.unit_receive, 0 ) AS unit_receive,
  IFNULL( m.unit_receive_back, 0 ) AS unit_receive_back,
  IFNULL( m.unit_trans_in, 0 ) AS unit_trans_in,
  IFNULL( m.unit_trans_out, 0 ) AS unit_trans_out,
  IFNULL( m.unit_send, 0 ) AS unit_send,
  IFNULL( m.unit_send_back, 0 ) AS unit_send_back,
  IFNULL( m.unit_adjust, 0 ) AS unit_adjust,
  IFNULL( m.unit_product, 0 ) AS unit_product,
  IFNULL( m.unit_withdraw_product, 0 ) AS unit_withdraw_product,
  0 AS open_macost_amount,
  0 AS amount_receive,
  0 AS amount_trans_in,
  0 AS amount_trans_out,
  0 AS amount_send,
  0 AS amount_adjust,
  0 AS amount_product,
  0 AS amount_withdraw_product,
  0 AS open_macost_per_unit,
  $P!{field_property_1} AS p1,
  $P!{field_property_2} AS p2,
  $P!{field_property_3} AS p3
FROM
  view_mm_postcompany_summary s
  LEFT JOIN batchnumberbatchnumber b ON b.id = s.batchnumber
  LEFT JOIN view_mm_postcompany_mov_aggr_doc m ON m.material = s.material 
  AND m.stockstatus = s.stockstatus 
  AND m.batchnumber = s.batchnumber 
  AND m.txdate >= $P{filter_todate_before} 
  AND m.txdate < DATE_ADD( $P{filter_todate_after}, INTERVAL 1 DAY ) 
WHERE
TRUE 
  AND s.processyear = $P{filter_byear} 
  AND s.processmonth = $P{filter_bmonth} 
  $P!{ExternalWhereClause} 
ORDER BY
  s.materialcode,
  m.txdate,
  s.stockstatus,
  s.processyear,
  s.processmonth,
  m.txno;