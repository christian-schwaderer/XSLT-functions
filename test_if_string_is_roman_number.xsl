<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:locfun="urn:local-functions"
    xmlns:own_t="http://no-real-uri-here/arguments_and_document_node_variables_of_Christian_Schwaderer" version="2.0">
    
        <xsl:function name="locfun:is_roman_number" as="xs:boolean">
        <!-- Tests if a given string is a Roman number -->
        
        <xsl:param name="given_string" as="xs:string"/>
        <xsl:variable name="given_string_uppercase"
            select="replace(upper-case($given_string),'E','A')"/>
        <!-- upper-case: Makes things easier. Sometimes Roman digits are printed in small letters ('Henry iv' instead of 'Henry IV'); 
        replace e with a. Later, we apply a little "math" trick. But as "e" has a meaning in numbers we get false positive results.
        Earlier versions of this functions accepted words like "mixed" as Roman numbers. That's why we have to get rid of all Es.
        -->

        <xsl:choose>
            <!-- A roman number cannot contain any arabic digit. So we test if there is an arabic digit in our string. If so: It returns false. The purpose is: Later we use actual numbers to test whether there are just letters used in roman numbers. If we accepted strings with numbers in it that could lead to false positive results -->
            <xsl:when
                test="contains($given_string, '0') or contains($given_string, '1') or contains($given_string, '2') or contains($given_string, '3') or contains($given_string, '4') or contains($given_string, '5') or contains($given_string, '6') or contains($given_string, '7') or contains($given_string, '8') or contains($given_string, '9')">
                <xsl:sequence select="false()"/>
            </xsl:when>

            <xsl:otherwise>

                <xsl:choose>
                    <xsl:when
                        test="number(translate($given_string_uppercase, 'IVXLCDM', '000000')) = 0">
                        <!-- That is a little bit of a trick: We replace all characters used in Roman numbes with 0. Then we test and sum up the result. If it is 0 then we can be sure that only I, V, X, L, C, D or M are in the tested string -->

                        <xsl:choose>
                            <xsl:when
                                test="contains($given_string_uppercase, 'VV') or contains($given_string_uppercase, 'LL') or 
                                contains($given_string_uppercase, 'DD') or contains($given_string_uppercase, 'IIIII') or contains($given_string_uppercase, 'XXXXX')
                                or contains($given_string_uppercase, 'CCCCC') or contains($given_string_uppercase, 'CCD') or contains($given_string_uppercase, 'IIV')
                                or contains($given_string_uppercase, 'XXL')">
                                <!-- We exclude some nonsense, combinations not possible in correct Roman numerals -->
                                <xsl:sequence select="false()"/>
                            </xsl:when>

                            <xsl:otherwise>
                                <!-- And now it's getting complicated. So far we can be sure that our given string consists only of letters used in Roman numerals in a combination 
                                which seems to be possible at first sight. Whether it the combination and construction of the numeral is indeed possible, is no subject to a more complex test.
                                We have to do some maths
                                -->

                                <xsl:variable name="char_into_number"
                                    select="translate($given_string_uppercase, 'IVXLCDM', '1234567')"/>
                                <!-- Each letter is replaced by an Arabic digit, making possible to sort and test greater/lesser values -->

                                <xsl:variable name="number_split" as="xs:double*">
                                    <!-- We split the string into an array -->
                                    <xsl:for-each select="string-to-codepoints($char_into_number)">
                                        <xsl:sequence select="number(codepoints-to-string(.))"/>
                                    </xsl:for-each>
                                </xsl:variable>

                                <xsl:variable name="numer_as_strings_with_separator" as="xs:string*">
                                    <!-- Now we insert | as a separator after each "change of digit value", eg. 777666333 will result in 777|666|333|-->
                                    <xsl:for-each select="$number_split">
                                        <xsl:variable name="position_of_number_before"
                                            select="position() - 1"/>
                                        <xsl:choose>
                                            <xsl:when
                                                test="$number_split[$position_of_number_before]=.">
                                                <xsl:value-of select="string(.)"/>
                                            </xsl:when>
                                            <xsl:otherwise>|<xsl:value-of select="string(.)"
                                                /></xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>|</xsl:variable>

                                <xsl:variable name="number_as_string_with_separator"
                                    select="locfun:make_string($numer_as_strings_with_separator)"/>
                                <!-- This simple function of mine turns a string sequence/array into one string
                                The code is as simple as you could think of
                                
                                <xsl:function name="locfun:make_string">
                                  <xsl:param name="input_sequence"/>
                                  <xsl:value-of select="$input_sequence"/>
                               </xsl:function>
                                
                                I use this rather often and think there should be a built in XPath function for that puropose, but as far as I know there is none 
                                
                                -->

                                <xsl:variable name="numbers_just_once" as="xs:double*">
                                    <!-- We want to have each digit just once, we need that later -->
                                    <xsl:for-each select="$number_split">
                                        <xsl:variable name="position_of_number_before"
                                            select="position() - 1"/>
                                        <xsl:if
                                            test="not(.=$number_split[$position_of_number_before])">
                                            <!-- The number processed right now must not be equal to the preceding number -->
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>

                                <xsl:variable name="numbers_just_once_sorted" as="xs:double*">
                                    <!-- We sort our array by value -->
                                    <xsl:for-each select="$numbers_just_once">
                                        <xsl:sort select="." order="descending"/>
                                        <xsl:value-of select="."/>
                                    </xsl:for-each>
                                </xsl:variable>

                                <xsl:variable name="numeral-in-groups" as="document-node()">
                                    <!-- All what we did before was just preparation for being able to build this document node variable in which we store all information we need for testing -->
                                    <xsl:document>
                                        <own_t:numeral-in-groups-root>
                                            <xsl:for-each select="$numbers_just_once">
                                                <xsl:variable name="value_processed" select="."/>
                                                <xsl:variable name="position-processed"
                                                  select="position()"/>

                                                <own_t:digit_group>
                                                  <!-- We split our (potential) Roman numeral into digit groups -->

                                                  <own_t:value>
                                                  <!-- The first child element is simple, just the numeral value (eg. from 1 to 7, representing the letters I to M) -->
                                                  <xsl:value-of select="$value_processed"/>
                                                  </own_t:value>

                                                  <own_t:how_many_digits>
                                                  <!-- This is the most complicated part of the function. We want to know of how many digits our group consists. (It could be between 1 and 4 for I, X and C and infinite for M. L and D may just appear once. But that's not the point here. We have excluded strings not machting this rule above.)-->
                                                  <xsl:variable
                                                  name="position_within_numbers_just_once"
                                                  select="index-of($numbers_just_once,$value_processed)"/>
                                                  <!-- position_within_numbers_just_once is defined as: Where is the value processed inside the (unsorted!) numeral -->

                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="$position_within_numbers_just_once[2] gt 0">
                                                  <!-- That means: A second appearance of our value exists.
                                                      So we have to do two things:
                                                      1. We have to test whether we process the first or the second occurrence right now
                                                      2. We have to calculate how many times our value occurs at either the first or the second occurrence
                                                  -->

                                                  <!-- I know it is ugly. But it seems to work
                                                      I do the following here:
                                                      I split the string into parts, using the separator | which we have inserted before and store it into variables
                                                      -->

                                                  <xsl:variable name="all_before_first"
                                                  select="substring-before($number_as_string_with_separator,string($value_processed))"/>
                                                  <xsl:variable name="just_first"
                                                  select="substring-before(substring($number_as_string_with_separator,string-length($all_before_first)),'|')"/>
                                                  <!-- Take the string $number_as_string_with_separator, go the the point where all before the first occurences ends. Go from there to the separator -->

                                                  <xsl:variable name="all-belonging-to-first"
                                                  select="concat($all_before_first, $just_first, '|')"/>

                                                  <xsl:variable name="allmost-all-before-second"
                                                  select="concat($all-belonging-to-first,substring-before(substring($number_as_string_with_separator,string-length($all-belonging-to-first)),string($value_processed)))"/>
                                                  <!-- 
                                                          
                                                          Take the string $number_as_string_with_separator, go the the point where all before the second occurences ends. Go from there to the first digit of the current value. Put that into string 
                                                      Take this together with all-belonging-to-first
                                                      -->



                                                  <xsl:variable name="just_second"
                                                  select="substring-before(substring($number_as_string_with_separator,string-length($allmost-all-before-second)),'|')"/>
                                                  <!-- Sum up the string length of all what we have done so far, go from there to the next separator. That's it. -->


                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="$position_within_numbers_just_once[1] = $position-processed">
                                                  <!-- If the first occurrence of our value is equal to the position within the for each loop we can be sure that process the first of the two occurences of our value -->
                                                  <xsl:value-of
                                                  select="string-length(replace($just_first, ' ', ''))"/>

                                                  </xsl:when>

                                                  <xsl:otherwise>
                                                  <!-- Otherwise here means: We process the second occurrence of our value -->
                                                  <xsl:value-of
                                                  select="string-length(replace($just_second, ' ', ''))"/>

                                                  </xsl:otherwise>

                                                  </xsl:choose>
                                                  </xsl:when>

                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="count($number_split[.=$value_processed])"/>
                                                  <!-- That's the easiest case. Our value appears just at one position, so we could simply count all digits equal to our value -->
                                                  </xsl:otherwise>

                                                  </xsl:choose>

                                                  <xsl:if
                                                  test="$position_within_numbers_just_once[3] gt 0"
                                                  >error</xsl:if>
                                                  <!-- That is not for building the variable but for testing. A certain value can appear just  twice inside a numeral, eg. MMCM is a correct way to express 2900, so the M appears twice, i.e. at the first position and and the third. But there is no way a value could appear three times.-->
                                                  </own_t:how_many_digits>

                                                </own_t:digit_group>
                                            </xsl:for-each>
                                        </own_t:numeral-in-groups-root>
                                    </xsl:document>
                                </xsl:variable>

                                <xsl:variable name="test_variable" as="xs:double*">
                                    <!-- And no finally: We test. We do this the following way: test_variable is an array of numerals. We start with a 0. If a "candidate" fails a test we insert 1. Afterwards we sum up: If the sum is 0 everything is fine, if it is greater than 0 our candidate has failed and is no Roman numeral  -->
                                    <xsl:for-each
                                        select="$numeral-in-groups/own_t:numeral-in-groups-root/own_t:digit_group"
                                        >0 <xsl:variable name="actual_value"
                                            select="number(own_t:value)" as="xs:double"/>
                                        <!-- These variable definitions are a little bit annoying but necessary
                                        If a value doesn't exist (e.g. because there is no preceding digit group because we process the first one) we insert 0. Otherwise some tests wouldn't work
                                        -->
                                        <xsl:variable name="preceding-value"
                                            select="if (number(preceding-sibling::own_t:digit_group[1]/own_t:value) gt 0) then number(preceding-sibling::own_t:digit_group[1]/own_t:value) else 0"
                                            as="xs:double"/>
                                        <xsl:variable name="pre-preceding-value"
                                            select="if (number(preceding-sibling::own_t:digit_group[2]/own_t:value) gt 0) then number(preceding-sibling::own_t:digit_group[2]/own_t:value) else 0"
                                            as="xs:double"/>
                                        <xsl:variable name="following-value"
                                            select="if (number(following-sibling::own_t:digit_group[1]/own_t:value) gt 0) then number(following-sibling::own_t:digit_group[1]/own_t:value) else 0"
                                            as="xs:double"/>
                                        <xsl:variable name="next-following-value"
                                            select="if (number(following-sibling::own_t:digit_group[2]/own_t:value) gt 0) then number(following-sibling::own_t:digit_group[2]/own_t:value) else 0"
                                            as="xs:double"/>
                                        <xsl:if test="$actual_value lt $following-value">
                                            <!-- This means: The digit group processed right now reduces the next value, e.g. CM and so on -->
                                            <xsl:if
                                                test="$actual_value = 2 or $actual_value = 4 or $actual_value = 6"
                                                >1</xsl:if>
                                            <!-- V, L and D are not allowed as a subtracting value -->
                                            <xsl:if test="number(own_t:how_many_digits) gt 2"
                                                >1</xsl:if>
                                            <!-- A reducing digit group normally consists of one digit. 2 is within the tolerance All above is not -->
                                            <xsl:if
                                                test="not(number(following-sibling::own_t:digit_group[1]/own_t:how_many_digits) = 1)"
                                                >1</xsl:if>
                                            <!-- The digit group beeing reduces must consist only of one digit. E.g. IXX is nonsense -->
                                            <xsl:for-each
                                                select="following-sibling::own_t:digit_group[position() gt 1]">
                                                <!-- A value may be only reduced once. Eg. XMIM is nonsense. For this purpose we check all digit groups from the next following onwards-->
                                                <xsl:if test="$following-value &lt;= number(value)"
                                                  >1</xsl:if>
                                                <!-- The value of all digit groups following the next may not be equal or greater than that the actual group reduces -->
                                            </xsl:for-each>
                                            <xsl:if test="$actual_value &lt;= $next-following-value"
                                                >1</xsl:if>
                                            <!--   The reducing digit group may not be less than or equal to that that follows the one reduces. E.g. CMC is nonsense. CMD is also nonsense -->
                                            <xsl:if
                                                test="$preceding-value gt 0 and $following-value gt $preceding-value"
                                                >1</xsl:if>
                                            <!-- If there is preceding-value it may not be greater than the following value -->
                                            <xsl:if
                                                test="$pre-preceding-value gt 0 and $following-value gt $pre-preceding-value"
                                                >1</xsl:if>
                                            <!-- If there is a pre-preceding-value it may not be greater than the following value -->
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>

                                <xsl:choose>
                                    <xsl:when test="sum($test_variable)=0">
                                        <xsl:sequence select="true()"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="false()"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:otherwise>

                        </xsl:choose>

                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>

                </xsl:choose>

            </xsl:otherwise>

        </xsl:choose>

    </xsl:function>
    
    <xsl:function name="locfun:make_string" as="xs:string">
        <xsl:param name="input_sequence"/>
        <xsl:value-of select="$input_sequence"/>
    </xsl:function>

</xsl:stylesheet>
