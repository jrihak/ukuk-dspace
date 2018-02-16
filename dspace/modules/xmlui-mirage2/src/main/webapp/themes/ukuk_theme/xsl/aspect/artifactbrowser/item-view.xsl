<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

	<!-- <JR> - 15. 9. 2017 - calling new template for CitacePro -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim" mode="itemSummaryView-DIM-citacepro"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <xsl:call-template name="itemSummaryView-DIM-work-type"/>
            <div class="row">
                <div class="col-sm-12">
                    <div class="row">
                        <div class="col-xs-12 col-sm-5">
                            <!--<xsl:call-template name="itemSummaryView-DIM-date"/>-->
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                            <xsl:call-template name="itemSummaryView-DIM-URI"/>
                            <xsl:call-template name="itemSummaryView-collections"/>
                        </div>
                        <div class="col-xs-12 col-sm-7">
                            <xsl:call-template name="itemSummaryView-DIM-authors"/>
                            <xsl:call-template name="itemSummaryView-DIM-advisors"/>
                            <xsl:call-template name="itemSummaryView-DIM-referees"/>
                            <xsl:call-template name="itemSummaryView-DIM-affiliation"/>
                            <xsl:call-template name="itemSummaryView-DIM-faculty"/>
                            <xsl:call-template name="itemSummaryView-DIM-discipline"/>
                            <xsl:call-template name="itemSummaryView-DIM-department"/>
                            <xsl:call-template name="itemSummaryView-DIM-acceptance-date"/>
                            <xsl:call-template name="itemSummaryView-DIM-work-language"/>
                            <xsl:call-template name="itemSummaryView-DIM-grade"/>
                            <xsl:call-template name="itemSummaryView-DIM-keywords-cs"/>
                            <xsl:call-template name="itemSummaryView-DIM-keywords-en"/>
                        </div>
                        <div class="col-xs-12 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-abstract-cs"/>
                            <xsl:call-template name="itemSummaryView-DIM-abstract-en"/>
                            <xsl:call-template name="itemSummaryView-DIM-abstract-original"/>
                            <!--<xsl:call-template name="itemSummaryView-DIM-thumbnail"/>-->
                        </div>
                        <!--<div class="col-xs-6 col-sm-12">-->
                            <!--<xsl:call-template name="itemSummaryView-DIM-file-section"/>-->
                        <!--</div>-->
                    </div>
                    <!--<xsl:call-template name="itemSummaryView-DIM-date"/>-->
                    <!--<xsl:call-template name="itemSummaryView-DIM-authors"/>-->
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
                <!--<div class="col-sm-8">-->
                    <!--<xsl:call-template name="itemSummaryView-DIM-abstract"/>-->
                    <!--<xsl:call-template name="itemSummaryView-DIM-URI"/>-->
                    <!--<xsl:call-template name="itemSummaryView-collections"/>-->
                <!--</div>-->
            </div>
        </div>
    </xsl:template>

	<!-- <JR> - 15. 9. 2017 - new template for CitacePRO -->
        <xsl:template match="dim:dim" mode="itemSummaryView-DIM-citacepro">
                <xsl:variable name="urlPrefix">
                        <xsl:text>https://www.citacepro.com/api/dspaceuk/citace/oai:dspace.cuni.cz:</xsl:text>
                </xsl:variable>

                <h4 class="item-view-heading">
                        <xsl:text>Citace dokumentu</xsl:text>
                </h4>
                <div id="ds-search-option" class="ds-option-set">
                        <embed style="width:100%;height:230px">
                                <xsl:attribute name="src">
                                        <xsl:call-template name="itemSummaryView-DIM-citaceURL">
                                                <xsl:with-param name="prefix" select="$urlPrefix" />
                                        </xsl:call-template>
                                </xsl:attribute>
                        </embed>
                </div>
        </xsl:template>

        <xsl:template name="itemSummaryView-DIM-citaceURL">
                <xsl:param name="prefix" />
                <xsl:variable name="urlPref">
                        <xsl:value-of select="$prefix" />
                </xsl:variable>
                <xsl:variable name="handleId">
                        <xsl:value-of select="$document//dri:meta/dri:pageMeta/dri:metadata[@element='identifier'][@qualifier='handle']"/>
                </xsl:variable>
                <xsl:value-of select="concat($urlPref,$handleId)"/>
        </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header item-view-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                    <xsl:call-template name="itemSummaryView-DIM-title-translated"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header item-view-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                    <xsl:call-template name="itemSummaryView-DIM-title-translated"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title-translated">
        <xsl:if test="dim:field[@element='title' and @qualifier='translated']">
            <h5 class="item-view-heading-secondary">
                <xsl:value-of select="dim:field[@element='title' and @qualifier='translated']"/>
            </h5>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <img alt="Thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$src"/>
                        </xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!--9.5.2017 <AM> doplněn český abstrakt uk.abstract.cs -->
     <xsl:template name="itemSummaryView-DIM-abstract-cs">
        <xsl:if test="dim:field[@element='abstract' and @qualifier='cs']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <div role="tab" id="panel-abstract-cs">
                    <h4 class="item-view-heading">
                        <a role="button" data-toggle="collapse" href="#abstract-cs-collapse" aria-expanded="false" aria-labelledby="abstract-cs-collapse">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract-item-view-cs</i18n:text>
                            <span class="glyphicon glyphicon-collapse-down pull-right"></span>
                        </a>
                    </h4>
                </div>

                <div id="abstract-cs-collapse" class="panel-collapse collapse out" role="tabpanel" aria-labelledby="panel-abstract-cs">
                    <div>
                        <xsl:for-each select="dim:field[@element='abstract' and @qualifier='cs']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:if test="count(dim:field[@element='abstract' and @qualifier='cs']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!--9.5.2017 <AM> doplněn anglický abstrakt uk.abstract.en -->
     <xsl:template name="itemSummaryView-DIM-abstract-en">
        <xsl:if test="dim:field[@element='abstract' and @qualifier='en']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <div role="tab" id="panel-abstract-en">
                    <h4 class="item-view-heading">
                        <a role="button" data-toggle="collapse" href="#abstract-en-collapse" aria-expanded="false" aria-labelledby="abstract-en-collapse">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract-item-view-en</i18n:text>
                            <span class="glyphicon glyphicon-collapse-down pull-right"></span>
                        </a>
                    </h4>
                </div>

                <div id="abstract-en-collapse" class="panel-collapse collapse out" role="tabpanel" aria-labelledby="panel-abstract-en">
                    <div>
                        <xsl:for-each select="dim:field[@element='abstract' and @qualifier='en']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='abstract' and @qualifier='en']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:if test="count(dim:field[@element='abstract' and @qualifier='en']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!--9.5.2017 <AM> doplněn abstrakt v průvodním jazyce dokumentu - uk.abstract.original -->
     <xsl:template name="itemSummaryView-DIM-abstract-original">
        <xsl:if test="dim:field[@element='abstract' and @qualifier='original']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <div role="tab" id="panel-abstract-original">
                    <h4 class="item-view-heading">
                        <a role="button" data-toggle="collapse" href="#abstract-original-collapse" aria-expanded="false" aria-labelledby="abstract-original-collapse">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract-item-view-original</i18n:text>
                            <span class="glyphicon glyphicon-collapse-down pull-right"></span>
                        </a>
                    </h4>
                </div>

                <div id="abstract-original-collapse" class="panel-collapse collapse out" role="tabpanel" aria-labelledby="panel-abstract-original">
                    <div>
                        <xsl:for-each select="dim:field[@element='abstract' and @qualifier='original']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='abstract' and @qualifier='original']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:if test="count(dim:field[@element='abstract' and @qualifier='original']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


 <!-- <xsl:template name="itemSummaryView-DIM-abstract-cs">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract' and @language='cs_CZ']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <div role="tab" id="panel-abstract-cs">
                    <h4 class="item-view-heading">
                        <a role="button" data-toggle="collapse" href="#abstract-cs-collapse" aria-expanded="false" aria-labelledby="abstract-cs-collapse">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract-item-view-cs</i18n:text>
                            <span class="glyphicon glyphicon-collapse-down pull-right"></span>
                        </a>
                    </h4>
                </div>

                <div id="abstract-cs-collapse" class="panel-collapse collapse out" role="tabpanel" aria-labelledby="panel-abstract-cs">
                    <div>
                        <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract' and @language='cs_CZ']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template> -->

  <!-- <xsl:template name="itemSummaryView-DIM-abstract-en">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract' and @language='en_US']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <div role="tab" id="panel-abstract-en">
                    <h4 class="item-view-heading">
                        <a role="button" data-toggle="collapse" href="#abstract-en-collapse" aria-expanded="false" aria-labelledby="abstract-en-collapse">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract-item-view-en</i18n:text>
                            <span class="glyphicon glyphicon-collapse-down pull-right"></span>
                        </a>
                    </h4>
                </div>

                <div id="abstract-en-collapse" class="panel-collapse collapse out" role="tabpanel" aria-labelledby="panel-abstract-en">
                    <div>
                        <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract' and @language='en_US']">
                            <xsl:choose>
                                <xsl:when test="node()">
                                    <xsl:copy-of select="node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                                <div class="spacer">&#160;</div>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template> -->

    <!-- <JR> - 20. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-faculty">
	<xsl:if test="dim:field[@element='faculty-name' and @qualifier='cs']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-faculty-item-view</i18n:text></h4>
		<xsl:choose>
			<xsl:when test="$active-locale='en'">
			<xsl:choose>
				<xsl:when test="dim:field[@element='description' and @qualifier='faculty' and language='en']">
					<div>
						<xsl:value-of select="dim:field[@element='faculty-name' and @qualifier='en']"/>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div>
						<xsl:value-of select="dim:field[@element='faculty-name' and @qualifier='cs']"/>
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$active-locale='cs'">
			<div>
				<xsl:value-of select="dim:field[@element='faculty-name' and @qualifier='cs']"/>
			</div>
		</xsl:when>
		</xsl:choose>
            </div>
    	</xsl:if>
	<!-- <JR> - 16. 2. 2017 -->
	<!-- Removed duplicate display of faculty name from item-view -->	
	<!--<xsl:if test="dim:field[@element='description' and @qualifier='faculty']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-faculty-item-view</i18n:text></h4>
                <div>
                    <xsl:value-of select="dim:field[@element='description' and @qualifier='faculty']"/>
                    <xsl:if test="dim:field[@element='description' and @qualifier='faculty' and language='en']">
                        <xsl:text> / </xsl:text><xsl:value-of select="dim:field[@element='description' and @qualifier='faculty' and @language='en']"/>
                    </xsl:if>
                </div>
            </div>
	</xsl:if>-->
    </xsl:template>

   <!-- <AM> - 18. 4. 2017
    <xsl:template name="itemSummaryView-DIM-discipline">
      <xsl:if test="dim:field[@element='degree' and @qualifier='discipline']">
        <div class="simple-item-view-description item-page-field-wrapper table">
           <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-discipline-item-view</i18n:text></h4>
                <div>
                    <xsl:value-of select="dim:field[@element='degree' and @qualifier='discipline']"/>
                    <xsl:if test="dim:field[@element='degree' and @qualifier='discipline' and @language='en']">
                        <xsl:text> / </xsl:text><xsl:value-of select="dim:field[@element='degree' and @qualifier='discipline' and @language='en']"/>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template> -->

   <!-- <AM> - 5. 5. 2017 -->
     <xsl:template name="itemSummaryView-DIM-discipline">
        <xsl:if test="dim:field[@element='degree' and @qualifier='discipline']">
           <div class="simple-item-view-description item-page-field-wrapper table">
                <xsl:choose>
                    <xsl:when test="$active-locale='en' and dim:field[@element='degree' and @qualifier='discipline' and (@language='en_US' or @language='en')]">
                        <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-discipline-item-view</i18n:text></h4>
                        <div><xsl:value-of select="dim:field[@element='degree' and @qualifier='discipline' and (@language='en_US' or @language='en')]"/></div>
                    </xsl:when>
                    <xsl:when test="$active-locale='cs' and dim:field[@element='degree' and @qualifier='discipline' and (@language='cs_CZ' or @language='cs')]">
                        <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-discipline-item-view</i18n:text></h4>
                        <div><xsl:value-of select="dim:field[@element='degree' and @qualifier='discipline' and (@language='cs_CZ' or @language='cs')]"/></div>
                    </xsl:when>
                </xsl:choose>
             </div>
        </xsl:if>
    </xsl:template>

  <!-- <AM> - 18. 4. 2017 -->
    <xsl:template name="itemSummaryView-DIM-affiliation">
      <xsl:if test="dim:field[@element='author' and @qualifier='affiliation']">
        <div class="simple-item-view-description item-page-field-wrapper table">
           <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-affiliation-item-view</i18n:text></h4>
                <div>
                    <xsl:value-of select="dim:field[@element='author' and @qualifier='affiliation']"/>
                    <xsl:if test="dim:field[@element='author' and @qualifier='affiliation' and @language='en']">
                        <xsl:text> / </xsl:text><xsl:value-of select="dim:field[@element='author' and @qualifier='affiliation' and @language='en']"/>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 20. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-department">
        <xsl:if test="dim:field[@element='description' and @qualifier='department' and @language='cs_CZ']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-department-item-view</i18n:text></h4>
                <div>
                    <xsl:value-of select="dim:field[@element='description' and @qualifier='department' and @language='cs_CZ']"/>
                    <xsl:if test="dim:field[@element='description' and @qualifier='department' and @language='en_US']">
                        <xsl:text> / </xsl:text><xsl:value-of select="dim:field[@element='description' and @qualifier='department' and @language='en_US']"/>
                    </xsl:if>

                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 22. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-grade">
        <xsl:if test="dim:field[@element='grade' and @qualifier='cs']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-grade-item-view</i18n:text></h4>
                <div>
                    <xsl:value-of select="dim:field[@element='grade' and @qualifier='cs']"/>
                    <xsl:if test="dim:field[@element='grade' and @qualifier='en']">
                        <xsl:text> / </xsl:text><xsl:value-of select="dim:field[@element='grade' and @qualifier='en']"/>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 20. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-work-type">
        <xsl:if test="dim:field[@element='type'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <!--<h4><i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-item-view</i18n:text></h4>-->
                <div>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='type']/text()='bakalářská práce'">
                            <h4>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-bachelor-th-item-view</i18n:text>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='type']/text()='diplomová práce'">
                            <h4>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-diploma-th-item-view</i18n:text>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>

                        </xsl:when>
                        <xsl:when test="dim:field[@element='type']/text()='dizertační práce'">
                            <h4>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-disert-th-item-view</i18n:text>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='type']/text()='rigorózní práce'">
                            <h4>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-rigo-th-item-view</i18n:text>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='type']/text()='habilitační práce'">
                            <h4>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-type-habi-th-item-view</i18n:text>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>
                        </xsl:when>
                        <xsl:otherwise>
                            <h4>
                                <xsl:value-of select="dim:field[@element='type']"/>
                                <!--<xsl:text> [</xsl:text><xsl:call-template name="itemSummaryView-DIM-defense-status"/><xsl:text>]</xsl:text>-->
                                <xsl:call-template name="itemSummaryView-DIM-defense-status"/>
                            </h4>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 22. 2. 2017 -->
       <xsl:template name="itemSummaryView-DIM-work-language">
        <xsl:choose>        
         <xsl:when test="dim:field[@element='language' and @qualifier='iso']">
           <div class="simple-item-view-description item-page-field-wrapper table">
              <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-item-view</i18n:text></h4>
                <div>
                    <xsl:choose>
                        <xsl:when test="node()/text()='cs_CZ'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-cs-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='en_US'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-en-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='de_DE'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-de-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='sk_SK'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sk-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='fr_FR'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-fr-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='ru_RU'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-ru-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='it_IT'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-it-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='es_ES'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-es-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='pt_PT'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-pt-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='nl_NL'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-nl-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='pl_PL'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-pl-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='no_NO'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-no-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='sv_SE'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sv-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='hu_HU'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-hu-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='sr_SP'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sr-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='ro_RO'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-ro-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='lt_LT'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-lt-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='sh_RS'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sh-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='da_DK'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-da-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='bg_BG'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-bg-item-view</i18n:text>
                        </xsl:when>
                            <xsl:when test="node()/text()='sl_SL'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sl-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="node()/text()='uk_UA'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-uk-item-view</i18n:text>
                        </xsl:when>
                    </xsl:choose>
                </div>
             </div>
        </xsl:when>
        <xsl:otherwise>
        <!-- <xsl:otherwise test="dim:field[@element='language' and not(@qualifier)]" -->
           <div class="simple-item-view-description item-page-field-wrapper table">
              <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-item-view</i18n:text></h4>
                <div>
                    <xsl:choose>
                       <xsl:when test="dim:field[@element='language']/text()='Čeština' or dim:field[@element='language']/text()='Czech'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-cs-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Angličtina' or dim:field[@element='language']/text()='English'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-en-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Němčina' or dim:field[@element='language']/text()='German'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-de-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Ruština' or dim:field[@element='language']/text()='Russian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-ru-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Francouzština' or dim:field[@element='language']/text()='French'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-fr-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Španělština' or dim:field[@element='language']/text()='Spanish'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-es-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Portugalština' or dim:field[@element='language']/text()='Portuguese'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-pt-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Polština' or dim:field[@element='language']/text()='Polish'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-pl-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Norština' or dim:field[@element='language']/text()='Norwegian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-no-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Švédština' or dim:field[@element='language']/text()='Swedish'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sv-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Maďarština' or dim:field[@element='language']/text()='Hungarian'">
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-hu-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Srbština' or dim:field[@element='language']/text()='Serbian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sr-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Rumunština' or dim:field[@element='language']/text()='Romanian'">
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-ro-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Litevština' or dim:field[@element='language']/text()='Lithuanian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-lt-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Srbochorvatština' or dim:field[@element='language']/text()='Serbo-Croatian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sh-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Dánština' or dim:field[@element='language']/text()='Danish'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-da-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Bulharština' or dim:field[@element='language']/text()='Bulgarian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-bg-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Slovinština' or dim:field[@element='language']/text()='Slovenian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-sl-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Ukrajinština' or dim:field[@element='language']/text()='Ukrainian'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-uk-item-view</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='language']/text()='Jiný' or dim:field[@element='language']/text()='Other'">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-00-item-view</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-work-language-00-item-view</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
             </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- <JR> - 22. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-defense-status">
        <xsl:if test="dim:field[@element='grade' and @qualifier='cs']">
            <xsl:if test="dim:field[@element='grade' and @qualifier='cs']">
                <xsl:choose>
                    <xsl:when test="node()/text()='Výtečně'">
                        <xsl:text> [</xsl:text><span class="text-theses-defended"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:when test="node()/text()='Výborně'">
                        <xsl:text> [</xsl:text><span class="text-theses-defended"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:when test="node()/text()='Velmi dobře'">
                        <xsl:text> [</xsl:text><span class="text-theses-defended"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:when test="node()/text()='Dobře'">
                        <xsl:text> [</xsl:text><span class="text-theses-defended"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:when test="node()/text()='Prospěl'">
                        <xsl:text> [</xsl:text><span class="text-theses-defended"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> [</xsl:text><span class="text-theses-failed"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-defense-status-not-defended-item-view</i18n:text></span><xsl:text>]</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 21. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-acceptance-date">
        <xsl:if test="dim:field[@element='dateAccepted'][not (@qualifier)]">
            <div class="simple-item-view-date item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-acceptance-date-item-view</i18n:text></h4>
                <div>
                    <xsl:choose>
                        <xsl:when test="substring(dim:field[@element='dateAccepted'][not (@qualifier)],9,1) = 0">
                            <xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],10,1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],9,2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>. </xsl:text>
                    <xsl:choose>
                        <xsl:when test="substring(dim:field[@element='dateAccepted'][not (@qualifier)],6,1) = 0">
                            <xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],7,1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],6,2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="substring(dim:field[@element='dateAccepted'][not (@qualifier)],1,4)"/>
                    <!--<xsl:call-template name="formatdate">-->
                        <!--<xsl:with-param name="DateTimeStr" select="dim:field[@element='dateAccepted']/text()"/>-->
                    <!--</xsl:call-template>-->
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 20. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-keywords-cs">
        <xsl:if test="count(dim:field[@element='subject'][not(@qualifier)]) &gt; 1">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-subject-item-view-cs</i18n:text></h4>
                <div>
                    <xsl:for-each select="dim:field[@element='subject' and @language='cs_CZ']">
                        <xsl:value-of select="./node()"/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 20. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-keywords-en">
        <xsl:if test="count(dim:field[@element='subject'][not(@qualifier)]) &gt; 1">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-subject-item-view-en</i18n:text></h4>
                <div>
                    <xsl:for-each select="dim:field[@element='subject' and @language='en_US']">
                        <xsl:value-of select="./node()"/><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h4>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <!--<xsl:when test="dim:field[@element='contributor']">-->
                        <!--<xsl:for-each select="dim:field[@element='contributor']">-->
                            <!--<xsl:call-template name="itemSummaryView-DIM-authors-entry" />-->
                        <!--</xsl:for-each>-->
                    <!--</xsl:when>-->
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 21. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-advisors">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='advisor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-advisor-item-view</i18n:text></h4>
                <xsl:for-each select="dim:field[@element='contributor' and @qualifier='advisor']">
                    <xsl:call-template name="itemSummaryView-DIM-advisors-entry" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 21. 2. 2017 -->
    <xsl:template name="itemSummaryView-DIM-referees">
        <xsl:if test="dim:field[@element='contributor' and @qualifier='referee' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-referee-item-view</i18n:text></h4>
                <xsl:for-each select="dim:field[@element='contributor' and @qualifier='referee']">
                    <xsl:call-template name="itemSummaryView-DIM-referees-entry" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-advisors-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>/browse?type=advisor&amp;value=</xsl:text><xsl:copy-of select="./node()"/>
                </xsl:attribute>
                <xsl:copy-of select="node()"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-referees-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>/browse?type=author&amp;value=</xsl:text><xsl:copy-of select="./node()"/>
                </xsl:attribute>
                <xsl:copy-of select="node()"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h4 class="item-view-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h4>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h4 class="item-view-heading">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h4>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h4 class="item-view-heading">
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h4>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <h4 class="item-view-heading">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h4>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <h5 class="item-list-entry">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
            </h5>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <!-- <JR> - 21. 2. 2017 -->
    <!-- Format date helper template -->

    <xsl:template name="formatdate">

        <xsl:param name="DateTimeStr" />
        <xsl:variable name="datestr">
            <xsl:value-of select="$DateTimeStr" />
        </xsl:variable>

        <xsl:variable name="mm">
            <xsl:value-of select="substring($datestr,6,2)" />
        </xsl:variable>

        <xsl:variable name="dd">
            <xsl:value-of select="substring($datestr,9,2)" />
        </xsl:variable>

        <xsl:variable name="yyyy">
            <xsl:value-of select="substring($datestr,1,4)" />
        </xsl:variable>

        <xsl:value-of select="concat($dd,'. ', $mm, '. ', $yyyy)" />
    </xsl:template>


</xsl:stylesheet>
