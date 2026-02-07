module mac_unit (
    input  logic        clk,
    input  logic        rst,

    input  logic        en,
    input  logic        clr,

    input  logic  [7:0]  x,
    input  logic  [6:0]  w,

    output logic [17:0]  acc
);

  logic [14:0] prod;
  logic [17:0] temp_res=18'd0;

  // Zero-skip operand isolation
  assign prod = (en && (x != 0) && (w != 0)) ? (x * w) : 15'd0;

  always_ff @(posedge clk) begin
    if (rst || clr)
      temp_res <= 18'd0;
    else
      temp_res <= temp_res + prod;
  end

  assign acc = temp_res;

`ifdef FORMAL

    logic f_past_valid=1'b0;
    always @(posedge clk) begin
        f_past_valid <= 1'b1;
    end

    always @(posedge clk) begin
        if(f_past_valid) begin
            if ($past(rst || clr))
                assert(acc == 0);
            else 
            assert(acc == $past(acc) + $past(prod));
        end
    end
  
    always @(posedge clk) begin
        assume(!(en && clr));
    end
    // 8 consecutive cycles of enable
    logic [3:0] en_count;

    always @(posedge clk) begin
        if (rst || !en) begin
            en_count <= 4'd0;
        end else if (en) begin
            en_count <= en_count + 4'd1;
        end

        cover(en_count == 4'd8);
    end

`endif


endmodule
