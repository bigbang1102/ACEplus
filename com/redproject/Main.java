package com.redproject;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

//TIP To <b>Run</b> code, press <shortcut actionId="Run"/> or
// click the <icon src="AllIcons.Actions.Execute"/> icon in the gutter.
public class Main {

    private static void convertFile(String sourceFileName,String outputFileName,String headerText) throws Exception{
        byte[] fileData = Files.readAllBytes(Paths.get(sourceFileName));
        String strData = new String(fileData, Charset.forName("TIS-620"));

        strData = strData.replace(
                "<jsp:include page=\"<%=\"/reporttemplate/filterreport-header.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=_reportTemplateIncHeader%>\"/>"
        );

        strData = strData.replace(
                "<jsp:include page=\"<%=\"/reporttemplate/filterreport-header.jsp?reportDrilldown=_drilldown&templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=reportTemplateIncHeader%>\"/>"
        );

        strData = strData.replace(
                "<jsp:include page=\"<%=\"/myreport/config_myreport.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=report_config_myreport_Inc%>\"/>"
        );


        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-from-to.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateFromTo%>\"/>"
        );

        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/reference-data-no-adv.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateReferenceDataNoADV%>\"/>"
        );



        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/reference-data-adv.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateReferenceDataADV%>\"/>"
        );

        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/material-ref-data.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateMaterialRefData2%>\"/>"
        );


        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath+\"/material-ref-data.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateMaterialRefData%>\"/>"
        );



        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/orderby-constant-no-adv.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateOrderbyConstantNoADV%>\"/>"
        );


            //************* */ เพิ่มใหม่ ********************************

        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-from-to-select-field.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateFromToSelectField%>\"/>"
        );

        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-from-to.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateFromToNVD%>\"/>"
        );

          strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-as-of.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsOf%>\"/>"
        );

            strData = strData.replace(
                "<jsp:include page=\"<%=\"/reporttemplate/filterreport-header2.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsmidie%>\"/>"
        );

          //************* */ เพิ่มใหม่ ********************************
           strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-from-to-adv.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsdatefrom%>\"/>"
        );
                   strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath+\"/orderby-constant-no-adv.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsorderby%>\"/>"

        );
        // ***************************** เพิ่มใหม่ ******************************
            strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-from-to-special.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsspecial%>\"/>"
        );
            strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/reference-data-one-select.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsreferencespecial%>\"/>"
        );
            strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath3+\"/reference-data-property.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsproperty%>\"/>"
        );      
     
            strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-as-of-readonly.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsreadonly%>\"/>"
        );
            strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath2+\"/date-as-of-readonly.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateDateAsreadonly%>\"/>"
        );
        strData = strData.replace(
                "<jsp:include page=\"<%=reportTemplatePath+\"/period-month-year.jsp?templateCallTime=\"+System.currentTimeMillis()%>\"/>",
                "<jsp:include page=\"<%=templateMaterialRefDatalist%>\"/>"
        );


        // <jsp:include page="<%=reportTemplatePath2+"/date-from-to-special.jsp?templateCallTime="+System.currentTimeMillis()%>"/>

        File file = new File(outputFileName);

        File parentDirectory = file.getParentFile();

        if (!parentDirectory.exists()){
            parentDirectory.mkdirs();
        }

        try(
                FileOutputStream fos = new FileOutputStream(outputFileName);
                OutputStreamWriter osw = new OutputStreamWriter(fos, StandardCharsets.UTF_8);
                BufferedWriter writer = new BufferedWriter(osw)){
            if (headerText != null && !headerText.isBlank()) {
                writer.write(headerText + System.lineSeparator());
            }
            writer.write(strData);
        }catch (IOException iex){
            iex.printStackTrace();
        }
    }
    public static void main(String[] args) {

        /*String directoryPath = args[0];
        String outputPath = args[1];
        String extension = args[2];*/
        String directoryPath =  "C:\\filter_report\\PC";
        String outputPath    =  "C:\\filter_report\\OUTPUT";
        String extension     =  "jsp";


        directoryPath = directoryPath.replace("\\","/");
        outputPath = outputPath.replace("\\","/");

        String jspHeader = "<%@ page language=\"java\" contentType=\"text/html; charset=UTF-8\" pageEncoding=\"UTF-8\"%>";

        try (Stream<Path> walk = Files.walk(Paths.get(directoryPath))){

            List<String> allFiles = walk
                    .filter(Files::isRegularFile) // Filter for regular files (not directories)
                    .map(Path::toString)          // Convert Path objects to String representations
                    .toList();

            for(String fileName : allFiles){
                if (fileName.toLowerCase().endsWith("."+extension)) {
                    String outputFileName = fileName.replace("\\","/");
                    outputFileName = outputFileName.replace(directoryPath,outputPath);

                    if (extension.equalsIgnoreCase("jsp")){
                        convertFile(fileName,outputFileName,jspHeader);
                    }else{
                        convertFile(fileName,outputFileName,null);
                    }
                    System.out.println(fileName);
                    System.out.println(outputFileName);
                }
            }

        }catch (Exception ex){
            ex.printStackTrace();
        }

        /*
        String fileName = "D:/ERP/red.war/src/main/webapp/WEB-INF/jsp/util/display/upload-2.jsp";
        try {
            byte[] fileData = Files.readAllBytes(Paths.get(fileName));
            System.out.println("file size : "+fileData.length);
            String strData = new String(fileData, Charset.forName("TIS-620"));

            byte[] fileDataOutput = strData.getBytes(StandardCharsets.UTF_8);
            System.out.println("output size : "+fileDataOutput.length);

            String outputFileName = "D:/ERP/upload-2.txt";

            try(
                FileOutputStream fos = new FileOutputStream(outputFileName);
                OutputStreamWriter osw = new OutputStreamWriter(fos, StandardCharsets.UTF_8);
                BufferedWriter writer = new BufferedWriter(osw)){
                    writer.write("<%@ page language=\"java\" contentType=\"text/html; charset=UTF-8\" pageEncoding=\"UTF-8\"%>"+System.lineSeparator());
                    writer.write(strData);
            }catch (IOException iex){
                iex.printStackTrace();
            }

            File file = new File(outputFileName);

            System.out.println("File output length (bytes): " + file.length());

            //System.out.println(strData);
        }catch (Exception ex){
            ex.printStackTrace();
        }*/
    }
}