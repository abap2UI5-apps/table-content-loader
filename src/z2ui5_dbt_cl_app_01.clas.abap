CLASS z2ui5_dbt_cl_app_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mt_table TYPE REF TO data.
    DATA mt_cols TYPE string_table.
    DATA mv_name TYPE string.

    TYPES:
      BEGIN OF ty_s_range,
        name    TYPE string,
        value   TYPE string,
        t_range TYPE RANGE OF string,
      END OF ty_s_range.

    DATA mt_range TYPE STANDARD TABLE OF ty_s_range.
    DATA:
      BEGIN OF ms_app,
        max_rows TYPE string,
        file     TYPE string,
      END OF ms_app.


  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_dbt_cl_app_01 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      TRY.
          DATA(lo_popup_file) = CAST z2ui5_cl_popup_file_upload( client->get_app( client->get( )-s_draft-id_prev_app ) ).
          IF lo_popup_file->result( )-check_confirmed = abap_true.
            ms_app-file = lo_popup_file->result( )-value.
            client->message_toast_display( `File uploaded sucessfully` ).
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'BUTTON_TABLE'.
        FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
        CREATE DATA mt_table TYPE STANDARD TABLE OF (mv_name) WITH DEFAULT KEY.
        ASSIGN mt_table->* TO <tab>.
        mt_cols = z2ui5_dbt_cl_utility=>get_fieldlist_by_table( <tab> ).


      WHEN 'BUTTON_POST'.

        CREATE DATA mt_table TYPE STANDARD TABLE OF (mv_name).
        ASSIGN mt_table->* TO <tab>.

        SELECT FROM (mv_name)
            FIELDS *
          INTO CORRESPONDING FIELDS OF TABLE @<tab>
            UP TO 50 ROWS.

      WHEN 'UPLOAD'.
        client->nav_app_call( z2ui5_cl_popup_file_upload=>factory( ) ).

      WHEN 'BUTTON_CANCEL'.
        client->message_toast_display( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = 'VIEW_MAIN'.
    mv_name = `Z2UI5_T_DRAFT`.

  ENDMETHOD.


  METHOD z2ui5_on_render.

*     IF mv_check_download_file = abap_true.
*        mv_check_download_file = abap_false.
*
***        view->_generic( ns = `html` name = `iframe` t_prop = VALUE #( ( n = `src` v = `data:application/xlsx;base64,` && lv_base ) ( n = `hidden` v = `hidden` ) ) ).
*        page->_generic( ns = `html` name = `iframe` t_prop = VALUE #( ( n = `src` v = `data:text/csv;base64,` && mv_file ) ( n = `hidden` v = `hidden` ) ) ).
***        view->_generic( ns = `html` name = `a` t_prop = VALUE #( ( n = `href` v = `data:text/csv;base64,` && lv_base ) ( n = `download` v = `filename.csv` ) ) ).
*
*      ENDIF.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).

    DATA(page) = view->page(
                title          = 'a2UI5 App - JSON File Upload'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
          )->header_content(
                )->link(
                    text = 'Project on GitHub'
                    target = '_blank'
                    href = `https://github.com/oblomov-dev/`
                )->get_parent(  ).

    DATA(content) = page->simple_form( "title    = `Create File .xlsx`
                                     "  layout   = `ResponsiveGridLayout`
                                       editable = `true` ).


    content->label( `(1) JSON File Upload`
        )->button( text = `Run...` width = `10%` press = client->_event( `UPLOAD` )
          )->label(
         )->input( width = `20%` description = `Size`
        )->label( `(2) Check DB Table`
        )->input( width = `20%` description =  `DB Table`
         )->label(
        )->button( text = `Run...` width = `10%` press = client->_event( `DB_CHECK` )
        )->label(
        )->input( width = `20%` description = `DB Number of Rows`
        )->label( `(3) JSON -> ITAB`
       )->button( text = `Run...` width = `10%` press = client->_event( `PROCESS` )
        )->label(
        )->input( width = `20%` description = `Number of Entries`
        )->label( `(4) Preview Rows`
        )->input( width = `20%` description = `Number of Rows`
         )->label(
       )->button( text = `Run...` width = `10%` press = client->_event( `PREVIEW` )
       )->label( `(5) Save Database`
       )->text( `Attention - Database Content will be overwritten!!!`
       )->label(
       )->button( text = `Run` width = `10%` press = client->_event( `PROCESS` )
*        )->input(  value = client->_bind( ms_app-max_rows ) width = `10%` description = `kB` enabled = abap_false
        ).
*        )->label( `File`
*        )->button( text = `Upload` width = `7%` enabled = COND #( WHEN mv_file IS NOT INITIAL THEN abap_true ELSE abap_false ) press = client->_event( `DOWNLOAD_FILE` ) ).



    client->view_display( view->stringify( ) ).


*    return.
*    DATA(page) = z2ui5_cl_xml_view=>factory( client )->shell( )->page(
*             title          = 'abap2UI5 - Database Tool'
*             navbuttonpress = client->_event( 'BACK' )
*             shownavbutton  = abap_true ).
*
*         page->sub_header(
*            )->toolbar(
*            )->label( 'Name'
*            )->input( value = client->_bind_edit( mv_name  ) width = `20%`
*            )->button( text = 'edit'
*            )->toolbar_spacer(
*            )->button( text = 'File Upload'
*            )->button( text = 'View/Change/Download'
*            )->button( text = 'JSON/XML Editor'
*            ).
*
**             )->link(
**                 text = 'Demo' target = '_blank'
**                 href = 'https://twitter.com/abap2UI5/status/1656904560953237508'
**             )->link(
**                 text = 'Source_Code' target = '_blank'
***                 href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me )
**         )->get_parent(
**         )->simple_form(  editable = abap_true
**             )->content( `form`
**                 )->title( 'Table'
**                 )->label( 'Name' ).
*
*   page->input( client->_bind_edit( mv_name  ) ).
*
*    page->button(
*                text  = 'read'
*                press = client->_event( 'BUTTON_POST' )
*            ).
*
*
*    IF mt_table IS BOUND.
*
*      FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
*      ASSIGN mt_table->* TO <tab>.
*      mt_cols = z2ui5_dbt_cl_utility=>get_fieldlist_by_table( <tab> ).
*
*      mt_range = VALUE #( FOR line IN mt_cols ( name = line ) ).
*
*      page->get_parent( )->get_parent( )->list(
*        items = client->_bind( mt_range )
*        headertext      = `Filter`
*        )->custom_list_item(
*            )->hbox(
*                )->text( `{NAME}`
*                )->input( value = `{VALUE}` enabled = abap_false
*        ).
*
*
*
*      DATA(tab) = page->get_parent( )->get_parent( )->simple_form( editable = abap_true
*                )->content( 'form' )->table(
*                  items = client->_bind( val = <tab> )
*              ).
*
*      DATA(lo_columns) = tab->columns( ).
*
*
*      LOOP AT mt_cols INTO DATA(lv_field) FROM 2.
*        lo_columns->column( )->text( lv_field ).
*      ENDLOOP.
*
*      DATA(lo_cells) = tab->items( )->column_list_item( selected = '{SELKZ}' )->cells( ).
*      LOOP AT mt_cols INTO lv_field FROM 2.
*        lo_cells->input( `{` && lv_field && `}` ).
*      ENDLOOP.
*
*    ENDIF.
*
*    client->view_display( page->stringify( ) ).
**    app-next-xml_main = lo_view->get_root( )->xml_get( ).

  ENDMETHOD.
ENDCLASS.
