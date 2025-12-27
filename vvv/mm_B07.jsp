<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% 
	String context = request.getContextPath();
	String reportType = request.getParameter("reportType")==null?"":request.getParameter("reportType");
	String txtype = request.getParameter("txtype")==null?"WIP":request.getParameter("txtype");
	String sort1 = request.getParameter("sort1")==null?"":request.getParameter("sort1");
	String sort2 = request.getParameter("sort2")==null?"":request.getParameter("sort2");
	String sort3 = request.getParameter("sort3")==null?"":request.getParameter("sort3");
	String reportType1 = "'"+reportType+"'";
	String storagestatus = "";
	String storagestatus2 =  "";

	String reportCode = request.getParameter("reportCode")==null?"MM201":request.getParameter("reportCode");
	String reportName = request.getParameter("reportName")==null?"ใบสั่งการแปรรูป":request.getParameter("reportName");
	//String filePath = "/reportdefault/report_erp_mm/workinprocess_summary/wip_summary";
	String filePath = "/reportdefault/MM/B/07/0/wip_summary";
	String exportTo = "pdf";
%>

<%
	request.getSession().setAttribute("Report_AutoCompleate_Buffer","");
%>

<%@ include file="/reporttemplate/template2/report-function-new.jsp" %>
<%@ include file="/reporttemplate/template2/report-inc.jsp" %>

<input type='hidden' name='reportsqlCode' id='reportsqlCode' value='<%=reportCode%>'>
<input type='hidden' id='method' name='method' value=''>
<input type='hidden' id='storagestatus' name='storagestatus' value=''>
<input type='hidden' id='storagestatus2' name='storagestatus2' value=''>

<jsp:include page="<%=_reportTemplateIncHeader%>"/>

