module rom_coeff (
  	input  logic 		comp_en,
    input  logic [3:0]  addr,        // 0..15
  	output logic [13:0] data        // matches the 16-bit lines you provided
);

    always_comb begin
      if(comp_en) begin
        case (addr)
            4'd0:  data = 14'b00000110010110;
            4'd1:  data = 14'b11110011111111;
            4'd2:  data = 14'b00010000000011;
            4'd3:  data = 14'b00000010000010;
            4'd4:  data = 14'b00010001111101;
            4'd5:  data = 14'b00000100000100;
            4'd6:  data = 14'b11110000000110;
            4'd7:  data = 14'b00000010000010;
            4'd8:  data = 14'b00100100101000;
            4'd9:  data = 14'b00000110000010;
            4'd10: data = 14'b00100000001001;
            4'd11: data = 14'b00000010000010;
            4'd12: data = 14'b00000010001010;
            4'd13: data = 14'b00001000000000;
            4'd14: data = 14'b00000100001100;
            4'd15: data = 14'b00000010000010;
            default: data = 14'b0;
		endcase
          end else begin
            data = 14'b0;
          end

        
    end

endmodule
