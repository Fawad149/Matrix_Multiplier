`include "input_buffer.sv"
`include "mac_unit.sv"
`include "rom_coeff.sv"
`include "controller.sv"
// `include "RM_IHPSG13_1P_512x32_c2_bm_bist.v"

module mm_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  input_data,
    input  logic        start,
    input  logic        read_ram,
    output logic [8:0]  read_data_out,
    output logic        finish
);

    // ---------- Control Signals ----------
    logic        top_wr_en;
    logic [4:0]  top_wr_addr;
    logic        mac_en;
    logic        mac_clr;
    logic [3:0]  rom_addr;
    logic [4:0]  top_rd_addr;
    logic        save_result;
  	logic [8:0]  res_index;
    
    // ---------- Data Signals ----------
    logic [31:0]  top_rd_data;
  	logic [13:0] rom_data;
  	logic [6:0] a_mac;
    logic [17:0] mac_acc [0:3];
  	logic [31:0] result_ram;
  
  
	//---------------RAM Controls---------    
  	logic [8:0]  read_index;
  	logic [8:0] ram_addr;
  	logic [17:0] read_shift;
  	logic       half_sel;
  	logic [1:0] ram_wrcnt;
  	logic  read_count;
  
  	//---------MAC Inputs------------------
    logic  [7:0] x1,x2,x3,x4;

    // ===================== CONTROLLER =====================
    controller u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
      	.coeff_data(rom_data),
        .inbuf_wr_en(top_wr_en),
        .inbuf_wr_addr(top_wr_addr),
        .mac_en(mac_en),
        .mac_clr(mac_clr),
        .rom_addr(rom_addr),
        .inbuf_rd_addr(top_rd_addr),
      	.coeff_out(a_mac),
        .save_result(save_result),
        .res_index(res_index),
      	.ram_write_cnt(ram_wrcnt),
        .finish(finish)
    );

    // ===================== INPUT BUFFER ====================
    input_buffer u_input_buffer (
        .clk(clk),
        .rst(rst),
        .comp_en(mac_en),
        .wr_en(top_wr_en),
        .wr_addr(top_wr_addr),
      	.wr_data(input_data),
        .rd_addr(top_rd_addr),
        .rd_data(top_rd_data)
    );

    // ========================= ROM =========================
    rom_coeff u_rom (
        .comp_en(mac_en),
        .addr(rom_addr),
        .data(rom_data)
    );

    // ========================= MAC =========================
    assign x1 = top_rd_data[31:24];
    assign x2 = top_rd_data[23:16];
    assign x3 = top_rd_data[15:8];
    assign x4 = top_rd_data[7:0]; 
  
    mac_unit u_mac_1 (
        .clk(clk),
        .rst(rst),
        .en(mac_en),
        .clr(mac_clr),
        .x(x1),
      	.w(a_mac),
        .acc(mac_acc[0])
    );
  
  	
  
    mac_unit u_mac_2 (
        .clk(clk),
        .rst(rst),
        .en(mac_en),
        .clr(mac_clr),
        .x(x2),
      	.w(a_mac),
        .acc(mac_acc[1])
    );
  
     mac_unit u_mac_3 (
        .clk(clk),
        .rst(rst),
        .en(mac_en),
        .clr(mac_clr),
        .x(x3),
      	.w(a_mac),
        .acc(mac_acc[2])
    );
  
    mac_unit u_mac_4 (
        .clk(clk),
        .rst(rst),
        .en(mac_en),
        .clr(mac_clr),
        .x(x4),
      	.w(a_mac),
        .acc(mac_acc[3])
    );

    // ========================= RAM =========================
  	RM_IHPSG13_1P_512x32_c2_bm_bist u_ram (
        .A_CLK(clk),              
        .A_MEN(1'b1),             
        .A_WEN(save_result),      
  	    .A_REN(read_ram),         
  	    .A_ADDR(ram_addr),        
  	    .A_DIN(result_ram), 
  	    .A_DOUT(read_shift),      
        .A_BM(32'b11111111111111111111111111111111),
        .A_BIST_EN(1'b0),          // BIST mode disabled
        .A_BIST_MEN(1'b0),         // BIST memory enable disabled
        .A_BIST_WEN(1'b0),         // BIST write enable disabled
  	    .A_BIST_REN(1'b0),         // BIST read enable disabled,
  	    .A_BIST_ADDR(9'b0),
  	    .A_BIST_DIN(32'd0),
  	    .A_BIST_BM(32'd0),
  	    .A_BIST_CLK(1'b0),         
        .A_DLY(1'b1)               
	);
  
  // ========================= RAM Operations =========================
  
  //-------Write Interface------------
  always_ff @(posedge clk) begin
    if(rst)
      ram_wrcnt <= 0;
    else if (save_result)
      ram_wrcnt <= ram_wrcnt + 1;
  end
  
  always_comb begin
    if(save_result) begin
    case (ram_wrcnt)
        2'd0: result_ram = {14'd0, mac_acc[0]};
        2'd1: result_ram = {14'd0, mac_acc[1]};
        2'd2: result_ram = {14'd0, mac_acc[2]};
        2'd3: result_ram = {14'd0, mac_acc[3]};
        default: result_ram = 32'd0;
    endcase
    end else begin
        result_ram = 32'd0;
    end
end
  
  assign ram_addr = (save_result== 1'b1) ? res_index : (!half_sel) ? (read_index) : (read_index+1);

  //-------Read Interface------------
    
  always_ff @(posedge clk) begin
        if (rst) begin
            read_index <= 0;
            half_sel   <= 0;
            read_data_out <= 0;
          	read_count <= 0;
        end
     else if (read_ram) begin
       if (read_count == 1'b1) begin
            if (!half_sel) begin
                read_data_out <= read_shift[8:0];
                half_sel <= 1'b1;
            end else begin
                read_data_out <= read_shift[17:9];
              	read_index <= read_index + 1;
                half_sel <= 1'b0;
            end
        end
        else begin
          read_count <= 1'b1;
        end
        
         end
        else begin
            half_sel <= 0;
            read_data_out <= 0;
          	read_count <= 0;
        end

   end


          

endmodule
