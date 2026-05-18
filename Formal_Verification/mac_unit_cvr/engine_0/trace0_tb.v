`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [7:0] PI_x;
  wire [0:0] PI_clk = clock;
  reg [0:0] PI_rst;
  reg [0:0] PI_clr;
  reg [6:0] PI_w;
  reg [0:0] PI_en;
  mac_unit UUT (
    .x(PI_x),
    .clk(PI_clk),
    .rst(PI_rst),
    .clr(PI_clr),
    .w(PI_w),
    .en(PI_en)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:107:execute$78  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$82  = 1'b1;
    UUT.en_count = 4'b1000;
    UUT.temp_res = 18'b000000000000000000;

    // state 0
    PI_x = 8'b00000000;
    PI_rst = 1'b0;
    PI_clr = 1'b0;
    PI_w = 7'b0000000;
    PI_en = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_x <= 8'b00000000;
      PI_rst <= 1'b0;
      PI_clr <= 1'b0;
      PI_w <= 7'b0000000;
      PI_en <= 1'b0;
    end

    genclock <= cycle < 1;
    cycle <= cycle + 1;
  end
endmodule
