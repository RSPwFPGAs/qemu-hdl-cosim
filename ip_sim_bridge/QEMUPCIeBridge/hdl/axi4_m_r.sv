`timescale 1ns/100ps
module axi4_m_r
#(
    parameter   TAGW            = 3
,               ADRW            = 32
,               DATW            = 256
,               SIZE            = 3'b010        // always refer to DATW
,               STBW            = (DATW/8)
,               DTMP            = 4096
)
(
    input                       i_clk
,   input                       i_rst_n
		
,	input 			[ ADRW-1:0] req_addr
,	input 			[    8-1:0] req_len
,	input 			[    3-1:0] req_size
,   input						req_valid

,   output          [ TAGW-1:0] o_m_arid
,   output  reg     [ ADRW-1:0] o_m_araddr
,   output  reg     [    8-1:0] o_m_arlen
,   output  reg     [    3-1:0] o_m_arsize
,   output          [    2-1:0] o_m_arburst
,   output                      o_m_arlock
,   output          [    4-1:0] o_m_arcache
,   output          [    3-1:0] o_m_arprot
,   output          [    4-1:0] o_m_arregion
,   output  reg                 o_m_arvalid
,   input                       i_m_arready

,   input           [ TAGW-1:0] i_m_rid
,   input           [ DATW-1:0] i_m_rdata
,   input           [    2-1:0] i_m_rresp
,   input                       i_m_rlast
,   input                       i_m_rvalid
,   output  reg                 o_m_rready
);

 	import "DPI-C" function void C_resp_read(input longint addr, input byte data_tmp[DTMP]);

    //---------------------------------------------------------------------
    // Constant Declarations
    //---------------------------------------------------------------------
    
    localparam READ_IDLE           = 0;
    localparam READ_DATA           = 1;

    //---------------------------------------------------------------------
    // Reg/Wire
    //---------------------------------------------------------------------

    reg        [           1:0] r_read_state            , n_read_state              ;
 
    reg        [      ADRW-1:0] r_addr                  , n_addr                    ;
    reg        [         3-1:0] r_size                  , n_size                    ;
    reg        [         8-1:0] r_len                   , n_len                     ;
    reg        [         8-1:0] r_len_cnt               , n_len_cnt                 ;
    reg                         r_m_arvalid             , n_m_arvalid               ;

    reg                         r_m_rready              , n_m_rready                ;
    byte                        r_data_tmp [0:DTMP-1]   , n_data_tmp [0:DTMP-1]     ;

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

        n_addr                  = r_addr            ;
        n_size                  = r_size            ;
        n_len                   = r_len             ;
        n_len_cnt               = r_len_cnt         ;
        n_m_arvalid             = r_m_arvalid       ; 

        n_m_rready              = r_m_rready        ; 
        n_data_tmp              = r_data_tmp        ;

        case(r_read_state)

        READ_IDLE: begin
            if(req_valid) begin
                n_read_state = READ_DATA;
                n_m_arvalid = 1;
                n_m_rready = 1;
                n_len_cnt = 0;
                n_addr = req_addr;
                n_size = req_size;
                n_len = req_len;
            end
        end // case: READ_IDLE

        READ_DATA: begin
            if ( i_m_arready ) begin
                n_m_arvalid = 0;
            end   
            if ( i_m_rvalid ) begin

                for ( i=0; i<STBW; i=i+1 ) begin
                    n_data_tmp[(r_len_cnt*STBW)+i] = i_m_rdata[(i*8)+:8];
                end

                if ( ! i_m_rlast ) begin
                    n_len_cnt = r_len_cnt + 1;
                end else begin
                    n_m_rready = 0;
                    n_read_state = READ_IDLE;
                end

            end // if ( i_m_rvalid )
        end // case: READ_DATA
        endcase // r_read_state
    end // COMBOREAD


    //------------------------------------------------------
    // FF
    //------------------------------------------------------
    always@(posedge i_clk)
    begin: C_req
        if ( i_m_rvalid && (n_read_state==READ_DATA) ) begin
            //$display( "V: HDL -> QEMU: R_resp: RDATA=%h", i_m_rdata );
        end
        if (r_read_state == READ_DATA && i_m_rlast && i_m_rvalid) begin
            C_resp_read(n_addr, n_data_tmp);
        end
    end

    integer k;
    always@(posedge i_clk)
    begin: FF
        if(~i_rst_n) begin
            //State
            r_read_state <= READ_IDLE;
            //Address
            r_addr <= 0;
            r_len <= 0;
            r_size <= 0;
            r_m_arvalid <= 0;
            //Data
            r_m_rready <= 0;
            for ( k=0; k<DTMP; k=k+1 ) begin
                r_data_tmp[k] <= 0;
            end
            r_len_cnt <= 0;
        end
        else begin
            //State
            r_read_state <= n_read_state;
            //Address
            r_addr  <= n_addr;
            r_len   <= n_len;
            r_size  <= n_size;
            r_m_arvalid <= n_m_arvalid;
            //Data
            r_m_rready <= n_m_rready;
            r_data_tmp <= n_data_tmp;
            r_len_cnt <= n_len_cnt;
        end
    end


    //---------------------------------------------------------------------
    // Primary oUtput Assignment
    //---------------------------------------------------------------------

    // Combo Out
    // Const Out
    assign  o_m_arid            = 0                 ;
    assign  o_m_arburst         = 2'b01             ;
    assign  o_m_arlock          = 0                 ;
    assign  o_m_arcache         = 4'b0011           ;
    assign  o_m_arprot          = 0                 ;
    assign  o_m_arregion        = 0                 ;
    // Reg   Out
    assign  o_m_araddr          = r_addr            ;
    assign  o_m_arlen           = r_len             ;
    assign  o_m_arsize          = r_size            ;
    assign  o_m_arvalid         = r_m_arvalid       ;
    assign  o_m_rready          = r_m_rready        ;

    initial begin
        r_addr          <= 0     ;
        r_len           <= 0     ;
        r_size          <= 0     ;
        r_m_arvalid     <= 0     ;
        r_m_rready      <= 0     ;
    end

endmodule // axi4_m_r

