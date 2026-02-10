`timescale 1ns / 1ps

module tb;
    // DUT ports
    logic       clk = 0;
    logic       rst = 1;
    logic [7:0] i_input_data = 8'b0;
    logic       i_start = 1'b0;
    logic       i_read_ram = 1'b0;
    logic [8:0] o_read_data_out; // NOTE: Output width halved to reduce pin count - will be time-multiplexed
    logic       o_finish;

    logic [7:0]  input_stimuli[2048];
    logic [31:0] expected_results[512];
    logic [31:0] calculated_results[512];


    localparam CLK_PERIOD = 10;
	localparam MAX_ITER = 32;  // Maximum number of values

    // MM_TOP Device Under Test Instance
    // Change module and port names if different
    mm_top dut (
        .clk            (clk),
        .rst            (rst),
        .input_data     (i_input_data),
        .start          (i_start),
        .read_ram       (i_read_ram),
        .read_data_out  (o_read_data_out),
        .finish         (o_finish)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // This task loads the corresponding values of the given matrix # from the input stimuli
    // The MATLAB script defines the element ordering (column-wise by default). 
    task automatic load_matrix(input [7:0] matrix_idx);
        integer stimuli_start = matrix_idx*32;      
      	integer stimuli_end = matrix_idx*32 + 32;
      	integer i;

        @(posedge clk);
      	i_start = 1'b1;
      	for (i = stimuli_start; i < stimuli_end; i++) begin
            i_input_data = input_stimuli[i];
            @(posedge clk);
        end

        i_start = 1'b0;
    endtask

    task automatic read_result(input int matrix_idx);
	int r;
    int chunk;
    int base;

    base = matrix_idx * 16;  // 16 outputs per matrix

    i_read_ram = 1'b1;
    @(posedge clk);
//       @(posedge clk);
    for (r = 0; r < 16; r++) begin

        calculated_results[base + r] = 32'd0;

        for (chunk = 0; chunk < 2; chunk++) begin
            @(posedge clk);
          

            if (chunk == 0) begin
                // LOWER 9 BITS
                calculated_results[base + r][8:0] = o_read_data_out;
//                 $display("  Lower 9 bits stored: %b", o_read_data_out);
            end
            else begin
                // UPPER 9 BITS
                calculated_results[base + r][17:9] = o_read_data_out;
//                 $display("  Upper 9 bits stored: %b", o_read_data_out);
            end
        end
		
    end
    i_read_ram = 1'b0;

endtask

  
    initial begin
		integer i = 0;
        integer errors=0;
      	$dumpfile("wave.vcd");      // name of VCD file
      	$dumpvars(0, tb);           // dump everything under module "tb"
      
        // reset release - active high is assumed
        rst = 1;
      	repeat(5) @(posedge clk); 
      	rst = 0;
      	@(posedge clk);
      
        // Read the stimuli and result files to corresponding arrays
        $readmemb("input_stimuli.txt", input_stimuli);
        $readmemb("output_results.txt", expected_results);
		

		while (i < MAX_ITER) begin
    		load_matrix(i);
    		wait(o_finish);        // Wait for the finish signal to be true
    		@(posedge clk);        // Wait for a clock cycle
          	read_result(i);
    		i++;                   // Increment the counter
        end
      
      for (integer k = 0; k < 256; k++) begin
            // compare 18-bit values only
    if (calculated_results[k][17:0] !== expected_results[k][17:0]) begin
        $display("Mismatch at index %0d:", k);
        $display("   Expected = %018b (%0d)", expected_results[k][17:0], expected_results[k][17:0]);
        $display("   Got      = %018b (%0d)\n", calculated_results[k][17:0], calculated_results[k]			[17:0]);
        errors++;
    end
end
        if (errors == 0) begin
            $display(" TEST PASSED ");
        end else begin 
            $display(" TEST FAILED with %0d mismatches ", errors);
        end
        $finish;
    end

endmodule
