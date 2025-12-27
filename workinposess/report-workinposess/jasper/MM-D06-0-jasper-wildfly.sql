SELECT
  IFNULL(sum.materialcode,'')           AS mat_code,
  IFNULL(sum.materialname,'')           AS mat_name,
  IFNULL(sum.storagelocationcode,'')    AS storage_code,
  IFNULL(sum.storagelocationname,'')    AS storage_name,
  IFNULL(sum.stockstatuscode,'')        AS stockstatus_code,
  IFNULL(sum.stockstatusname,'')        AS stockstatus_name,
IFNULL(sum.batchcode,'') AS batch_code,
IFNULL(sum.batchname,'') AS batch_name,

  sum.open_qty                           AS unit_open,

  m.txdate                               AS txdate,
  sum.processmonth                       AS pmonth,
  sum.processyear                        AS pyear,
  m.txno                                 AS flow,


  IFNULL(m.unit_receive,0)               AS unit_receive,
  IFNULL(m.unit_receive_back,0)          AS unit_receive_back,
  IFNULL(m.unit_trans_in,0)              AS unit_trans_in,
  IFNULL(m.unit_trans_out,0)             AS unit_trans_out,
  IFNULL(m.unit_send,0)                  AS unit_send,
  IFNULL(m.unit_send_back,0)             AS unit_send_back,
  IFNULL(m.unit_adjust,0)                AS unit_adjust,
  IFNULL(m.unit_product,0)               AS unit_product,
  IFNULL(m.unit_withdraw_product,0)      AS unit_withdraw_product,

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

FROM view_mm_post_summary AS sum
LEFT JOIN view_mm_post_mov_aggr_doc AS m
  ON  m.material        = sum.material
  AND m.storagelocation = sum.storagelocation
  AND m.stockstatus     = sum.stockstatus
  AND m.batchnumber     = sum.batchnumber
  AND m.txdate >= STR_TO_DATE($P{filter_todate_before}, '%Y-%m-%d')
  AND m.txdate <= STR_TO_DATE($P{filter_todate_after},  '%Y-%m-%d')

WHERE 1=1
  AND sum.processyear  = $P{filter_byear}
  AND sum.processmonth = $P{filter_bmonth}
  AND $P!{ExternalWhereClause}

GROUP BY
  sum.material,
  sum.storagelocation,
  sum.stockstatus,
  sum.batchnumber,
  m.txno,

  m.txdate,
  sum.processyear,
  sum.processmonth

ORDER BY
  sum.storagelocation,
  sum.material,
  m.txdate,
  sum.stockstatus,
  sum.processyear,
  sum.processmonth,
  m.txno;
