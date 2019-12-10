`timescale 1ns/100ps

module axi4_s_w
# (
    parameter   TAGW            = 3
,               ADRW            = 32
,               DATW            = 256
,               STBW            = (DATW/8)
,               DTMP            = 4096
,               STMP            = (DTMP/32)
)
(
    input                       i_clk
,   input                       i_rst_n

,   input  [          TAGW-1:0] i_s_awid
,   input  [          ADRW-1:0] i_s_awaddr
,   input  [             8-1:0] i_s_awlen
,   input  [             3-1:0] i_s_awsize
,   input  [             2-1:0] i_s_awburst
,   input                       i_s_awlock
,   input  [             4-1:0] i_s_awcache
,   input  [             3-1:0] i_s_awprot
,   input  [             4-1:0] i_s_awregion
,   input                       i_s_awvalid
,   output                      o_s_awready

,   input  [          TAGW-1:0] i_s_wid
,   input  [          DATW-1:0] i_s_wdata
,   input                       i_s_wlast
,   input  [          STBW-1:0] i_s_wstrb
,   input                       i_s_wvalid
,   output                      o_s_wready

,   output [          TAGW-1:0] o_s_bid
,   output [             2-1:0] o_s_bresp
,   output                      o_s_bvalid
,   input                       i_s_bready

);

    import "DPI-C" function void C_req_write(input longint addr, input int width, input int len,
                                            input byte data_tmp[DTMP], input int strb_tmp[STMP]);

    //---------------------------------------------------------------------
    // Constant Declarations
    //---------------------------------------------------------------------

    localparam AXI_RESP_OK          = 2'b00;
    localparam AXI_RESP_SLVERR      = 2'b10;
    
    localparam WRITE_IDLE           = 0;
    localparam WRITE_RESPONSE       = 1;
    localparam WRITE_DATA           = 2;

    //---------------------------------------------------------------------
    // Reg/Wire
    //---------------------------------------------------------------------

    reg        [           1:0] r_write_state           , n_write_state             ;

    reg        [      TAGW-1:0] r_id                    , n_id                      ;    
    reg        [      ADRW-1:0] r_addr                  , n_addr                    ;
    reg        [         3-1:0] r_size                  , n_size                    ;
    reg        [         8-1:0] r_len                   , n_len                     ;
    reg        [         8-1:0] r_len_cnt               , n_len_cnt                 ;

    reg                         r_s_awready             , n_s_awready               ;
    reg                         r_s_wready              , n_s_wready                ;
    reg        [      TAGW-1:0] r_s_bid                 , n_s_bid                   ;
    reg        [         2-1:0] r_s_bresp               , n_s_bresp                 ;
    reg                         r_s_bvalid              , n_s_bvalid                ;
    
    byte                        r_data_tmp [0:DTMP-1]   , n_data_tmp [0:DTMP-1]     ;
    int                         r_strb_tmp [0:STMP-1]   , n_strb_tmp [0:STMP-1]     ;

    //---------------------------------------------------------------------
    // Instance
    //---------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Main
    //---------------------------------------------------------------------

    //------------------------------------------------------
    // Combo
    //------------------------------------------------------

    integer i, j;
    logic send_to_qemu;
    always@(*)
    begin: COMBO_WRITE

        n_write_state           = r_write_state     ;

        n_id                    = r_id              ;
        n_addr                  = r_addr            ;
        n_size                  = r_size            ;
        n_len                   = r_len             ;
        n_len_cnt               = r_len_cnt         ;

        n_s_awready             = r_s_awready       ;
        n_s_wready              = r_s_wready        ;
        n_s_bid                 = r_s_bid           ;
        n_s_bresp               = r_s_bresp         ;
        n_s_bvalid              = r_s_bvalid        ;  

        n_data_tmp              = r_data_tmp        ;
        n_strb_tmp              = r_strb_tmp        ;
        
        send_to_qemu = 0;
        
        case(r_write_state)

        WRITE_IDLE: begin
            if(i_s_awvalid) begin
                n_write_state   = WRITE_DATA        ;
                n_s_awready     = 1'b0              ;
                n_s_wready      = 1'b1              ;
                n_id            = i_s_awid          ;
                n_addr          = i_s_awaddr        ;
                n_size          = i_s_awsize        ;
                n_len           = i_s_awlen         ;
                n_len_cnt       = 0                 ;
            end
        end // case: WRITE_IDLE

        WRITE_DATA: begin
               
            if( i_s_wvalid ) begin

                for ( j=0; j<STBW; j=j+1 ) begin
                    n_data_tmp[(r_len_cnt*STBW)+j] = i_s_wdata[(j*8)+:8];
                end
                
                n_strb_tmp[r_len_cnt] = i_s_wstrb;

                if ( r_len_cnt != r_len ) begin
                    n_len_cnt       = r_len_cnt + 1     ;
                end else begin
                    n_s_bid         = r_id              ;
                    n_s_bresp       = AXI_RESP_OK	;
                    n_s_bvalid      = 1'b1              ;
                    n_s_wready      = 1'b0              ;
                    n_write_state   = WRITE_RESPONSE    ;
                    send_to_qemu = 1;
                end
            end // if ( i_s_wvalid )
        end // case: WRITE_DATA

        WRITE_RESPONSE: begin
            if (i_s_bready) begin                    
                n_write_state        = WRITE_IDLE   ;
                n_s_awready          = 1'b1         ;
                n_s_bvalid           = 1'b0         ;
            end
        end // case: WRITE_RESPONSE

        endcase // r_write_state
    end // COMBO_WRITE


    //------------------------------------------------------
    // FF
    //------------------------------------------------------
    integer k;

    always@(posedge i_clk)
    begin: C_req
        if (send_to_qemu) begin
            C_req_write(n_addr, n_size, n_len, n_data_tmp, n_strb_tmp);
        end
    end
    
    always@(*)
    begin: COMBO_DISPLAY
        @(posedge i_clk);
        if ( i_s_wvalid & (r_write_state==WRITE_DATA) ) begin
            //$display( "V: HDL ->QEMU: Write: WDATA=%h, WSTRB=%h", i_s_wdata, i_s_wstrb );
        end
    end // COMBO_DISPLAY

    always@(posedge i_clk)
    begin: FF
        if(~i_rst_n) begin
            r_write_state      <= WRITE_IDLE        ;
            r_s_awready        <= 1                 ;
            r_s_wready         <= 0                 ;
            r_s_bid            <= 0                 ;
            r_s_bresp          <= AXI_RESP_OK       ;    
            r_s_bvalid         <= 0                 ;
            r_id               <= 0                 ;
            r_addr             <= 0                 ;
            r_size             <= 0                 ;
            r_len              <= 0                 ;
            r_len_cnt          <= 0                 ;
            for ( k=0; k<DTMP; k=k+1 ) begin
            r_data_tmp[k]      <= 0                 ;
            end
            for ( k=0; k<STMP; k=k+1 ) begin
            r_strb_tmp[k]      <= 0                 ;
            end
        end
        else begin
            r_write_state      <= n_write_state     ;
            r_s_awready        <= n_s_awready       ;
            r_s_wready         <= n_s_wready        ;
            r_s_bid            <= n_s_bid           ;
            r_s_bresp          <= n_s_bresp         ;
            r_s_bvalid         <= n_s_bvalid        ;
            r_id               <= n_id              ;
            r_addr             <= n_addr            ;
            r_size             <= n_size            ;
            r_len              <= n_len             ;
            r_len_cnt          <= n_len_cnt         ;
            r_data_tmp         <= n_data_tmp        ;
            r_strb_tmp         <= n_strb_tmp        ;
        end
    end


    //---------------------------------------------------------------------
    // Primary oUtput Assignment
    //---------------------------------------------------------------------

    // Combo Out
    // Const Out
    // Reg   Out
    assign  o_s_awready         = r_s_awready       ;
    assign  o_s_wready          = r_s_wready        ;
    assign  o_s_bid             = r_s_bid           ;
    assign  o_s_bresp           = r_s_bresp         ;
    assign  o_s_bvalid          = r_s_bvalid        ;

endmodule