<div id="header_detail" class="header_detail"></div>
		
		<div style="clear:both;height:5px;">&nbsp;</div>
		<div class="main_block">

			<div class="content_template">
				<%
					hDate = new HashMap();
					hDate.put("captionFrom","จาก วันที่");
					hDate.put("captionTo","ถึง");
					hDate.put("paramFromDate","filter_fromdate");
					hDate.put("paramToDate","filter_todate");
					hDate.put("paramname","filter_todate");
					hDate.put("sql","wip.txdate");
					alDate.add(hDate);
					request.setAttribute( "filterDate", hDate); 
				%>
				<jsp:include page="<%=templateDateFromTo%>"/>
				<%///////////END from_to_date1//////////////%>
			</div>
			
		<div class="content_template">

				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "ประเภทรายการ" );%>
				<%request.setAttribute( "caption2", "ประเภทรายการ" );%>
				<%request.setAttribute( "caption3", "ประเภทรายการ" );%>
				<%request.setAttribute( "caption4", "ประเภทรายการ" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "'WIP'" );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>

				<%request.setAttribute( "refDataName", "movementtype" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
				<%///////////END reference-data//////////////%>
			</div>


			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "ประเภทงานเอกสาร" );%>
				<%request.setAttribute( "caption2", "ประเภทรายการ" );%>
				<%request.setAttribute( "caption3", "ประเภทงานเอกสาร" );%>
				<%request.setAttribute( "caption4", "ประเภทงานเอกสาร" );%>
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "WIP" );%>
				<%//request.setAttribute( "ft2", "" );%>
				<%//request.setAttribute( "ft3", "" );%>
				<%//request.setAttribute( "ft4", "" );%>
					
				<%request.setAttribute( "reportcode", reportCode );%>

				<%request.setAttribute( "parentRefDataName1", "movementtypeparent" );%>
				<%request.setAttribute( "refDataName", "documentcategory" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>

			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "สถานะเอกสาร" );%>
				<%request.setAttribute( "caption2", "สถานะเอกสาร" );%>
				<%request.setAttribute( "caption3", "สถานะเอกสาร" );%>
				<%request.setAttribute( "caption4", "สถานะเอกสาร" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "workinprocess" );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>
					

				<%//request.setAttribute( "parentRefDataName1", "statustxtype" );%>
				<%request.setAttribute( "refDataName", "status" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>
			

			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "คลังต้นทาง" );%>
				<%request.setAttribute( "caption2", "คลัง" );%>
				<%request.setAttribute( "caption3", "คลัง" );%>
				<%request.setAttribute( "caption4", "คลัง" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", employeeCode );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>

				<%request.setAttribute( "refDataName", "storagelocation_from" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>

			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "คลังปลายทาง" );%>
				<%request.setAttribute( "caption2", "คลัง" );%>
				<%request.setAttribute( "caption3", "คลัง" );%>
				<%request.setAttribute( "caption4", "คลัง" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", employeeCode );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>

				<%request.setAttribute( "refDataName", "storagelocation_to" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>
		
			
			
			<div class="content_template">
			<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "กลุ่มสินค้า" );%>
				<%request.setAttribute( "caption2", "กลุ่มสินค้า" );%>
				<%request.setAttribute( "caption3", "กลุ่มสินค้า" );%>
				<%request.setAttribute( "caption4", "กลุ่มสินค้า" );%>
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "" );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>
				<%request.setAttribute( "reportcode", reportCode );%>
				<%request.setAttribute( "refDataName", "materialgroup" );%>
			<jsp:include page="<%=templateReferenceDataNoADV%>"/>
		<%///////////END reference-data//////////////%>
		</div>
			<div class="content_template">
			<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "สินค้า" );%>
				<%request.setAttribute( "caption2", "กลุ่มสินค้า" );%>
				<%request.setAttribute( "caption3", "สินค้า" );%>
				<%request.setAttribute( "caption4", "สินค้า" );%>
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "" );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>
				<%request.setAttribute( "reportcode", reportCode );%>
				<%request.setAttribute( "parentRefDataName1", "materialgrouptrade" );%>
				<%request.setAttribute( "refDataName", "materialtrade" );%>
			<jsp:include page="<%=templateReferenceDataADV%>"/>
		<%///////////END reference-data//////////////%>
		</div>

			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "เลขที่เอกสารอ้างอิง" );%>
				<%request.setAttribute( "caption2", "เลขที่เอกสารอ้างอิง" );%>
				<%request.setAttribute( "caption3", "เลขที่เอกสารอ้างอิง" );%>
				<%request.setAttribute( "caption4", "เลขที่เอกสารอ้างอิง" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "workinprocessworkinprocess" );%>
				<%request.setAttribute( "ft2", "WIP" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>
					

				<%//request.setAttribute( "parentRefDataName1", "statustxtype" );%>
				<%request.setAttribute( "refDataName", "refdocno" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>

			<div class="content_template">
				<%///////////reference-data///////////%>
				<%request.setAttribute( "caption1", "ประเภทสินค้า" );%>
				<%request.setAttribute( "caption2", "ประเภทสินค้า" );%>
				<%request.setAttribute( "caption3", "ประเภทสินค้า" );%>
				<%request.setAttribute( "caption4", "ประเภทสินค้า" );%>

				<%request.setAttribute( "reportcode", reportCode );%>
				
				<%request.setAttribute( "paramName", "filter_sortder" );%>
				<%request.setAttribute( "paramTableName", "propertyproperty" );%>
				<%request.setAttribute( "showcode", "N" );%>
				<%request.setAttribute( "ft1", "" );%>
				<%request.setAttribute( "ft2", "" );%>
				<%request.setAttribute( "ft3", "" );%>
				<%request.setAttribute( "ft4", "" );%>
					

				<%//request.setAttribute( "parentRefDataName1", "statustxtype" );%>
				<%request.setAttribute( "refDataName", "materialtype" );%>
				<jsp:include page="<%=templateReferenceDataNoADV%>"/>
					<%///////////END reference-data//////////////%>
			</div>
			

		ประเภทการแสดงรายงาน   
			<INPUT TYPE="radio" ID="method" NAME="method" value="all" onchange="" checked>&nbsp;&nbsp;แบบทั้งหมด
			<INPUT TYPE="radio" ID="method" NAME="method" value="total" onchange="" >&nbsp;&nbsp;แบบเฉพาะยอดรวม

			<div class="content_template">
				<%///////////from_to_date1///////////%>
				<%request.setAttribute( "caption1", "เรียงลำดับ 1" );%>
				<%request.setAttribute( "caption2", "ดูทั้งหมด" );%>
				<%request.setAttribute( "caption3", "ทั้งหมด" );%>
				<%request.setAttribute( "caption4", "ที่ต้องการดู" );%>
				<%request.setAttribute( "paramName", "sort_order1" );%>
				<%request.setAttribute( "valueList", "ประเภทรายการ,movcode|สถานะ,status|วันที่,txdate|คลังต้นทาง,from_storagelocation|คลังปลายทาง,to_storagelocation|ประเภทสินค้า,materialtypecode" );%>
				<jsp:include page="<%=templateOrderbyConstantNoADV%>"/>
				<%///////////END from_to_date1//////////////%>
			</div>

			<div class="content_template">
				<%///////////from_to_date1///////////%>
				<%request.setAttribute( "caption1", "เรียงลำดับ 2" );%>
				<%request.setAttribute( "caption2", "ดูทั้งหมด" );%>
				<%request.setAttribute( "caption3", "ทั้งหมด" );%>
				<%request.setAttribute( "caption4", "ที่ต้องการดู" );%>
				<%request.setAttribute( "paramName", "sort_order2" );%>
				<%request.setAttribute( "valueList", "วันที่,txdate|สถานะ,status|ประเภทรายการ,movcode|คลังต้นทาง,from_storagelocation|คลังปลายทาง,to_storagelocation|ประเภทสินค้า,materialtypecode" );%>
				<jsp:include page="<%=templateOrderbyConstantNoADV%>"/>
				<%///////////END from_to_date1//////////////%>
			</div>


		</div>
		
		
		<div class="report_block">
			<iframe class="report_frame" id="report_frame" name="report_frame"></iframe>
		</div>
	
</form>
</BODY>

<script>
	
function externalSQLWhere(){
		document.getElementById("externalSQLWhere").value = '';
		
		try{
			checkD = filterDate();
			if(!checkD){
				return checkD;
			}
		}catch(err){

		}
		
		var tmp =  document.getElementById("externalSQLWhere").value;
		var movement = getSelectItems_new("movementtype");
		var doctype = getSelectItems_new("documentcategory");
		var status = getSelectItems_new("status");
		var from_stock = getSelectItems_new("storagelocation_from");
		var to_stock = getSelectItems_new("storagelocation_to");	
		var material = getSelectItems_new("materialtrade");
		var materialgroup = getSelectItems_new("materialgroup");
		var refdocno = getSelectItems_new("refdocno");
		var materialtype = getSelectItems_new("materialtype");

		if(status!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.status in("+status+")" ; 
		}


		if(movement!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.movementtypeCode in("+movement+")" ; 
		}


		if(doctype!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.document_categoryCode in("+doctype+")" ; 
		}

		if(from_stock!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.storagelocation_fromcode in("+from_stock+")" ; 
		}
		
		if(to_stock!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.storagelocation_tocode in("+to_stock+")" ; 
		}

		if(material!=''){
			tmp +=(tmp==""?"":" and ")+  "receive.materialid in("+material+")" ; 
		}
		if(materialgroup!=''){
			tmp +=(tmp==""?"":" and ")+  "receive.materialgroupcode in("+materialgroup+")" ; 
		}
		if(refdocno!=''){
			tmp +=(tmp==""?"":" and ")+  "wip.refdocno in("+refdocno+")"  ; 
		}
		if(materialtype!=''){
			tmp +=(tmp==""?"":" and ")+  "receive.materialtypecode in("+materialtype+")"  ; 
		}
		
		var method = $('input:radio[name=method]:checked').val();
		document.getElementById("method").value = method;
		document.getElementById("storagestatus").value = "FG";
		document.getElementById("storagestatus2").value = "DE";

		document.getElementById("externalSQLWhere").value = tmp;
		return true;
	}
	$(function(){		
		var text_detail=document.createTextNode(filter_frame.getAttribute("detail"));
		document.getElementById("header_detail").appendChild(text_detail);
		$(".header_detail").css({"float":"left","color":"#0b82c6"});
	});

	function viewReport(mode){

		var check = externalSQLWhere();
		
		if(!check){
			return check;
		}
		
		replaceDate();

		//alert('xxxx'+document.getElementById("externalSQLWhere").value);
		
		var sort_order1 = getSelectItemsOrderby("sort_order1");
	
		var sort_order2 = getSelectItemsOrderby("sort_order2");
		var tmpOrder = sort_order1==''?'':sort_order1;
		tmpOrder  += sort_order2==''?'': (tmpOrder!=''?',':'')+sort_order2;
		tmpOrder += tmpOrder!=''?',':'';
		document.getElementById("externalSQLOrderBy").value = tmpOrder;



		if(mode == 'view'){
			$(".main_block").hide("fast");
			$(".show_filter").show("fast");
			$("#filter_btn").show();
			$("#filter_btn").attr("value","show");
			$("#filter_btn").attr("src","<%=context%>/reporttemplate/images/show_filter.gif")
			$(".report_block").height("95%");
			$(".report_block").show("slow");
			report_form.target = report_frame.name;
			report_form.submit();
		} else {
			report_form.target = "_blank";
			report_form.submit();
		}
	}

	function exportReport(){

	  var check = externalSQLWhere();
	  
	  if(!check){
	   return check;
	  }
	  
	  replaceDate();

	  document.getElementById("reportsqlCode").value = "<%=reportCode%>";
	  document.getElementById("reportName").value = "<%=reportCode%>";
	  
	   report_form.action = "<%=context%>/reportdefault/downloadexcel/download_excel_file.jsp" ;
	   report_form.target = "_blank";
	   report_form.submit();
  
 }
 function drilldownReport(){

	  var check = externalSQLWhere();
	  
	  if(!check){
	   return check;
	  }
	  
	  replaceDate();

	  document.getElementById("reportsqlCode").value = "<%=reportCode%>";
	  document.getElementById("reportName").value = "<%=reportCode%>";
	  
	   report_form.action = "<%=context%>/reporttemplate/templatedrilldown/drilldown.jsp" ;
	   report_form.target = "_blank";
	   report_form.submit();
  
 }


	function toggleFilter(){
		if($("#filter_btn").attr("value")=="show"){
			$("#filter_btn").attr("src","<%=context%>/reporttemplate/images/hide_filter.gif")
			$("#filter_btn").attr("value","hide");
		} else {
			$("#filter_btn").attr("src","<%=context%>/reporttemplate/images/show_filter.gif")
			$("#filter_btn").attr("value","show");
		}
		$(".show_filter").toggle("fast");
		$(".main_block").toggle("slow");
	}</script>
<%@ include file="/myreport/function_myreport.jsp" %>
<%@ include file="/reporttemplate/template2/report-filter-function.jsp" %>
<jsp:include page="<%=report_config_myreport_Inc%>"/>
</HTML>




