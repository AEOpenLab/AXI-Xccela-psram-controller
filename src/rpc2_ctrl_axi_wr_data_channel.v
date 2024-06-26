module rpc2_ctrl_axi_wr_data_channel (
   // Outputs
   AXI_WREADY, wready_done, axi2ip_data_valid, axi2ip_strb, 
   axi2ip_data, wdat_rd_en, wdat_wr_en, wdat_din, 
   // Inputs
   clk, reset_n, AXI_WDATA, AXI_WSTRB, AXI_WLAST, AXI_WVALID, 
   wready_req, wready_size, wready_fixed, wready_strb, ip_clk, 
   ip_reset_n, ip_data_ready, ip_data_size, wdat_dout, wdat_empty, 
   wdat_full, wdat_pre_full
   );
//   parameter C_AXI_ID_WIDTH   = 'd4;
   parameter C_AXI_DATA_WIDTH = 'd32;
   
   localparam WDAT_FIFO_DATA_WIDTH = C_AXI_DATA_WIDTH+((C_AXI_DATA_WIDTH*2)/8);
   
   // Global System Signals
   input clk;
   input reset_n;

   // Write Data Channel Signals
   input [C_AXI_DATA_WIDTH-1:0] AXI_WDATA;
   input [(C_AXI_DATA_WIDTH/8)-1:0] AXI_WSTRB;
   input                            AXI_WLAST;
   input                            AXI_WVALID;
   output                           AXI_WREADY;

   input                            wready_req;
   input [1:0]                      wready_size;
   input                            wready_fixed;
   input [(C_AXI_DATA_WIDTH/8)-1:0] wready_strb;
   output                           wready_done;

   // for IP
   input                            ip_clk;
   input                            ip_reset_n;
   
   input                            ip_data_ready;
   output                           axi2ip_data_valid;
   output [(C_AXI_DATA_WIDTH/8)-1:0] axi2ip_strb;
   output [C_AXI_DATA_WIDTH-1:0]     axi2ip_data;
   
   input [1:0]                       ip_data_size;


   // WDAT FIFO
   output                            wdat_rd_en;
   output                            wdat_wr_en;
   output [WDAT_FIFO_DATA_WIDTH-1:0] wdat_din;
   input [WDAT_FIFO_DATA_WIDTH-1:0]  wdat_dout;
   input                             wdat_empty;
   input                             wdat_full;
   input                             wdat_pre_full;
   
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics

   reg                               AXI_WREADY;
   reg                               wready_valid;
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   // End of automatics
   

   //--------------------------------------
   // AXI
   //--------------------------------------
   // AXI_WREADY
   always @(posedge clk or negedge reset_n) begin
      if (~reset_n)
        AXI_WREADY <= 1'b0;
      else if (wdat_pre_full || wready_done)
        AXI_WREADY <= 1'b0;
      else if (wready_req || wready_valid)
        AXI_WREADY <= 1'b1;
   end
   
   // wready_valid
   always @(posedge clk or negedge reset_n) begin
      if (~reset_n)
        wready_valid <= 1'b0;
      else if (wready_req)
        wready_valid <= 1'b1;
      else if (wready_done)
        wready_valid <= 1'b0;
   end

   rpc2_ctrl_axi_wr_data_control
//     #(C_AXI_ID_WIDTH,
     #(C_AXI_DATA_WIDTH,
       WDAT_FIFO_DATA_WIDTH)
     axi_wr_data_control (/*AUTOINST*/
                          // Outputs
                          .wdat_wr_en   (wdat_wr_en),
                          .wdat_rd_en   (wdat_rd_en),
                          .wdat_din     (wdat_din[WDAT_FIFO_DATA_WIDTH-1:0]),
                          .wready_done  (wready_done),
                          .axi2ip_data_valid(axi2ip_data_valid),
                          .axi2ip_strb  (axi2ip_strb[(C_AXI_DATA_WIDTH/8)-1:0]),
                          .axi2ip_data  (axi2ip_data[C_AXI_DATA_WIDTH-1:0]),
                          // Inputs
                          .clk          (clk),
                          .reset_n      (reset_n),
                          .AXI_WDATA    (AXI_WDATA[C_AXI_DATA_WIDTH-1:0]),
                          .AXI_WSTRB    (AXI_WSTRB[(C_AXI_DATA_WIDTH/8)-1:0]),
                          .AXI_WLAST    (AXI_WLAST),
                          .AXI_WVALID   (AXI_WVALID),
                          .AXI_WREADY   (AXI_WREADY),
                          .wdat_empty   (wdat_empty),
                          .wdat_full    (wdat_full),
                          .wdat_dout    (wdat_dout[WDAT_FIFO_DATA_WIDTH-1:0]),
                          .wready_req   (wready_req),
                          .wready_size  (wready_size[1:0]),
                          .wready_fixed (wready_fixed),
                          .wready_strb  (wready_strb[(C_AXI_DATA_WIDTH/8)-1:0]),
                          .ip_clk       (ip_clk),
                          .ip_reset_n   (ip_reset_n),
                          .ip_data_size (ip_data_size[1:0]),
                          .ip_data_ready(ip_data_ready));
   
endmodule
