`timescale 1ns/100ps
module axi4_ip
#(
    parameter   TAGW            = 3
,               ADRW            = 32
,               DATW            = 256
,               SIZE            = 3'b101        // always refer to DATW
,               STBW            = (DATW/8)
,               DTMP            = 4096
,               NSTB            = DTMP/STBW

,               CLKOFREQ        = 250
)
(
    // Clock/Reset
    input wire                  i_axi_ctl_aclk
,   input wire                  i_sys_rst_n
,   input wire                  i_refclk  
,   output                      o_axi_aclk
,   output                      o_axi_aresetn

    //Master read wires
,   output          [ TAGW-1:0] o_m_arid
,   output  reg     [ ADRW-1:0] o_m_araddr
,   output  reg     [    8-1:0] o_m_arlen
,   output          [    3-1:0] o_m_arsize
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

    //Master write wires
,   output          [ TAGW-1:0] o_m_awid
,   output  reg     [ ADRW-1:0] o_m_awaddr
,   output  reg     [    8-1:0] o_m_awlen
,   output          [    3-1:0] o_m_awsize
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
,   output          [ STBW-1:0] o_m_wstrb
,   output  reg                 o_m_wvalid
,   input                       i_m_wready

,   input           [ TAGW-1:0] i_m_bid
,   input           [    2-1:0] i_m_bresp
,   input                       i_m_bvalid
,   output  reg                 o_m_bready
    
    //Slave Read wires
,   input  [          TAGW-1:0] i_s_arid
,   input  [          ADRW-1:0] i_s_araddr
,   input  [             8-1:0] i_s_arlen
,   input  [             3-1:0] i_s_arsize
,   input  [             2-1:0] i_s_arburst
,   input                       i_s_arlock
,   input  [             4-1:0] i_s_arcache
,   input  [             3-1:0] i_s_arprot
,   input  [             4-1:0] i_s_arregion
,   input                       i_s_arvalid
,   output                      o_s_arready

,   output [          TAGW-1:0] o_s_rid
,   output [          DATW-1:0] o_s_rdata
,   output [             2-1:0] o_s_rresp
,   output                      o_s_rlast
,   output                      o_s_rvalid
,   input                       i_s_rready

    //Slave Write wires
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

    // Interrupt
,   output                      interrupt_out
,   input                       intx_msi_request
,   output                      intx_msi_grant

    //==================================
    // Unused Signals
    //==================================

    // AXI Slave: S_AXI_CTL
,   input  [           32 -1:0] i_s_ctl_araddr
,   input                       i_s_ctl_arvalid
,   output                      o_s_ctl_arready

,   output [           32 -1:0] o_s_ctl_rdata
,   output [            2 -1:0] o_s_ctl_rresp
,   output                      o_s_ctl_rvalid
,   input                       i_s_ctl_rready

,   input  [           32 -1:0] i_s_ctl_awaddr
,   input                       i_s_ctl_awvalid
,   output                      o_s_ctl_awready

,   input  [           32 -1:0] i_s_ctl_wdata
,   input  [            4 -1:0] i_s_ctl_wstrb
,   input                       i_s_ctl_wvalid
,   output                      o_s_ctl_wready

,   output [            2 -1:0] o_s_ctl_bresp
,   output                      o_s_ctl_bvalid
,   input                       i_s_ctl_bready

    // pcie3_cfg_msix
,   input  [           64 -1:0] cfg_interrupt_msix_address
,   input  [           32 -1:0] cfg_interrupt_msix_data
,   output [            4 -1:0] cfg_interrupt_msix_enable
,   output                      cfg_interrupt_msix_fail
,   input                       cfg_interrupt_msix_int
,   output [            4 -1:0] cfg_interrupt_msix_mask
,   output                      cfg_interrupt_msix_sent
,   output [            8 -1:0] cfg_interrupt_msix_vf_enable
,   output [            8 -1:0] cfg_interrupt_msix_vf_mask

    // pcie_7x)mgt
,   input  [            8 -1:0] pci_exp_rxn
,   input  [            8 -1:0] pci_exp_rxp
,   output [            8 -1:0] pci_exp_txn
,   output [            8 -1:0] pci_exp_txp
);

    localparam CLK_PERIOD = (1000/CLKOFREQ);
    reg clk_out;
    reg rst_n_out;
    always
    begin
        clk_out = 0;
        #(CLK_PERIOD/2);
        clk_out = 1;
        #(CLK_PERIOD/2);
    end

    initial
    begin
	$display("[%t] : System Reset(axi4_ip/rst_n_out) Is Asserted...", $realtime);
        rst_n_out = 0;
        #(CLK_PERIOD*100.01);
	$display("[%t] : System Reset(axi4_ip/rst_n_out) Is DeAsserted...", $realtime);
        rst_n_out = 1;
    end

    import "DPI-C" function void    C_setup_pcie_connection();
    import "DPI-C" function void    C_poll(output int req_type, output longint addr, output int len, 
                                           output int size, output int strb[0:NSTB-1], output byte data[0:DTMP-1]);
    import "DPI-C" function void    C_qemu_step();
    
    int strb[0:NSTB-1];
    byte data[0:DTMP-1];
    longint addr;
    int len;
    int size;
    int req_type;
    int i;
    
    reg req_m_rvalid;
    reg req_m_wvalid;
    reg req_s_rvalid;
    
    enum { NOOP, M_RD, M_WR, S_RD } qemu_req_type;
    
    logic send_m_read;
    logic send_m_write;
    logic send_s_read;
    always@(posedge o_axi_aclk) begin
        send_m_read = 0;
        send_m_write= 0;
        send_s_read = 0;

        C_poll(req_type, addr, len, size, strb, data);
        
        case (req_type)
            M_RD: begin
                $display("V: Q->H addr %x len %x size %x", addr, len, size);
                send_m_read = 1;
            end
            M_WR: begin
                $display("V: Q->H addr %x len %x size %x strb %x", addr, len, size, strb[0]);
                send_m_write = 1;
            end
            S_RD: begin
                $display("V: H->Q Read response %x%x%x%x", data[3], data[2], data[1], data[0]); 
                send_s_read = 1;
            end
        endcase
        
        req_m_rvalid <= send_m_read;
        req_m_wvalid <= send_m_write;
        req_s_rvalid <= send_s_read;
    end

    always@(posedge o_axi_aclk) begin
        C_qemu_step();
    end

    //---------------------------------------------------------------------
    // Instance
    //---------------------------------------------------------------------
    axi4_m_r #(
    .TAGW(TAGW),
    .ADRW(ADRW),
    .DATW(DATW),
    .SIZE(SIZE),
    .STBW(STBW),
    .DTMP(DTMP)
    ) axi4_m_r_inst (
       .i_clk        (o_axi_aclk            )
    ,  .i_rst_n      (o_axi_aresetn         )

    ,  .req_addr     (addr                  )
    ,  .req_len      (len                   )
    ,  .req_size     (size                  )
    ,  .req_valid    (req_m_rvalid          )
    
    ,  .o_m_arid     (o_m_arid              )
    ,  .o_m_araddr   (o_m_araddr            )
    ,  .o_m_arlen    (o_m_arlen             )
    ,  .o_m_arsize   (o_m_arsize            )
    ,  .o_m_arburst  (o_m_arburst           )
    ,  .o_m_arlock   (o_m_arlock            )
    ,  .o_m_arcache  (o_m_arcache           )
    ,  .o_m_arprot   (o_m_arprot            )
    ,  .o_m_arregion (o_m_arregion          )
    ,  .o_m_arvalid  (o_m_arvalid           )
    ,  .i_m_arready  (i_m_arready           )

    ,  .i_m_rid      (i_m_rid               )
    ,  .i_m_rdata    (i_m_rdata             )
    ,  .i_m_rresp    (i_m_rresp             )
    ,  .i_m_rlast    (i_m_rlast             )
    ,  .i_m_rvalid   (i_m_rvalid            )
    ,  .o_m_rready   (o_m_rready            )
    );

    axi4_m_w #(
    .TAGW(TAGW),
    .ADRW(ADRW),
    .DATW(DATW),
    .SIZE(SIZE),
    .STBW(STBW),
    .DTMP(DTMP),
    .NSTB(NSTB)
    ) axi4_m_w_inst (
       .i_clk        (o_axi_aclk            )
    ,  .i_rst_n      (o_axi_aresetn         )

    ,  .req_addr     (addr                  )
    ,  .req_len      (len                   )
    ,  .req_size     (size                  )
    ,  .req_strb     (strb                  )
    ,  .req_data     (data                  )
    ,  .req_valid    (req_m_wvalid          )

    ,  .o_m_awid     (o_m_awid              )
    ,  .o_m_awaddr   (o_m_awaddr            )
    ,  .o_m_awlen    (o_m_awlen             )
    ,  .o_m_awsize   (o_m_awsize            )
    ,  .o_m_awburst  (o_m_awburst           )
    ,  .o_m_awlock   (o_m_awlock            )
    ,  .o_m_awcache  (o_m_awcache           )
    ,  .o_m_awprot   (o_m_awprot            )
    ,  .o_m_awregion (o_m_awregion          )
    ,  .o_m_awvalid  (o_m_awvalid           )
    ,  .i_m_awready  (i_m_awready           )

    ,  .o_m_wid      (o_m_wid               )
    ,  .o_m_wdata    (o_m_wdata             )
    ,  .o_m_wlast    (o_m_wlast             )
    ,  .o_m_wstrb    (o_m_wstrb             )
    ,  .o_m_wvalid   (o_m_wvalid            )
    ,  .i_m_wready   (i_m_wready            )

    ,  .i_m_bid      (i_m_bid               )
    ,  .i_m_bresp    (i_m_bresp             )
    ,  .i_m_bvalid   (i_m_bvalid            )
    ,  .o_m_bready   (o_m_bready            )
    );

    axi4_s_r #(
    .TAGW(TAGW),
    .ADRW(ADRW),
    .DATW(DATW),
    .SIZE(SIZE),
    .STBW(STBW),
    .DTMP(DTMP),
    .NSTB(NSTB)
    ) axi4_s_r_inst (
         .i_clk        (o_axi_aclk      )
    ,    .i_rst_n      (o_axi_aresetn   )

    ,    .req_data  (data               )
    ,    .req_valid (req_s_rvalid       )

    ,    .i_s_arid     (i_s_arid        )
    ,    .i_s_araddr   (i_s_araddr      )
    ,    .i_s_arlen    (i_s_arlen       )
    ,    .i_s_arsize   (i_s_arsize      )
    ,    .i_s_arburst  (i_s_arburst     )
    ,    .i_s_arlock   (i_s_arlock      )
    ,    .i_s_arcache  (i_s_arcache     )
    ,    .i_s_arprot   (i_s_arprot      )
    ,    .i_s_arregion (i_s_arregion    )
    ,    .i_s_arvalid  (i_s_arvalid     )
    ,    .o_s_arready  (o_s_arready     )

    ,    .o_s_rid      (o_s_rid         )
    ,    .o_s_rdata    (o_s_rdata       )
    ,    .o_s_rresp    (o_s_rresp       )
    ,    .o_s_rlast    (o_s_rlast       )
    ,    .o_s_rvalid   (o_s_rvalid      )
    ,    .i_s_rready   (i_s_rready      )
    );

    axi4_s_w #(
    .TAGW(TAGW),
    .ADRW(ADRW),
    .DATW(DATW),
    .STBW(STBW),
    .DTMP(DTMP),
    .STMP(DTMP/32)
    ) axi4_s_w_inst (
         .i_clk        (o_axi_aclk      )
    ,    .i_rst_n      (o_axi_aresetn   )

    ,    .i_s_awid     (i_s_awid        )
    ,    .i_s_awaddr   (i_s_awaddr      )
    ,    .i_s_awlen    (i_s_awlen       )
    ,    .i_s_awsize   (i_s_awsize      )
    ,    .i_s_awburst  (i_s_awburst     )
    ,    .i_s_awlock   (i_s_awlock      )
    ,    .i_s_awcache  (i_s_awcache     )
    ,    .i_s_awprot   (i_s_awprot      )
    ,    .i_s_awregion (i_s_awregion    )
    ,    .i_s_awvalid  (i_s_awvalid     )
    ,    .o_s_awready  (o_s_awready     )

    ,    .i_s_wid      (i_s_wid         )
    ,    .i_s_wdata    (i_s_wdata       )
    ,    .i_s_wlast    (i_s_wlast       )
    ,    .i_s_wstrb    (i_s_wstrb       )
    ,    .i_s_wvalid   (i_s_wvalid      )
    ,    .o_s_wready   (o_s_wready      )

    ,    .o_s_bid      (o_s_bid         )
    ,    .o_s_bresp    (o_s_bresp       )
    ,    .o_s_bvalid   (o_s_bvalid      )
    ,    .i_s_bready   (i_s_bready      )

    );

    //INTERRUPT
    axi4_s_i #(
    .TAGW(TAGW),
    .ADRW(ADRW),
    .DATW(DATW),
    .SIZE(SIZE),
    .STBW(STBW),
    .DTMP(DTMP)
    ) axi4_s_i_inst (
         .i_clk        (o_axi_aclk      )
    ,    .i_rst_n      (o_axi_aresetn   )

    ,    .interrupt_out    (interrupt_out   )
    ,    .intx_msi_request (intx_msi_request)
    ,    .intx_msi_grant   (intx_msi_grant  )
    );

    //---------------------------------------------------------------------
    // Main
    //---------------------------------------------------------------------
    initial
    begin
	$display("[%t] : V: axi4_ip: before C_setup_pcie_connection().", $realtime);
        C_setup_pcie_connection();
	$display("[%t] : V: axi4_ip: after C_setup_pcie_connection().", $realtime);
        wait(~i_sys_rst_n);
	$display("[%t] : V: axi4_ip: after System Reset(wait(~i_sys_rst_n)) .", $realtime);
    end

    assign  o_axi_aclk          = clk_out   ;
    assign  o_axi_aresetn       = rst_n_out ;
    assign  interrupt_out       = 0         ;
    assign  intx_msi_grant      = 0         ;

    assign  o_s_ctl_arready     = 0         ;
    assign  o_s_ctl_rdata       = 0         ;
    assign  o_s_ctl_rresp       = 0         ;
    assign  o_s_ctl_rvalid      = 0         ;
    assign  o_s_ctl_awready     = 0         ;
    assign  o_s_ctl_wready      = 0         ;
    assign  o_s_ctl_bresp       = 0         ;
    assign  o_s_ctl_bvalid      = 0         ;

    assign  cfg_interrupt_msix_enable       = 0     ;
    assign  cfg_interrupt_msix_fail         = 0     ;
    assign  cfg_interrupt_msix_mask         = 0     ;
    assign  cfg_interrupt_msix_sent         = 0     ;
    assign  cfg_interrupt_msix_vf_enable    = 0     ;
    assign  cfg_interrupt_msix_vf_mask      = 0     ;



endmodule
