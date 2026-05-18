
module input_buffer (
    input  logic        clk,
    input  logic        rst,
	input  logic 		comp_en,
    input  logic        wr_en,
    input  logic [4:0]  wr_addr,   // 0..31
    input  logic [7:0]  wr_data,

    input  logic [4:0]  rd_addr,
  output logic [31:0]  rd_data
);

    // 32 x 8-bit memory
    logic [7:0] mem [0:31];

    // write logic
    always_ff @(posedge clk) begin
      if(rst)
        mem[wr_addr]<=0;
        if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // read logic
  assign rd_data =(comp_en) ? {mem[rd_addr],mem[rd_addr+1],mem[rd_addr+2],mem[rd_addr+3]} : 32'd0;

`ifdef FORMAL

    logic f_past_valid = 1'b0;
    always_ff @(posedge clk)
        f_past_valid <= 1'b1;


    always_ff @(posedge clk) begin
        assume(wr_addr < 32);
        assume(rd_addr < 29);
    end

    // Write correctness
    always_ff @(posedge clk) begin
        if (f_past_valid && $past(wr_en)) begin
            assert(mem[$past(wr_addr)] == $past(wr_data));
        end
    end

    // Read gating
    always_ff @(posedge clk) begin
        if (!comp_en)
            assert(rd_data == 32'd0);
    end

    // Read packing correctness
    always_ff @(posedge clk) begin
        if (comp_en) begin
            assert(rd_data[31:24] == mem[rd_addr]);
            assert(rd_data[23:16] == mem[rd_addr+1]);
            assert(rd_data[15:8]  == mem[rd_addr+2]);
            assert(rd_data[7:0]   == mem[rd_addr+3]);
        end
    end

`endif

endmodule