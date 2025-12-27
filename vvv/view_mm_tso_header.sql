CREATE OR REPLACE VIEW view_mm_tso_header AS
SELECT
    tso.id                           AS ID,
    tso.txtype                       AS TXTYPE,
    tso.txdate                       AS TXDATE,
    tso.txno                         AS TXNO,
    tso.parent_refdocno              AS PARENT_REFDOCNO,
    tso.movementtypecode             AS MOVEMENTTYPECODE,
    tso.movementtypename             AS MOVEMENTTYPENAME,
    tso.document_categorycode        AS DOCUMENT_CATEGORYCODE,
    tso.document_categoryname        AS DOCUMENT_CATEGORYNAME,
    tso.flow_refdoctype              AS FLOW_REFDOCTYPE,
    tso.flow_refdocno                AS FLOW_REFDOCNO,
    tso.refdocno                     AS REFDOCNO,
    tso.refdocdate                   AS REFDOCDATE,
    tso.status                       AS STATUS,
    tso.remark                       AS REMARK,
    tso.branchcode                   AS BRANCHCODE,
    tso.branchname                   AS BRANCHNAME,
    tso.storagelocation_tocode       AS STORAGELOCATION_TOCODE,
    tso.storagelocation_toname       AS STORAGELOCATION_TONAME,
    tso.storagelocation_fromcode     AS STORAGELOCATION_FROMCODE,
    tso.storagelocation_fromname     AS STORAGELOCATION_FROMNAME,

    emp.departmentname    						AS DEPARTMENTNAME,

    stq.txdate                       AS PARENT_REFDOCDATE,
    tso.external_refdocno            AS EXTERNAL_REFDOCNO,
    tso.external_refdocdate          AS EXTERNAL_REFDOCDATE,
    tso.createbyname                 AS CREATEBYNAME



FROM transferstocktransferstock AS tso
LEFT JOIN transferstockrequesttransferstockrequest AS stq ON tso.parent_refdocno = stq.txno
LEFT JOIN employeeemployee AS emp ON tso.createbyid = emp.id;
