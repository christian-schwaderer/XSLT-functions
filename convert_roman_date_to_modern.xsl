<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:locfun="urn:local-functions"
    xmlns:own_t="http://no-real-uri-here/arguments_and_document_node_variables_of_Christian_Schwaderer" version="2.0">
    
    <xsl:function name="locfun:convert_date" as="xs:string">
        <!-- This function converts Roman dates (eg. III kal. april.) into modern dates (in this case: "March 30").
            Roughly speaking, this function performs three steps:
            1. it "cleans" the input strings (lower case and some spelling cleaning)
            2. it "detects" their actual content, using large table of variants
            3. it does the actual calculation of the date:
               a. the actual starting point is calculated. For the "kalendae" it's 1, for the rest the table is consulted. In the table there are informations on what date the "nonae" and "idus" are in each month.
               b. The result date is calucated in two septs: First, we do a simple substraction: actual starting point minus input day number. Then we check: If the result of the first step is negative.
                  We go the the month preceding month, take its number of days and add them to the (negative) result of the first step.
               c. c. Then we have to check whether our result month is the input month or the preceeding month. This is quite simple: Negative first step result means: preceeding month.
               d. Finally, we check if we have a "leap year issue". If the leap year parameter is true and the result month is february and we had to calculate from the "kalendae" backwards, we have to reduce our result by 1.
               e. A string with the result is created and returned.
        -->

        <xsl:param name="input_month" as="xs:string?"/>
        <xsl:param name="input_month_part" as="xs:string?"/>
        <xsl:param name="input_day" as="xs:string?"/>
        <xsl:param name="leap_year" as="xs:boolean?"/>

        <!-- The function expects four parameters:
        1. A string indicating the month in latin. The function is quite tolerant here. See below.
        2. A string indicating the part of the month: kalendae, nonae, idus. Again much spelling variant tolerance here.
        3. A string indicating the given number of the day in Roman numerals. If your date is exactly on a fix date (eg. "kalendibus"), just write '' here
        4. A boolean for the leap year. 'true()' means 'yes, we're in a leap year'. 
        -->


        <xsl:variable name="input_month_edit"
            select="translate(lower-case($input_month),'yjv.','iiu')"/>
        <xsl:variable name="input_month_part_edit"
            select="translate(lower-case($input_month_part),'yjv.','iiu')"/>
        <xsl:variable name="input_day_edit" select="translate(lower-case($input_day),'.,#;','')"/>


        <xsl:variable name="tables">
            
       <!-- Building a large ariable for all possible values of the string parameters and additional information we need. -->
                <own_t:tables_root>

                    <own_t:month>
                        <own_t:latin_name>ianuarii</own_t:latin_name>
                        <!-- In order to create a function as tolerant as possible regarding spelling variants, we need many lines with orthographic variants. Some of them are of course mere fantasy -->
                        <own_t:latin_name>ianuari</own_t:latin_name>
                        <own_t:latin_name>ianuarias</own_t:latin_name>
                        <own_t:latin_name>ianuaras</own_t:latin_name>
                        <own_t:latin_name>ianuaros</own_t:latin_name>
                        <own_t:latin_name>ianuares</own_t:latin_name>
                        <own_t:latin_name>ianuaries</own_t:latin_name>
                        <own_t:latin_name>ianuarios</own_t:latin_name>
                        <own_t:latin_name>iannuarii</own_t:latin_name>
                        <own_t:latin_name>iannuari</own_t:latin_name>
                        <own_t:latin_name>iannuarias</own_t:latin_name>
                        <own_t:latin_name>iannuaras</own_t:latin_name>
                        <own_t:latin_name>iannuaros</own_t:latin_name>
                        <own_t:latin_name>iannuares</own_t:latin_name>
                        <own_t:latin_name>iannuaries</own_t:latin_name>
                        <own_t:latin_name>iannuarios</own_t:latin_name>
                        <own_t:latin_name>ian</own_t:latin_name>
                        <own_t:latin_name>iann</own_t:latin_name>
                        <own_t:latin_name>ianuar</own_t:latin_name>
                        <own_t:english_name>January</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>februarii</own_t:latin_name>
                        <own_t:latin_name>februari</own_t:latin_name>
                        <own_t:latin_name>februarias</own_t:latin_name>
                        <own_t:latin_name>februaras</own_t:latin_name>
                        <own_t:latin_name>februaros</own_t:latin_name>
                        <own_t:latin_name>februares</own_t:latin_name>
                        <own_t:latin_name>februaries</own_t:latin_name>
                        <own_t:latin_name>februarii</own_t:latin_name>
                        <own_t:latin_name>feuruarii</own_t:latin_name>
                        <own_t:latin_name>feuruari</own_t:latin_name>
                        <own_t:latin_name>feuruarias</own_t:latin_name>
                        <own_t:latin_name>feuruaras</own_t:latin_name>
                        <own_t:latin_name>feuruaros</own_t:latin_name>
                        <own_t:latin_name>feuruares</own_t:latin_name>
                        <own_t:latin_name>feuruaries</own_t:latin_name>
                        <own_t:latin_name>feuruarii</own_t:latin_name>
                        <own_t:latin_name>fepruarii</own_t:latin_name>
                        <own_t:latin_name>fepruari</own_t:latin_name>
                        <own_t:latin_name>fepruarias</own_t:latin_name>
                        <own_t:latin_name>fepruaras</own_t:latin_name>
                        <own_t:latin_name>fepruaros</own_t:latin_name>
                        <own_t:latin_name>fepruares</own_t:latin_name>
                        <own_t:latin_name>fepruaries</own_t:latin_name>
                        <own_t:latin_name>fepruarii</own_t:latin_name>
                        <own_t:latin_name>fibruarii</own_t:latin_name>
                        <own_t:latin_name>fibruari</own_t:latin_name>
                        <own_t:latin_name>fibruarias</own_t:latin_name>
                        <own_t:latin_name>fibruaras</own_t:latin_name>
                        <own_t:latin_name>fibruaros</own_t:latin_name>
                        <own_t:latin_name>fibruaris</own_t:latin_name>
                        <own_t:latin_name>fibruariis</own_t:latin_name>
                        <own_t:latin_name>fibruarii</own_t:latin_name>
                        <own_t:latin_name>fiuruarii</own_t:latin_name>
                        <own_t:latin_name>fiuruari</own_t:latin_name>
                        <own_t:latin_name>fiuruarias</own_t:latin_name>
                        <own_t:latin_name>fiuruaras</own_t:latin_name>
                        <own_t:latin_name>fiuruaros</own_t:latin_name>
                        <own_t:latin_name>fiuruaris</own_t:latin_name>
                        <own_t:latin_name>fiuruariis</own_t:latin_name>
                        <own_t:latin_name>fiuruarii</own_t:latin_name>
                        <own_t:latin_name>fipruarii</own_t:latin_name>
                        <own_t:latin_name>fipruari</own_t:latin_name>
                        <own_t:latin_name>fipruarias</own_t:latin_name>
                        <own_t:latin_name>fipruaras</own_t:latin_name>
                        <own_t:latin_name>fipruaros</own_t:latin_name>
                        <own_t:latin_name>fipruaris</own_t:latin_name>
                        <own_t:latin_name>fipruariis</own_t:latin_name>
                        <own_t:latin_name>fipruarii</own_t:latin_name>
                        <own_t:latin_name>fip</own_t:latin_name>
                        <own_t:latin_name>feu</own_t:latin_name>
                        <own_t:latin_name>feb</own_t:latin_name>
                        <own_t:latin_name>fib</own_t:latin_name>
                        <own_t:english_name>February</own_t:english_name>
                        <own_t:number_of_days>28</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>mar</own_t:latin_name>
                        <own_t:latin_name>martii</own_t:latin_name>
                        <own_t:latin_name>marti</own_t:latin_name>
                        <own_t:latin_name>martias</own_t:latin_name>
                        <own_t:latin_name>martios</own_t:latin_name>
                        <own_t:latin_name>marties</own_t:latin_name>
                        <own_t:latin_name>martas</own_t:latin_name>
                        <own_t:latin_name>martos</own_t:latin_name>
                        <own_t:latin_name>martes</own_t:latin_name>
                        <own_t:latin_name>mar</own_t:latin_name>
                        <own_t:latin_name>marcii</own_t:latin_name>
                        <own_t:latin_name>marci</own_t:latin_name>
                        <own_t:latin_name>marcias</own_t:latin_name>
                        <own_t:latin_name>marcios</own_t:latin_name>
                        <own_t:latin_name>marcies</own_t:latin_name>
                        <own_t:latin_name>marcas</own_t:latin_name>
                        <own_t:latin_name>marcos</own_t:latin_name>
                        <own_t:latin_name>marces</own_t:latin_name>
                        <own_t:english_name>March</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>7</own_t:position_of_nonae>
                        <own_t:position_of_idus>15</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>aprilis</own_t:latin_name>
                        <own_t:latin_name>aprelis</own_t:latin_name>
                        <own_t:latin_name>apr</own_t:latin_name>
                        <own_t:latin_name>apriles</own_t:latin_name>
                        <own_t:latin_name>apreles</own_t:latin_name>
                        <own_t:latin_name>aurilis</own_t:latin_name>
                        <own_t:latin_name>aurelis</own_t:latin_name>
                        <own_t:latin_name>aur</own_t:latin_name>
                        <own_t:latin_name>auriles</own_t:latin_name>
                        <own_t:latin_name>aureles</own_t:latin_name>
                        <own_t:english_name>April</own_t:english_name>
                        <own_t:number_of_days>30</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>madii</own_t:latin_name>
                        <own_t:latin_name>maii</own_t:latin_name>
                        <own_t:latin_name>mai</own_t:latin_name>
                        <own_t:latin_name>maias</own_t:latin_name>
                        <own_t:latin_name>maas</own_t:latin_name>
                        <own_t:latin_name>maos</own_t:latin_name>
                        <own_t:latin_name>maes</own_t:latin_name>
                        <own_t:latin_name>mais</own_t:latin_name>
                        <own_t:latin_name>maiis</own_t:latin_name>
                        <own_t:latin_name>maios</own_t:latin_name>
                        <own_t:latin_name>maies</own_t:latin_name>
                        <own_t:latin_name>madee</own_t:latin_name>
                        <own_t:latin_name>maee</own_t:latin_name>
                        <own_t:latin_name>mae</own_t:latin_name>
                        <own_t:latin_name>maeas</own_t:latin_name>
                        <own_t:latin_name>maas</own_t:latin_name>
                        <own_t:latin_name>maos</own_t:latin_name>
                        <own_t:latin_name>maes</own_t:latin_name>
                        <own_t:latin_name>maes</own_t:latin_name>
                        <own_t:latin_name>maees</own_t:latin_name>
                        <own_t:latin_name>maeos</own_t:latin_name>
                        <own_t:latin_name>maees</own_t:latin_name>
                        <own_t:latin_name>madi</own_t:latin_name>
                        <own_t:latin_name>madias</own_t:latin_name>
                        <own_t:latin_name>madas</own_t:latin_name>
                        <own_t:latin_name>mados</own_t:latin_name>
                        <own_t:latin_name>mades</own_t:latin_name>
                        <own_t:latin_name>madis</own_t:latin_name>
                        <own_t:latin_name>madiis</own_t:latin_name>
                        <own_t:latin_name>madios</own_t:latin_name>
                        <own_t:latin_name>madies</own_t:latin_name>
                        <own_t:latin_name>maddee</own_t:latin_name>
                        <own_t:latin_name>madee</own_t:latin_name>
                        <own_t:latin_name>made</own_t:latin_name>
                        <own_t:latin_name>madeas</own_t:latin_name>
                        <own_t:latin_name>madas</own_t:latin_name>
                        <own_t:latin_name>mados</own_t:latin_name>
                        <own_t:latin_name>mades</own_t:latin_name>
                        <own_t:latin_name>mades</own_t:latin_name>
                        <own_t:latin_name>madees</own_t:latin_name>
                        <own_t:latin_name>madeos</own_t:latin_name>
                        <own_t:latin_name>madees</own_t:latin_name>
                        <own_t:english_name>May</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>7</own_t:position_of_nonae>
                        <own_t:position_of_idus>15</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>iunii</own_t:latin_name>
                        <own_t:latin_name>iuni</own_t:latin_name>
                        <own_t:latin_name>iunias</own_t:latin_name>
                        <own_t:latin_name>iunios</own_t:latin_name>
                        <own_t:latin_name>iun</own_t:latin_name>
                        <own_t:latin_name>iunas</own_t:latin_name>
                        <own_t:latin_name>iunos</own_t:latin_name>
                        <own_t:latin_name>iunes</own_t:latin_name>
                        <own_t:latin_name>iunies</own_t:latin_name>
                        <own_t:latin_name>iuniis</own_t:latin_name>
                        <own_t:latin_name>iunei</own_t:latin_name>
                        <own_t:latin_name>iune</own_t:latin_name>
                        <own_t:latin_name>iuneas</own_t:latin_name>
                        <own_t:latin_name>iuneos</own_t:latin_name>
                        <own_t:latin_name>iuneas</own_t:latin_name>
                        <own_t:latin_name>iuneos</own_t:latin_name>
                        <own_t:latin_name>iunnii</own_t:latin_name>
                        <own_t:latin_name>iunni</own_t:latin_name>
                        <own_t:latin_name>iunnias</own_t:latin_name>
                        <own_t:latin_name>iunnios</own_t:latin_name>
                        <own_t:latin_name>iunn</own_t:latin_name>
                        <own_t:latin_name>innuas</own_t:latin_name>
                        <own_t:latin_name>iunnos</own_t:latin_name>
                        <own_t:latin_name>iunnes</own_t:latin_name>
                        <own_t:latin_name>iunnies</own_t:latin_name>
                        <own_t:latin_name>iunniis</own_t:latin_name>
                        <own_t:latin_name>iunnei</own_t:latin_name>
                        <own_t:latin_name>iunne</own_t:latin_name>
                        <own_t:latin_name>iunneas</own_t:latin_name>
                        <own_t:latin_name>iunneos</own_t:latin_name>
                        <own_t:latin_name>iunneas</own_t:latin_name>
                        <own_t:latin_name>iunneos</own_t:latin_name>
                        <own_t:english_name>June</own_t:english_name>
                        <own_t:number_of_days>30</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>iulii</own_t:latin_name>
                        <own_t:latin_name>iuli</own_t:latin_name>
                        <own_t:latin_name>iulias</own_t:latin_name>
                        <own_t:latin_name>iulios</own_t:latin_name>
                        <own_t:latin_name>iul</own_t:latin_name>
                        <own_t:latin_name>iluas</own_t:latin_name>
                        <own_t:latin_name>iulos</own_t:latin_name>
                        <own_t:latin_name>iules</own_t:latin_name>
                        <own_t:latin_name>iulies</own_t:latin_name>
                        <own_t:latin_name>iuliis</own_t:latin_name>
                        <own_t:latin_name>iulei</own_t:latin_name>
                        <own_t:latin_name>iule</own_t:latin_name>
                        <own_t:latin_name>iuleas</own_t:latin_name>
                        <own_t:latin_name>iuleos</own_t:latin_name>
                        <own_t:latin_name>iuleas</own_t:latin_name>
                        <own_t:latin_name>iuleos</own_t:latin_name>
                        <own_t:latin_name>iullii</own_t:latin_name>
                        <own_t:latin_name>iulli</own_t:latin_name>
                        <own_t:latin_name>iullias</own_t:latin_name>
                        <own_t:latin_name>iullios</own_t:latin_name>
                        <own_t:latin_name>iull</own_t:latin_name>
                        <own_t:latin_name>illuas</own_t:latin_name>
                        <own_t:latin_name>iullos</own_t:latin_name>
                        <own_t:latin_name>iulles</own_t:latin_name>
                        <own_t:latin_name>iullies</own_t:latin_name>
                        <own_t:latin_name>iulliis</own_t:latin_name>
                        <own_t:latin_name>iullei</own_t:latin_name>
                        <own_t:latin_name>iulle</own_t:latin_name>
                        <own_t:latin_name>iulleas</own_t:latin_name>
                        <own_t:latin_name>iulleos</own_t:latin_name>
                        <own_t:latin_name>iulleas</own_t:latin_name>
                        <own_t:latin_name>iulleos</own_t:latin_name>
                        <own_t:english_name>July</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>7</own_t:position_of_nonae>
                        <own_t:position_of_idus>15</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>aug</own_t:latin_name>
                        <own_t:latin_name>august</own_t:latin_name>
                        <own_t:latin_name>augusti</own_t:latin_name>
                        <own_t:latin_name>augustii</own_t:latin_name>
                        <own_t:latin_name>augustos</own_t:latin_name>
                        <own_t:latin_name>augustas</own_t:latin_name>
                        <own_t:latin_name>augustes</own_t:latin_name>
                        <own_t:latin_name>augustis</own_t:latin_name>
                        <own_t:latin_name>augusti</own_t:latin_name>
                        <own_t:latin_name>augostii</own_t:latin_name>
                        <own_t:latin_name>augostos</own_t:latin_name>
                        <own_t:latin_name>augostas</own_t:latin_name>
                        <own_t:latin_name>augostes</own_t:latin_name>
                        <own_t:latin_name>augostis</own_t:latin_name>
                        <own_t:english_name>August</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>septembris</own_t:latin_name>
                        <own_t:latin_name>septembress</own_t:latin_name>
                        <own_t:latin_name>septembras</own_t:latin_name>
                        <own_t:latin_name>septembros</own_t:latin_name>
                        <own_t:latin_name>sebtembris</own_t:latin_name>
                        <own_t:latin_name>sebtembress</own_t:latin_name>
                        <own_t:latin_name>sebtembras</own_t:latin_name>
                        <own_t:latin_name>sebtembros</own_t:latin_name>
                        <own_t:latin_name>seutembris</own_t:latin_name>
                        <own_t:latin_name>seutembress</own_t:latin_name>
                        <own_t:latin_name>seutembras</own_t:latin_name>
                        <own_t:latin_name>seutembros</own_t:latin_name>
                        <own_t:latin_name>septenbris</own_t:latin_name>
                        <own_t:latin_name>septenbress</own_t:latin_name>
                        <own_t:latin_name>septenbras</own_t:latin_name>
                        <own_t:latin_name>septenbros</own_t:latin_name>
                        <own_t:latin_name>sebtenbris</own_t:latin_name>
                        <own_t:latin_name>sebtenbress</own_t:latin_name>
                        <own_t:latin_name>sebtenbras</own_t:latin_name>
                        <own_t:latin_name>sebtenbros</own_t:latin_name>
                        <own_t:latin_name>seutenbris</own_t:latin_name>
                        <own_t:latin_name>seutenbress</own_t:latin_name>
                        <own_t:latin_name>seutenbras</own_t:latin_name>
                        <own_t:latin_name>seutenbros</own_t:latin_name>
                        <own_t:latin_name>septennbris</own_t:latin_name>
                        <own_t:latin_name>septennbress</own_t:latin_name>
                        <own_t:latin_name>septennbras</own_t:latin_name>
                        <own_t:latin_name>septennbros</own_t:latin_name>
                        <own_t:latin_name>sebtennbris</own_t:latin_name>
                        <own_t:latin_name>sebtennbress</own_t:latin_name>
                        <own_t:latin_name>sebtennbras</own_t:latin_name>
                        <own_t:latin_name>sebtennbros</own_t:latin_name>
                        <own_t:latin_name>seutennbris</own_t:latin_name>
                        <own_t:latin_name>seutennbress</own_t:latin_name>
                        <own_t:latin_name>seutennbras</own_t:latin_name>
                        <own_t:latin_name>seutennbros</own_t:latin_name>
                        <own_t:english_name>September</own_t:english_name>
                        <own_t:number_of_days>30</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>oct</own_t:latin_name>
                        <own_t:latin_name>octo</own_t:latin_name>
                        <own_t:latin_name>octob</own_t:latin_name>
                        <own_t:latin_name>octop</own_t:latin_name>
                        <own_t:latin_name>octobris</own_t:latin_name>
                        <own_t:latin_name>octobres</own_t:latin_name>
                        <own_t:latin_name>octobras</own_t:latin_name>
                        <own_t:latin_name>octobros</own_t:latin_name>
                        <own_t:latin_name>octubris</own_t:latin_name>
                        <own_t:latin_name>octubres</own_t:latin_name>
                        <own_t:latin_name>octubras</own_t:latin_name>
                        <own_t:latin_name>octubros</own_t:latin_name>
                        <own_t:latin_name>octopris</own_t:latin_name>
                        <own_t:latin_name>octopres</own_t:latin_name>
                        <own_t:latin_name>octopras</own_t:latin_name>
                        <own_t:latin_name>octopros</own_t:latin_name>
                        <own_t:latin_name>octupris</own_t:latin_name>
                        <own_t:latin_name>octupres</own_t:latin_name>
                        <own_t:latin_name>octupras</own_t:latin_name>
                        <own_t:latin_name>octupros</own_t:latin_name>
                        <own_t:english_name>October</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>7</own_t:position_of_nonae>
                        <own_t:position_of_idus>15</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>nouenbris</own_t:latin_name>
                        <own_t:latin_name>nouenbres</own_t:latin_name>
                        <own_t:latin_name>nouenbras</own_t:latin_name>
                        <own_t:latin_name>nouenbros</own_t:latin_name>
                        <own_t:latin_name>nouinbris</own_t:latin_name>
                        <own_t:latin_name>nouinbres</own_t:latin_name>
                        <own_t:latin_name>nouinbras</own_t:latin_name>
                        <own_t:latin_name>nouinbros</own_t:latin_name>
                        <own_t:latin_name>nobenbris</own_t:latin_name>
                        <own_t:latin_name>nobenbres</own_t:latin_name>
                        <own_t:latin_name>nobenbras</own_t:latin_name>
                        <own_t:latin_name>nobenbros</own_t:latin_name>
                        <own_t:latin_name>nobinbris</own_t:latin_name>
                        <own_t:latin_name>nobinbres</own_t:latin_name>
                        <own_t:latin_name>nobinbras</own_t:latin_name>
                        <own_t:latin_name>nobinbros</own_t:latin_name>
                        <own_t:latin_name>nouenpris</own_t:latin_name>
                        <own_t:latin_name>nouenpres</own_t:latin_name>
                        <own_t:latin_name>nouenpras</own_t:latin_name>
                        <own_t:latin_name>nouenpros</own_t:latin_name>
                        <own_t:latin_name>nouinpris</own_t:latin_name>
                        <own_t:latin_name>nouinpres</own_t:latin_name>
                        <own_t:latin_name>nouinpras</own_t:latin_name>
                        <own_t:latin_name>nouinpros</own_t:latin_name>
                        <own_t:latin_name>nopenpris</own_t:latin_name>
                        <own_t:latin_name>nopenpres</own_t:latin_name>
                        <own_t:latin_name>nopenpras</own_t:latin_name>
                        <own_t:latin_name>nopenpros</own_t:latin_name>
                        <own_t:latin_name>nopinpris</own_t:latin_name>
                        <own_t:latin_name>nopinpres</own_t:latin_name>
                        <own_t:latin_name>nopinpras</own_t:latin_name>
                        <own_t:latin_name>nopinpros</own_t:latin_name>
                        <own_t:latin_name>nou</own_t:latin_name>
                        <own_t:latin_name>nouen</own_t:latin_name>
                        <own_t:latin_name>nouenbr</own_t:latin_name>
                        <own_t:latin_name>nouenpro</own_t:latin_name>
                        <own_t:latin_name>nouembris</own_t:latin_name>
                        <own_t:latin_name>nouembres</own_t:latin_name>
                        <own_t:latin_name>nouembras</own_t:latin_name>
                        <own_t:latin_name>nouembros</own_t:latin_name>
                        <own_t:latin_name>nouimbris</own_t:latin_name>
                        <own_t:latin_name>nouimbres</own_t:latin_name>
                        <own_t:latin_name>nouimbras</own_t:latin_name>
                        <own_t:latin_name>nouimbros</own_t:latin_name>
                        <own_t:latin_name>nobembris</own_t:latin_name>
                        <own_t:latin_name>nobembres</own_t:latin_name>
                        <own_t:latin_name>nobembras</own_t:latin_name>
                        <own_t:latin_name>nobembros</own_t:latin_name>
                        <own_t:latin_name>nobimbris</own_t:latin_name>
                        <own_t:latin_name>nobimbres</own_t:latin_name>
                        <own_t:latin_name>nobimbras</own_t:latin_name>
                        <own_t:latin_name>nobimbros</own_t:latin_name>
                        <own_t:latin_name>nouempris</own_t:latin_name>
                        <own_t:latin_name>nouempres</own_t:latin_name>
                        <own_t:latin_name>nouempras</own_t:latin_name>
                        <own_t:latin_name>nouempros</own_t:latin_name>
                        <own_t:latin_name>nouimpris</own_t:latin_name>
                        <own_t:latin_name>nouimpres</own_t:latin_name>
                        <own_t:latin_name>nouimpras</own_t:latin_name>
                        <own_t:latin_name>nouimpros</own_t:latin_name>
                        <own_t:latin_name>nopempris</own_t:latin_name>
                        <own_t:latin_name>nopempres</own_t:latin_name>
                        <own_t:latin_name>nopempras</own_t:latin_name>
                        <own_t:latin_name>nopempros</own_t:latin_name>
                        <own_t:latin_name>nopimpris</own_t:latin_name>
                        <own_t:latin_name>nopimpres</own_t:latin_name>
                        <own_t:latin_name>nopimpras</own_t:latin_name>
                        <own_t:latin_name>nopimpros</own_t:latin_name>
                        <own_t:latin_name>nou</own_t:latin_name>
                        <own_t:latin_name>nouem</own_t:latin_name>
                        <own_t:latin_name>nouembr</own_t:latin_name>
                        <own_t:latin_name>nouempro</own_t:latin_name>
                        <own_t:english_name>November</own_t:english_name>
                        <own_t:number_of_days>30</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month>
                        <own_t:latin_name>decembris</own_t:latin_name>
                        <own_t:latin_name>decembres</own_t:latin_name>
                        <own_t:latin_name>decembras</own_t:latin_name>
                        <own_t:latin_name>decembros</own_t:latin_name>
                        <own_t:latin_name>decembri</own_t:latin_name>
                        <own_t:latin_name>decembr</own_t:latin_name>
                        <own_t:latin_name>decem</own_t:latin_name>
                        <own_t:latin_name>dec</own_t:latin_name>
                        <own_t:latin_name>decimbris</own_t:latin_name>
                        <own_t:latin_name>decimbres</own_t:latin_name>
                        <own_t:latin_name>decimbras</own_t:latin_name>
                        <own_t:latin_name>decimbros</own_t:latin_name>
                        <own_t:latin_name>decimbri</own_t:latin_name>
                        <own_t:latin_name>decimbr</own_t:latin_name>
                        <own_t:latin_name>decim</own_t:latin_name>
                        <own_t:latin_name>dicimbris</own_t:latin_name>
                        <own_t:latin_name>dicimbris</own_t:latin_name>
                        <own_t:latin_name>dicimbras</own_t:latin_name>
                        <own_t:latin_name>dicimbros</own_t:latin_name>
                        <own_t:latin_name>dicimbri</own_t:latin_name>
                        <own_t:latin_name>dicimbr</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:latin_name>dic</own_t:latin_name>
                        <own_t:latin_name>dicimbris</own_t:latin_name>
                        <own_t:latin_name>dicimbris</own_t:latin_name>
                        <own_t:latin_name>dicimbras</own_t:latin_name>
                        <own_t:latin_name>dicimbros</own_t:latin_name>
                        <own_t:latin_name>dicimbri</own_t:latin_name>
                        <own_t:latin_name>dicimbr</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:latin_name>decempris</own_t:latin_name>
                        <own_t:latin_name>decempres</own_t:latin_name>
                        <own_t:latin_name>decempras</own_t:latin_name>
                        <own_t:latin_name>decempros</own_t:latin_name>
                        <own_t:latin_name>decempri</own_t:latin_name>
                        <own_t:latin_name>decempr</own_t:latin_name>
                        <own_t:latin_name>decem</own_t:latin_name>
                        <own_t:latin_name>dec</own_t:latin_name>
                        <own_t:latin_name>decimpris</own_t:latin_name>
                        <own_t:latin_name>decimpres</own_t:latin_name>
                        <own_t:latin_name>decimpras</own_t:latin_name>
                        <own_t:latin_name>decimpros</own_t:latin_name>
                        <own_t:latin_name>decimpri</own_t:latin_name>
                        <own_t:latin_name>decimpr</own_t:latin_name>
                        <own_t:latin_name>decim</own_t:latin_name>
                        <own_t:latin_name>dicimpris</own_t:latin_name>
                        <own_t:latin_name>dicimpris</own_t:latin_name>
                        <own_t:latin_name>dicimpras</own_t:latin_name>
                        <own_t:latin_name>dicimpros</own_t:latin_name>
                        <own_t:latin_name>dicimpri</own_t:latin_name>
                        <own_t:latin_name>dicimpr</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:latin_name>dic</own_t:latin_name>
                        <own_t:latin_name>dicimpris</own_t:latin_name>
                        <own_t:latin_name>dicimpris</own_t:latin_name>
                        <own_t:latin_name>dicimpras</own_t:latin_name>
                        <own_t:latin_name>dicimpros</own_t:latin_name>
                        <own_t:latin_name>dicimpri</own_t:latin_name>
                        <own_t:latin_name>dicimpr</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:latin_name>decemuris</own_t:latin_name>
                        <own_t:latin_name>decemures</own_t:latin_name>
                        <own_t:latin_name>decemuras</own_t:latin_name>
                        <own_t:latin_name>decemuros</own_t:latin_name>
                        <own_t:latin_name>decemuri</own_t:latin_name>
                        <own_t:latin_name>decemur</own_t:latin_name>
                        <own_t:latin_name>decem</own_t:latin_name>
                        <own_t:latin_name>dec</own_t:latin_name>
                        <own_t:latin_name>decimuris</own_t:latin_name>
                        <own_t:latin_name>decimures</own_t:latin_name>
                        <own_t:latin_name>decimuras</own_t:latin_name>
                        <own_t:latin_name>decimuros</own_t:latin_name>
                        <own_t:latin_name>decimuri</own_t:latin_name>
                        <own_t:latin_name>decimur</own_t:latin_name>
                        <own_t:latin_name>decim</own_t:latin_name>
                        <own_t:latin_name>dicimuris</own_t:latin_name>
                        <own_t:latin_name>dicimuris</own_t:latin_name>
                        <own_t:latin_name>dicimuras</own_t:latin_name>
                        <own_t:latin_name>dicimuros</own_t:latin_name>
                        <own_t:latin_name>dicimuri</own_t:latin_name>
                        <own_t:latin_name>dicimur</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:latin_name>dic</own_t:latin_name>
                        <own_t:latin_name>dicimuris</own_t:latin_name>
                        <own_t:latin_name>dicimuris</own_t:latin_name>
                        <own_t:latin_name>dicimuras</own_t:latin_name>
                        <own_t:latin_name>dicimuros</own_t:latin_name>
                        <own_t:latin_name>dicimuri</own_t:latin_name>
                        <own_t:latin_name>dicimur</own_t:latin_name>
                        <own_t:latin_name>dicim</own_t:latin_name>
                        <own_t:english_name>December</own_t:english_name>
                        <own_t:number_of_days>31</own_t:number_of_days>
                        <own_t:position_of_nonae>5</own_t:position_of_nonae>
                        <own_t:position_of_idus>13</own_t:position_of_idus>
                    </own_t:month>

                    <own_t:month_part>
                        <own_t:name>kalendae</own_t:name>
                        <own_t:variants>kalendae</own_t:variants>
                        <own_t:variants>kalende</own_t:variants>
                        <own_t:variants>kalendibus</own_t:variants>
                        <own_t:variants>kalendis</own_t:variants>
                        <own_t:variants>kalendas</own_t:variants>
                        <own_t:variants>kalendes</own_t:variants>
                        <own_t:variants>kal</own_t:variants>
                        <own_t:variants>kalen</own_t:variants>
                        <own_t:variants>calendae</own_t:variants>
                        <own_t:variants>calende</own_t:variants>
                        <own_t:variants>calendibus</own_t:variants>
                        <own_t:variants>calendis</own_t:variants>
                        <own_t:variants>calendas</own_t:variants>
                        <own_t:variants>calendes</own_t:variants>
                        <own_t:variants>calendis</own_t:variants>
                        <own_t:variants>cal</own_t:variants>
                        <own_t:variants>calen</own_t:variants>
                        <own_t:variants>calen</own_t:variants>
                        <own_t:variants>kallendae</own_t:variants>
                        <own_t:variants>kallende</own_t:variants>
                        <own_t:variants>kallendibus</own_t:variants>
                        <own_t:variants>kallendis</own_t:variants>
                        <own_t:variants>kallendas</own_t:variants>
                        <own_t:variants>kallendes</own_t:variants>
                        <own_t:variants>kall</own_t:variants>
                        <own_t:variants>kallll</own_t:variants>
                        <own_t:variants>kallen</own_t:variants>
                        <own_t:variants>callendae</own_t:variants>
                        <own_t:variants>callende</own_t:variants>
                        <own_t:variants>callendibus</own_t:variants>
                        <own_t:variants>callendis</own_t:variants>
                        <own_t:variants>callendas</own_t:variants>
                        <own_t:variants>callendes</own_t:variants>
                        <own_t:variants>callendis</own_t:variants>
                        <own_t:variants>call</own_t:variants>
                        <own_t:variants>callll</own_t:variants>
                        <own_t:variants>callen</own_t:variants>
                        <own_t:variants>callen</own_t:variants>
                        <own_t:variants>kalenndae</own_t:variants>
                        <own_t:variants>kalennde</own_t:variants>
                        <own_t:variants>kalenndibus</own_t:variants>
                        <own_t:variants>kalenndis</own_t:variants>
                        <own_t:variants>kalenndas</own_t:variants>
                        <own_t:variants>kalenndes</own_t:variants>
                        <own_t:variants>kal</own_t:variants>
                        <own_t:variants>kalenn</own_t:variants>
                        <own_t:variants>calenndae</own_t:variants>
                        <own_t:variants>calennde</own_t:variants>
                        <own_t:variants>calenndibus</own_t:variants>
                        <own_t:variants>calenndis</own_t:variants>
                        <own_t:variants>calenndas</own_t:variants>
                        <own_t:variants>calenndes</own_t:variants>
                        <own_t:variants>calenndis</own_t:variants>
                        <own_t:variants>cal</own_t:variants>
                        <own_t:variants>calenn</own_t:variants>
                        <own_t:variants>calenn</own_t:variants>
                        <own_t:variants>kallenndae</own_t:variants>
                        <own_t:variants>kallennde</own_t:variants>
                        <own_t:variants>kallenndibus</own_t:variants>
                        <own_t:variants>kallenndis</own_t:variants>
                        <own_t:variants>kallenndas</own_t:variants>
                        <own_t:variants>kallenndes</own_t:variants>
                        <own_t:variants>kall</own_t:variants>
                        <own_t:variants>kallll</own_t:variants>
                        <own_t:variants>kallenn</own_t:variants>
                        <own_t:variants>callenndae</own_t:variants>
                        <own_t:variants>callennde</own_t:variants>
                        <own_t:variants>callenndibus</own_t:variants>
                        <own_t:variants>callenndis</own_t:variants>
                        <own_t:variants>callenndas</own_t:variants>
                        <own_t:variants>callenndes</own_t:variants>
                        <own_t:variants>callenndis</own_t:variants>
                        <own_t:variants>call</own_t:variants>
                        <own_t:variants>callll</own_t:variants>
                        <own_t:variants>callenn</own_t:variants>
                        <own_t:variants>callenn</own_t:variants>
                    </own_t:month_part>

                    <own_t:month_part>
                        <own_t:name>nonae</own_t:name>
                        <own_t:variants>nonae</own_t:variants>
                        <own_t:variants>nonas</own_t:variants>
                        <own_t:variants>nonis</own_t:variants>
                        <own_t:variants>non</own_t:variants>
                        <own_t:variants>noniae</own_t:variants>
                        <own_t:variants>none</own_t:variants>
                        <own_t:variants>nonie</own_t:variants>
                        <own_t:variants>nonus</own_t:variants>
                        <own_t:variants>nonos</own_t:variants>
                        <own_t:variants>nonius</own_t:variants>
                        <own_t:variants>nonios</own_t:variants>
                        <own_t:variants>nonnae</own_t:variants>
                        <own_t:variants>nonis</own_t:variants>
                        <own_t:variants>nonn</own_t:variants>
                        <own_t:variants>nonniae</own_t:variants>
                        <own_t:variants>nonne</own_t:variants>
                        <own_t:variants>nonnie</own_t:variants>
                        <own_t:variants>nonnus</own_t:variants>
                        <own_t:variants>nonnos</own_t:variants>
                        <own_t:variants>nonnius</own_t:variants>
                        <own_t:variants>nonnios</own_t:variants>
                    </own_t:month_part>

                    <own_t:month_part>
                        <own_t:name>idus</own_t:name>
                        <own_t:variants>idus</own_t:variants>
                        <own_t:variants>idibus</own_t:variants>
                        <own_t:variants>idos</own_t:variants>
                        <own_t:variants>iduos</own_t:variants>
                        <own_t:variants>idiis</own_t:variants>
                        <own_t:variants>idis</own_t:variants>
                        <own_t:variants>idios</own_t:variants>
                        <own_t:variants>idius</own_t:variants>
                        <own_t:variants>idies</own_t:variants>
                        <own_t:variants>ides</own_t:variants>
                        <own_t:variants>idubus</own_t:variants>
                        <own_t:variants>hidus</own_t:variants>
                        <own_t:variants>hidibus</own_t:variants>
                        <own_t:variants>hidos</own_t:variants>
                        <own_t:variants>hiduos</own_t:variants>
                        <own_t:variants>hidiis</own_t:variants>
                        <own_t:variants>hidis</own_t:variants>
                        <own_t:variants>hidios</own_t:variants>
                        <own_t:variants>hidius</own_t:variants>
                        <own_t:variants>hidies</own_t:variants>
                        <own_t:variants>hides</own_t:variants>
                        <own_t:variants>hidubus</own_t:variants>
                        <own_t:variants>hid</own_t:variants>
                        <own_t:variants>id</own_t:variants>
                        <own_t:variants>idi</own_t:variants>
                        <own_t:variants>hidi</own_t:variants>
                    </own_t:month_part>

                    <own_t:numeral>
                        <own_t:value>1</own_t:value>
                        <own_t:representation>i</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>2</own_t:value>
                        <own_t:representation>ii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>3</own_t:value>
                        <own_t:representation>iii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>4</own_t:value>
                        <own_t:representation>iv</own_t:representation>
                        <own_t:representation>iiii</own_t:representation>
                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>5</own_t:value>
                        <own_t:representation>v</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>6</own_t:value>
                        <own_t:representation>vi</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>7</own_t:value>
                        <own_t:representation>vii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>8</own_t:value>
                        <own_t:representation>viii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>9</own_t:value>
                        <own_t:representation>ix</own_t:representation>
                        <own_t:representation>viiii</own_t:representation>
                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>10</own_t:value>
                        <own_t:representation>x</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>11</own_t:value>
                        <own_t:representation>xi</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>12</own_t:value>
                        <own_t:representation>xii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>13</own_t:value>
                        <own_t:representation>xiii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>14</own_t:value>
                        <own_t:representation>xiv</own_t:representation>
                        <own_t:representation>xiiii</own_t:representation>
                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>15</own_t:value>
                        <own_t:representation>xv</own_t:representation>
                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>16</own_t:value>
                        <own_t:representation>xvi</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>17</own_t:value>
                        <own_t:representation>xvii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>18</own_t:value>
                        <own_t:representation>xviii</own_t:representation>

                    </own_t:numeral>

                    <own_t:numeral>
                        <own_t:value>19</own_t:value>
                        <own_t:representation>xviiii</own_t:representation>
                        <own_t:representation>xix</own_t:representation>
                    </own_t:numeral>

                </own_t:tables_root>
            
        </xsl:variable>

        <xsl:variable name="input_actual_month"
            select="if ($tables/own_t:tables_root/own_t:month[own_t:latin_name=$input_month_edit]/own_t:english_name) then $tables/own_t:tables_root/own_t:month[own_t:latin_name=$input_month_edit]/own_t:english_name else 'Error. Month not detected'"/>

        <xsl:variable name="input_actual_day_number"
            select="if (number($tables/own_t:tables_root/own_t:numeral[own_t:representation=$input_day_edit]/own_t:value)) then $tables/own_t:tables_root/own_t:numeral[own_t:representation=$input_day_edit]/own_t:value - 1 else 0"/>
        <!-- If we can't find the input day number in our table, that means usually we're right on a fix date: kalendis, idibus, nonis. If we find our date in the table, it is important to subtract 1, because the starting day is actually the first step of the backward calcuation. II. kal. april. means the day before the kalendae. -->

        <xsl:variable name="input_actual_month_part"
            select="if ($tables/own_t:tables_root/own_t:month_part[own_t:variants=$input_month_part_edit]/own_t:name) then $tables/own_t:tables_root/own_t:month_part[own_t:variants=$input_month_part_edit]/own_t:name else 'Error. Month part not detected.'"/>


        <xsl:variable name="actual_starting_point"
            select="if ($input_actual_month_part='kalendae') then 1 else if ($input_actual_month_part='nonae') then $tables/own_t:tables_root/own_t:month[own_t:english_name=$input_actual_month]/own_t:position_of_nonae else if ($input_actual_month_part='idus') then $tables/own_t:tables_root/own_t:month[own_t:english_name=$input_actual_month]/own_t:position_of_idus else 'error'"/>

        <xsl:variable name="month_before"
            select="if ($tables/own_t:tables_root/own_t:month[own_t:english_name=$input_actual_month]/preceding-sibling::own_t:month) then $tables/own_t:tables_root/own_t:month[own_t:english_name=$input_actual_month]/preceding-sibling::own_t:month[1]/own_t:english_name else if ($input_actual_month = 'January') then 'December' else 'Error. Month not detected'"/>
        <!-- The months are in chronological order the document node. So, no problem here. But for December we have to state manually that it is January. -->


        <xsl:variable name="result_date_first_step"
            select="number($actual_starting_point) - number($input_actual_day_number)"/>

        <xsl:variable name="result_date_second_step"
            select="if ($result_date_first_step gt 0) then $result_date_first_step else number($result_date_first_step) + number($tables/own_t:tables_root/own_t:month[own_t:english_name=$month_before]/own_t:number_of_days)"/>

        <xsl:variable name="result_month"
            select="if ($result_date_first_step gt 0) then $input_actual_month else $month_before"/>

        <xsl:variable name="leap_year_step" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$leap_year=true()">
                    <xsl:choose>
                        <xsl:when
                            test="$result_month='February' and $input_actual_month_part='kalendae'"
                            >1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>

        </xsl:variable>

        <xsl:sequence
            select="concat(string($result_month),' ',string($result_date_second_step + $leap_year_step), if($input_actual_month_part='Error. Month part not detected.') then $input_actual_month_part else '')"/>
                                                                                                        <!-- Passing through the error message. If there is no error message, then there is no need for the month part. -->
  </xsl:function>
    
</xsl:stylesheet>
