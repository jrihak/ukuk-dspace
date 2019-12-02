package org.dspace.discovery;

import org.apache.log4j.Logger;

import org.apache.solr.common.SolrInputDocument;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.Metadatum;

import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.core.ConfigurationManager;

import org.dspace.util.SolrImportExportException;
import java.util.List;

/**
 * Indexing plugin used when indexing the communities/collections/items into DSpace
 *
 * @author Kevin Van de Velde (kevin at atmire dot com)
 * @author Mark Diggory (markd at atmire dot com)
 * @author Ben Bosman (ben at atmire dot com)
 */
public class SolrServiceFacultyMappingPlugin implements SolrServiceIndexPlugin 
{

    /** log4j category */
    private static final Logger log = Logger.getLogger(SolrServiceFacultyMappingPlugin.class);

    @Override
    public void additionalIndex(Context context, DSpaceObject dso, SolrInputDocument document) 
    {
        if (dso instanceof Item)
        {
            // Get an array of metadata fields in which the information about responsible faculties are stored
            // TODO: Get the name of the Metadata string from configuration file
            // TODO: Decide if we want to have separate metadata fields for faculty with PRIMARY RESPONSIBILITY and for faculties with SECONDARY RESPONSIBILITY
            Metadatum[] faculty_ids = dso.getMetadataByMetadataString("uk.faculty-name.*");
            
            log.info("Metadata value found in DSpace object is: "+faculty_ids);
            log.info("Array size is: "+faculty_ids.length);
            if (faculty_ids.length > 0)
            {   // We found at least one field with specified schema.element.qualifier in the Item metadata
                log.info("Metadatum list is longer than 0!");

                // go through the found metadata fields and get their values
                for (int i=0; i <  faculty_ids.length; i++)
                {
                    // Get managed names from config / map file / api endpoint (depends what will be available in the end)
                    //
                    // FIXME: Stick to the config file for now / we might want to get this data on the fly from database or API later?
                    String faculty_id = null;

                    try
                    {
                        faculty_id = faculty_ids[i].value;
                        log.info("Faculty ID found: "+faculty_id);
                        String names_config = ConfigurationManager.getProperty("solr-mapping", "faculty-map-id."+faculty_id);
                        
                        if (names_config.length() == 0 || names_config == null)
                        {
                            // This means that we didn't find currently processed FACULTY_ID in configuration file - and that is not good.
                            // FIXME: This might not be the right Exception to throw, consider creating a special type of Exception or using more suitable one
                            throw  new SolrImportExportException("Couldn't find a mapping for FACULTY_ID="+faculty_id);
                        }

                        String[] managed_names = names_config.split(",");

                        // Add SOLR field for faculty name converted from ID
                        // FIXME: We don't want to create SOLR field for each faculty ID that we find in Item metadata, instead we want to add multiple values
                        // to one field
                        // TODO: Decide, if we want to have a separate SOLR field for PRIMARY faculty and SECONDARY faculties OR if we want to have
                        // one general field for all faculties that have at least some responsibility for the item, e.g. "responsible_faculties_names"
                        //
                        // See https://wiki.lyrasis.org/display/DSPACE/How+to+add+additional+fields+and+values+to+Solr+discovery+index for example 
                        // when dealing with bitstream names
                        for (int y=0; y < managed_names.length; y++)
                        {
                            log.info("Adding name on index"+y+": "+managed_names[y].trim());
                            // Trim leading and trailing whitespaces and add value to SOLR index field
                            document.addField("faculty_managed_name", managed_names[y].trim());
                        }

                    }
                    catch (SolrImportExportException sie)
                    {
                        
                        log.warn(LogManager.getHeader(context, "configuration_error",
                            "no names mapping in cofiguration file for FACULTY_ID=" + faculty_id), sie);
                    }
                }
            }     
        }
    }
}
