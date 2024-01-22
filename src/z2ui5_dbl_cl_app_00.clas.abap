CLASS z2ui5_dbl_cl_app_00 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_dbl_cl_app_00 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF client->get( )-check_on_navigated = abap_true.

      DATA(view) = z2ui5_cl_xml_view=>factory( client ).

      DATA(page) = view->shell( )->page(
              title          = 'abap2UI5 - DB Loader'
              navbuttonpress = client->_event( 'BACK' )
              shownavbutton  = abap_true ).

      page->generic_tile(
         class     = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
         header    = `Upload DB Table`
         subheader    = `CSV & JSON`
         press     = client->_event( `z2ui5_file_cl_app_01` )
      )->get( )->tile_content(
        )->image_content( src = 'sap-icon://upload' ).

      page->generic_tile(
         class     = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
         header    = `DB Table Editor`
         subheader    = `CSV & JSON`
         press     = client->_event( `z2ui5_file_cl_app_01` )
      )->get( )->tile_content(
        )->image_content( src = 'sap-icon://upload' ).

      page->generic_tile(
        class = 'sapUiTinyMarginBegin sapUiTinyMarginTop tileLayout'
        header    = `View, Change & Download`
*        subheader    = `on-premise only`
         press     = client->_event( `z2ui5_xlsx_cl_app_02` )
      )->get( )->tile_content(
         )->image_content( src = 'sap-icon://download' ).

      client->view_display( view->stringify( ) ).

    ENDIF.

    IF client->get( )-event IS INITIAL.
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BACK`.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

        DATA li_app TYPE REF TO z2ui5_if_app.
        DATA(lv_classname) = to_upper( client->get( )-event ).
        CREATE OBJECT li_app TYPE (lv_classname).
        client->nav_app_call( li_app ).

    ENDCASE.


  ENDMETHOD.
ENDCLASS.
