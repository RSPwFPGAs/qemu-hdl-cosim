`timescale 1ns/100ps
/*
 *	Known Limitations: Can only transfer up to one full bus of data at a time.
 */
module axi4_m_w
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

,	input 			[ ADRW-1:0] req_addr
,	input 			[    8-1:0] req_len
,	input 			[    3-1:0] req_size
, 	input  int	    req_strb [0:NSTB-1]
, 	input  byte 	req_data [0:DTMP-1]
,   input						req_valid

,   output          [ TAGW-1:0] o_m_awid
,   output  reg     [ ADRW-1:0] o_m_awaddr
,   output  reg     [    8-1:0] o_m_awlen
,   output  reg     [    3-1:0] o_m_awsize
,   output          [    2-1:0] o_m_awburst
,   output                      o_m_awlock
,   output          [    4-1:0] o_m_awcache
,   output          [    3-1:0] o_m_awprot
,   output          [    4-1:0] o_m_awregion
,   output  reg                 o_m_awvalid
,   input                       i_m_awready

,   output          [ TAGW-1:0] o_m_wid
,   output  reg     [ DATW-1:0] o_m_wdata
,   output  reg                 o_m_wlast
,   output  reg     [ STBW-1:0] o_m_wstrb
,   output  reg                 o_m_wvalid
,   input                       i_m_wready

,   input           [ TAGW-1:0] i_m_bid
,   input           [    2-1:0] i_m_bresp
,   input                       i_m_bvalid
,   output  reg                 o_m_bready
);

    import "DPI-C" function void C_resp_write();

    //---------------------------------------------------------------------
    // Constant Declarations
    //---------------------------------------------------------------------
    localparam WRITE_IDLE            = 0;
    localparam WRITE_DATA            = 1;
    localparam WRITE_RESPONSE        = 2;

    //---------------------------------------------------------------------
    // Reg/Wire
    //---------------------------------------------------------------------
    reg        [           1:0] r_write_state           , n_write_state             ;
 
    reg        [      ADRW-1:0] r_addr                  , n_addr                    ;
    reg        [         3-1:0] r_size                  , n_size                    ;
    reg        [         8-1:0] r_len                   , n_len                     ;
    reg        [         8-1:0] r_len_cnt               , n_len_cnt                 ;
    reg                         r_m_awvalid             , n_m_awvalid               ;

    byte                 r_data [0:DTMP-1]              , n_data [0:DTMP-1]         ;
    int 	             r_strb [0:NSTB-1]	            , n_strb [0:NSTB-1]         ;
    
    reg 	   [	  DATW-1:0]	r_m_wdata				, n_m_wdata					;

	reg 	   [	  STBW-1:0]	r_m_wstrb				, n_m_wstrb					;
    reg 						r_m_last				, n_m_last					;
    reg                         r_m_wvalid              , n_m_wvalid                ;

    //---------------------------------------------------------------------
    // Instance
    //---------------------------------------------------------------------

    //---------------------------------------------------------------------
    // Main
    //---------------------------------------------------------------------

    //------------------------------------------------------
    // Combo
    //------------------------------------------------------
    int i;
        always@(*)
    begin: COMBO_WRITE

        n_write_state           = r_write_state     ;

        n_addr                  = r_addr            ;
        n_size                  = r_size            ;
        n_len                   = r_len             ;
        n_len_cnt               = r_len_cnt         ;
        n_m_awvalid             = r_m_awvalid       ; 

        n_data 					= r_data 			;
        n_strb					= r_strb			;
        n_m_last				= r_m_last			;
        n_m_wdata				= r_m_wdata			;
        n_m_wstrb				= r_m_wstrb			;
        n_m_wvalid 				= r_m_wvalid 		;

        case(r_write_state)

        WRITE_IDLE: begin
            if(req_valid) begin
                //$display("V: Q->H WR: addr: %h", n_addr);
                n_write_state = WRITE_DATA;
                n_m_awvalid = 1;
                n_len_cnt = 0;
                n_addr = req_addr;
                n_size = req_size;
                n_len  = req_len;
                n_data = req_data;
                n_strb = req_strb;
            end
        end // case: WRITE_IDLE

        WRITE_DATA: begin
            if ( i_m_awready ) begin
                n_m_awvalid = 0;
            end   
            if ( i_m_wready ) begin
                n_m_wvalid = 1;
                
                for ( i=0; i<STBW; i=i+1 ) begin
                    n_m_wdata[(i*8)+:8] = r_data[(STBW*r_len_cnt)+i];
                end

                n_m_wstrb = r_strb[r_len_cnt];

                if ( n_len_cnt == n_len ) begin
                   	n_m_last = 1;
                   	n_write_state = WRITE_RESPONSE;
                end else begin
                	n_len_cnt = r_len_cnt + 1;
                end

            end // if ( i_m_wready )
        end // case: WRITE_DATA

        WRITE_RESPONSE: begin
        	n_m_wvalid = 0;
        	n_m_last = 0;
        	if ( i_m_bvalid ) begin
        		n_write_state = WRITE_IDLE;
        	end
        end // case: WRITE_RESPONSE
        endcase // r_read_state
    end // COMBO_WRITE

    //------------------------------------------------------
    // FF
    //------------------------------------------------------

    always@(posedge i_clk)
    begin: C_resp
        if (i_m_bvalid) 
            C_resp_write();
    end
    
    integer k;
    always@(posedge i_clk)
    begin: FF
        if(~i_rst_n) begin
            //State
            r_write_state <= WRITE_IDLE;
            //Address
            r_addr <= 0;
            r_len <= 0;
            r_size <= 0;
            r_m_awvalid <= 0;
            //Data
            r_m_wstrb <= 0;
            r_m_last <= 0;
            r_m_wvalid <= 0;
            for ( k=0; k<DTMP; k=k+1 ) begin
                r_data[k] <= 0;
            end
            for ( k=0; k<NSTB; k=k+1 ) begin
                r_strb[k] <= 0;
            end
            r_m_wdata <= 0;
            r_len_cnt <= 0;
            end
        else begin
            //State
            r_write_state <= n_write_state;
            //Address
            r_addr  <= n_addr;
            r_len   <= n_len;
            r_size  <= n_size;
            r_strb <= n_strb;
            r_data <= n_data;
            r_m_awvalid <= n_m_awvalid;
            //Data
            r_m_wstrb <= n_m_wstrb;
            r_m_last <= n_m_last;
            r_m_wvalid <= n_m_wvalid;
            r_m_wdata <= n_m_wdata;
            r_len_cnt <= n_len_cnt;
        end
    end

    //---------------------------------------------------------------------
    // Primary Output Assignment
    //---------------------------------------------------------------------
    // Combo Out
    // Const Out
    assign  o_m_awid            = 0                 ;
    assign  o_m_awburst         = 2'b01             ;
    assign  o_m_awlock          = 0                 ;
    assign  o_m_awcache         = 4'b0011           ;
    assign  o_m_awprot          = 0                 ;
    assign  o_m_awregion        = 0                 ;
    assign  o_m_wid             = 0                 ;
    assign  o_m_bready          = 1                 ;
    // Reg   Out
    assign  o_m_awaddr          = r_addr            ;
    assign  o_m_awlen           = r_len             ;
    assign  o_m_awsize          = r_size            ;
    assign  o_m_awvalid         = r_m_awvalid       ;
    assign  o_m_wdata	        = r_m_wdata 		;
    assign  o_m_wstrb	        = r_m_wstrb	    	;
    assign  o_m_wlast           = r_m_last			;
    assign  o_m_wvalid          = r_m_wvalid        ;

    initial begin
        r_addr      <= 0   ;
        r_len       <= 0   ;
        r_size      <= 0   ;
        r_m_awvalid <= 0   ;
        r_m_wdata   <= 0   ;
        r_m_wstrb   <= 0   ;
        r_m_last    <= 0   ;
        r_m_wvalid  <= 0   ;
    end

endmodule // axi4_m_w
