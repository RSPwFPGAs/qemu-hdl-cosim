`timescale 1ns/100ps
/*
	Known Limitations: Can only transfer up to one full bus of data at a time.
*/
module axi4_s_r
#(
    parameter   TAGW            = 3
,               ADRW            = 32
,               DATW            = 256
,               SIZE            = 3'b010        // always refer to DATW
,               STBW            = (DATW/8)
,               DTMP            = 4096
,				NSTB            = DTMP/STBW
)
(
    input                       i_clk
,   input                       i_rst_n

, 	input 	byte req_data [0:DTMP-1]
,   input						req_valid

,   input           [ TAGW-1:0] i_s_arid
,   input           [ ADRW-1:0] i_s_araddr
,   input           [    8-1:0] i_s_arlen
,   input           [    3-1:0] i_s_arsize
,   input           [    2-1:0] i_s_arburst
,   input                       i_s_arlock
,   input           [    4-1:0] i_s_arcache
,   input           [    3-1:0] i_s_arprot
,   input           [    4-1:0] i_s_arregion
,   input                       i_s_arvalid
,   output reg                  o_s_arready

,   output reg      [ TAGW-1:0] o_s_rid
,   output reg      [ DATW-1:0] o_s_rdata
,   output          [    2-1:0] o_s_rresp
,   output reg                  o_s_rlast
,   output reg                  o_s_rvalid
,   input                       i_s_rready
);

	import "DPI-C" function void C_req_read(input longint addr, input int width, input int len, input int id);
    //---------------------------------------------------------------------
    // SLAVE READ
    //---------------------------------------------------------------------
    localparam AXI_RESP_OK          = 2'b00;
    
    localparam READ_IDLE            = 0;
    localparam READ_DATA            = 1;
    localparam READ_RESPONSE        = 2;

    //---------------------------------------------------------------------
    // Reg/Wire
    //---------------------------------------------------------------------

    reg        [           1:0] r_read_state            , n_read_state              ;
    reg                         r_s_arready             , n_s_arready               ;
    reg        [      DATW-1:0] r_s_rdata               , n_s_rdata                 ;
    reg                         r_s_rlast               , n_s_rlast                 ;
    reg                         r_s_rvalid              , n_s_rvalid                ;

    reg        [      TAGW-1:0] r_id                    , n_id                      ;
    reg        [         8-1:0] r_len                   , n_len                     ;
    reg        [         8-1:0] r_len_cnt 				, n_len_cnt                 ;


    byte                        r_data  [0:DTMP-1]      , n_data  [0:DTMP-1]        ;

    //---------------------------------------------------------------------
    // Instance
    //---------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Main
    //---------------------------------------------------------------------

    //------------------------------------------------------
    // Combo
    //------------------------------------------------------

    integer i;

    always@(*)
    begin: COMBO_READ
        n_read_state            = r_read_state      ;

        n_id                    = r_id              ;
        n_len                   = r_len             ;
        n_len_cnt               = r_len_cnt         ;

        n_s_arready             = r_s_arready       ;
        n_s_rdata               = r_s_rdata         ; 
        n_s_rlast               = r_s_rlast         ;
        n_s_rvalid              = r_s_rvalid        ;
      
        n_data                  = r_data            ;

        case(r_read_state)

        READ_IDLE: begin
        	n_s_rvalid = 0;
        	n_s_rlast = 0;
            if( i_s_arvalid ) begin
                n_s_arready = 0;
                n_len = i_s_arlen;
                n_len_cnt = 0;
                n_id = i_s_arid;
                n_read_state = READ_DATA;
            end
        end
        READ_DATA: begin
        	if ( req_valid ) begin
        		n_read_state = READ_RESPONSE;
        		n_data = req_data;
        	end
        end
        READ_RESPONSE: begin
            if ( i_s_rready ) begin
            	n_s_rvalid = 1;
                for ( i=0; i<STBW; i=i+1 ) begin
                    n_s_rdata[(i*8)+:8] = r_data[(STBW*r_len_cnt)+i];
                end

                if ( n_len_cnt == n_len ) begin
                   	n_s_rlast = 1;
                   	n_read_state = READ_IDLE;
                   	n_s_arready = 1;
                end else begin
                	n_len_cnt = r_len_cnt + 1;
                end
            end
        end
        endcase // read_state
    end // COMBO_READ

    //------------------------------------------------------
    // FF
    //------------------------------------------------------
    integer ksr;

    always@(posedge i_clk)
    begin: C_slave_read_ff
        if(i_s_arvalid && r_read_state == READ_IDLE) begin
            C_req_read(i_s_araddr, i_s_arsize, i_s_arlen, i_s_arid);
        end
    end

    always@(posedge i_clk)
    begin: FF
        if(~i_rst_n) begin
            r_read_state       <= READ_IDLE         ;
            r_id               <= 0                 ;
            r_len              <= 0                 ;
            r_len_cnt          <= 0                 ;
            r_s_arready        <= 1                 ;
            r_s_rdata          <= {(DATW/4){4'hA}}  ; 
            r_s_rlast          <= 0                 ;
            r_s_rvalid         <= 0                 ;
            for ( ksr=0; ksr<DTMP; ksr=ksr+1 ) begin
            r_data[ksr]        <= 0                 ;
            end
        end
        else begin
            r_read_state       <= n_read_state      ;
            r_id               <= n_id              ;
            r_len              <= n_len             ;
            r_len_cnt          <= n_len_cnt         ;
            r_s_arready        <= n_s_arready       ;
            r_s_rdata          <= n_s_rdata         ; 
            r_s_rlast          <= n_s_rlast         ;
            r_s_rvalid         <= n_s_rvalid        ;
            r_data             <= n_data            ;
        end
    end


    //---------------------------------------------------------------------
    // Output Assignment
    //---------------------------------------------------------------------

    // Combo Out
    // Const Out
    assign  o_s_rresp			= AXI_RESP_OK		;
    // Reg   Out
    assign  o_s_arready			= r_s_arready		;
    assign  o_s_rdata			= r_s_rdata  		;
    assign  o_s_rid 			= r_id 				;
    assign  o_s_rlast			= r_s_rlast 		;
    assign  o_s_rvalid			= r_s_rvalid 		;

    initial begin
        r_s_arready			<= 1 ;
        r_s_rdata           <= 0 ;
        r_id                <= 0 ;
        r_s_rlast           <= 0 ;
        r_s_rvalid          <= 0 ;
    end

endmodule // axi4_s_r
