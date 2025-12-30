`include "input_buffer.sv"
`include "mac_unit.sv"
`include "rom_coeff.sv"
`include "controller.sv"

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
    logic [3:0]  res_index;
    
    // ---------- Data Signals ----------
  	logic [7:0]	 top_wr_data;
    logic [31:0]  top_rd_data;
  	logic [13:0] rom_data;
//     logic [6:0]  coeff_hi;
//     logic [6:0]  coeff_lo;
  	logic [6:0] a_mac;
    logic [17:0] mac_acc [0:3];
    logic [17:0] result_ram [0:15];
    
    logic [3:0]  read_index;
    logic [17:0] read_shift;
    logic        half_sel;
  
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

    // ================== STORE RESULTS ======================
    always_ff @(posedge clk) begin
      if (save_result) begin
        result_ram[res_index] <= mac_acc[0];
        result_ram[res_index+1] <= mac_acc[1];
        result_ram[res_index+2] <= mac_acc[2];
        result_ram[res_index+3] <= mac_acc[3];
      end 
    end

    // ===================== READ INTERFACE =================


    always_ff @(posedge clk) begin
        if (rst) begin
            read_index <= 0;
            read_shift <= 0;
            half_sel   <= 0;
            read_data_out <= 0;
        end

        else if (read_ram) begin
            if (!half_sel) begin
                read_shift <= result_ram[read_index];
                read_data_out <= result_ram[read_index][8:0];
                half_sel <= 1'b1;
            end else begin
                read_data_out <= read_shift[17:9];
                half_sel <= 1'b0;
                read_index <= read_index + 1;
            end
        end
        else begin
          read_index <= 0;
            half_sel   <= 0;
            read_shift <= 0;
            read_data_out <= 0;
        end
    end

endmodule
