`include "input_buffer.sv"
`include "mac_unit.sv"
`include "rom_coeff.sv"
`include "controller.sv"
`include "RM_IHPSG13_1P_512x32_c2_bm_bistv.v"

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
  	logic [7:0]	 top_wr_data;
    logic [31:0]  top_rd_data;
  	logic [13:0] rom_data;
//     logic [6:0]  coeff_hi;
//     logic [6:0]  coeff_lo;
  	logic [6:0] a_mac;
    logic [17:0] mac_acc [0:3];
  	logic [31:0] result_ram;
  	logic [31:0] ram_read_data;
    
  	logic [8:0]  read_index;
  	logic [8:0] ram_addr;
  	logic [31:0] read_shift;
  	logic [1:0]      half_sel;
  	logic 	     second_ram_data;
  	logic [1:0] ram_wrcnt;
  	logic [3:0] read_addr;
  logic read_valid;
  
    logic  [7:0] x1,x2,x3,x4;

    // ===================== CONTROLLER =====================
    controller u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .wr_data(input_data),
      	.coeff_data(rom_data),
        .inbuf_wr_en(top_wr_en),
        .inbuf_wr_addr(top_wr_addr),
      	.inbuf_wr_data(top_wr_data),
        .mac_en(mac_en),
        .mac_clr(mac_clr),
        .rom_addr(rom_addr),
        .inbuf_rd_addr(top_rd_addr),
      	.coeff_out(a_mac),
        .save_result(save_result),
        .res_index(res_index),
      	.ram_write_cnt(ram_wrcnt),
      	.ram_read(read_ram),
      	.addr_read(read_addr),
        .finish(finish)
    );

    // ===================== INPUT BUFFER ====================
    input_buffer u_input_buffer (
        .clk(clk),
        .rst(rst),
        .comp_en(mac_en),
        .wr_en(top_wr_en),
        .wr_addr(top_wr_addr),
      	.wr_data(top_wr_data),
        .rd_addr(top_rd_addr),
        .rd_data(top_rd_data)
    );

    // ========================= ROM =========================
    rom_coeff u_rom (
        .clk(clk),
        .comp_en(mac_en),
        .addr(rom_addr),
        .data(rom_data)
    );

//     assign coeff_hi = rom_data[13:7];
//     assign coeff_lo = rom_data[6:0];

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

  	// RAM instantiation
RM_IHPSG13_1P_512x32_c2_bm_bist u_ram (
    .A_CLK(clk),               // Connect the clock
    .A_MEN(1'b1),              // Memory enable (always on)
    .A_WEN(save_result),       // Write enable (triggered when save_result is active)
  	.A_REN(finish | read_ram),          // Read enable (controlled by read_ram signal)
  	.A_ADDR(ram_addr),        // Address for writing data, could be controlled by res_index
  	.A_DIN(result_ram), // Data to be written (MAC results)
  	.A_DOUT(read_shift),      // Data read from RAM (connected to top_rd_data)
    .A_BM(32'b11111111111111111111111111111111), // Mask bits (set to all 1s for full write)
    .A_BIST_EN(1'b0),          // BIST mode disabled
    .A_BIST_MEN(1'b0),         // BIST memory enable disabled
    .A_BIST_WEN(1'b0),         // BIST write enable disabled
  	.A_BIST_REN(1'b0),         // BIST read enable disabled,
  	.A_BIST_ADDR(9'b0),
  	.A_BIST_DIN(32'd0),
  	.A_BIST_BM(32'd0),
  	.A_BIST_CLK(1'b0),          // BIST clock signal (not used in this case)
    .A_DLY(1'b1)               // Delay setting (recommended to tie to 1)
);
  
//     RM_IHPSG13_1P_512x32_c2_bm_bist u_ram(
//       .A_CLK(clk),
//       .A_MEN(1'b1),
//       .A_WEN(),
//       .A_REN(read_ram),
//       .A_ADDR(),
//       .A_DIN(),
//       .A_DLY(),
//       .A_DOUT(),
//       .A_BM(),
//       .A_BIST_CLK(1'b0),
//       .A_BIST_EN(1'b0),
//       .A_BIST_MEN(1'b0),
//       .A_BIST_WEN(1'b0),
//       .A_BIST_REN(1'b0),
//       .A_BIST_ADDR(1'b0),
//       .A_BIST_DIN(1'b0),
//       .A_BIST_BM(1'b0)
//     );
  
    // ================== STORE RESULTS ======================
//     always_ff @(posedge clk) begin
//       if (save_result) begin
//         result_ram[res_index] <= mac_acc[0];
//         result_ram[res_index+1] <= mac_acc[1];
//         result_ram[res_index+2] <= mac_acc[2];
//         result_ram[res_index+3] <= mac_acc[3];
//       end 
//     end
  always_ff @(posedge clk) begin
    if(rst)
      ram_wrcnt <= 0;
    else if (save_result)
      ram_wrcnt <= ram_wrcnt + 1;
  end
//   always_ff @(posedge clk) begin
//     if(rst)
//       result_ram <= 32'd0;
//     if(save_result) begin
//     case (ram_wrcnt)
//         2'd0: result_ram <= {14'd0, mac_acc[0]};
//         2'd1: result_ram <= {14'd0, mac_acc[1]};
//         2'd2: result_ram <= {14'd0, mac_acc[2]};
//         2'd3: result_ram <= {14'd0, mac_acc[3]};
// //         default: result_ram <= 32'd0;
//     endcase
//     end
// end
  
  always_comb begin
    if(save_result) begin
    case (ram_wrcnt)
        2'd0: result_ram = {14'd0, mac_acc[0]};
        2'd1: result_ram = {14'd0, mac_acc[1]};
        2'd2: result_ram = {14'd0, mac_acc[2]};
        2'd3: result_ram = {14'd0, mac_acc[3]};
        default: result_ram = 32'd0;
    endcase
    end
end

//       always_ff @(posedge clk) begin
//         if(rst) begin
//           result_ram <= 32'd0;
//         end else if (save_result) begin
//           if(second_ram_data) begin
//           result_ram <= {mac_acc[1][17:2],mac_acc[0][17:2]};
//         	second_ram_data <= 1'b1;
//         end else begin
//           result_ram <= {mac_acc[3][17:2],mac_acc[2][17:2]};
//           	second_ram_data <= 1'b0;
// //         result_ram[res_index+2] <= mac_acc[2];
// //         result_ram[res_index+3] <= mac_acc[3];
//       end 
//     end
//       end
  
  assign ram_addr = (save_result== 1'b1) ? res_index : (!half_sel) ? (read_index) : (read_index+1);
    // ===================== READ INTERFACE =================



// always_ff @(posedge clk) begin
//     if (rst)
//         read_valid <= 1'b0;
//     else
//         read_valid <= read_ram;
// end
  

   always_ff @(posedge clk) begin
        if (rst) begin
            read_index <= 0;
            half_sel   <= 0;
            read_data_out <= 0;
        end
     else if (read_ram) begin
            if (!half_sel) begin
                read_data_out <= read_shift[8:0];
                half_sel <= 1'b1;
            end else begin
                read_data_out <= read_shift[17:9];
              	read_index <= read_index + 1;
                half_sel <= 1'b0;
//                 read_index <= read_index + 1;
            end
        end
        else begin
//           read_index <= 0;
            half_sel <= 0;
            read_data_out <= 0;
        end
    end

          
// //     always_ff @(posedge clk) begin
// //         if (rst) begin
// //             read_index <= 0;
// //             half_sel   <= 0;
// //             read_data_out <= 0;
// //         end else if (read_ram) begin
// //           if (half_sel== 2'b00) begin
// //             read_data_out <= read_shift[7:0];
// //                 half_sel <= half_sel + 1;
// //           end else if (half_sel == 2'b01) begin
// //               read_data_out <= read_shift[15:8];
// //                 half_sel <= half_sel + 1;
// // //                 read_index <= read_index + 1;
// //           end else if (half_sel == 2'b10) begin
// //             read_data_out <=  read_shift[23:16];
// //             half_sel <= half_sel + 1;
// //           end else begin
// //             read_data_out <= read_shift[31:24];
// //             read_index <= read_index + 1;
// //         end
// //           end else begin
// //           	read_index <= 0;
// //             half_sel   <= 0;
// //             read_data_out <= 0;
// //         end
// //     end

endmodule
