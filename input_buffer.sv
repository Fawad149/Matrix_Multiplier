
module input_buffer (
    input  logic        clk,
    input  logic        rst,
	input  logic 		comp_en,
    input  logic        wr_en,
    input  logic [4:0]  wr_addr,   // 0..31
    input  logic [7:0]  wr_data,

    input  logic [4:0]  rd_addr,
    output logic [7:0]  rd_data
);

    // 32 x 8-bit memory
    logic [7:0] mem [0:31];

    // write logic
    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // read logic
  assign rd_data =(comp_en) ? mem[rd_addr] : 8'd0;

endmodule
