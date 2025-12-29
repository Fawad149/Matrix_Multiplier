module mac_unit (
    input  logic        clk,
    input  logic        rst,

    input  logic        en,
    input  logic        clr,

    input  logic  [7:0]  x,
  	input  logic  [6:0]  w,

  output logic  [17:0] acc
);

  logic  [14:0] prod;
  logic [17:0] temp_res;

    always_ff @(posedge clk) begin
      if (rst || clr)
          temp_res <= 18'd0;
        else
            temp_res <= temp_res + prod;
    end

  assign prod = (en) ? (x*w) : 15'd0;
  assign acc = temp_res;
endmodule
