`include "input_buffer.sv"
`include "mac_unit.sv"
`include "rom_coeff.sv"

module mm_top (
    input  logic        clk,
    input  logic        rst,

    input  logic [7:0]  input_data,
    input  logic        start,

    input  logic        read_ram,
    output logic [8:0]  read_data_out,
    output logic        finish
);

    // ---------- FSM ----------
    typedef enum logic [2:0] {
        IDLE,
        LOAD_INPUTS,
        COMPUTE_MAC,
        SAVE_RESULT,
        NEXT_ELEMENT,
        DONE
    } state_t;

    state_t state, next_state;

    // ---------- loop counters ----------
    logic [4:0] input_cnt;
    logic [1:0] row_i;
    logic [1:0] col_j;
    logic [2:0] k_cnt;

    // ---------- input buffer ----------
    logic        inbuf_wr_en;
    logic [4:0]  inbuf_wr_addr;
    logic [7:0]  inbuf_wr_data;
    logic [4:0]  inbuf_rd_addr;
    logic [7:0]  inbuf_rd_data;

    // ---------- ROM ----------
    logic [3:0]  rom_addr;
    logic [15:0] rom_data;
    logic [6:0]  coeff_hi;
    logic [6:0]  coeff_lo;

    // ---------- MAC ----------
    logic        mac_en;
    logic        mac_clr;
    logic [7:0]  mac_x;
    logic [6:0]  mac_w;
    logic [17:0] mac_acc;
  	logic cnt_is_zero_d;
  
  	// ---------- RESULT RAM ----------
    logic [17:0] result_ram [0:15];    // 16 outputs = 4x4 matrix
    logic [3:0]  res_index;
  	logic prev_read_ram;

    // ---------- READOUT ----------
    logic [3:0] read_index;
    logic [17:0] read_shift;
    logic        half_sel;

    // ===================== FSM ===============================

    // state register
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next-state logic
    always_comb begin
        next_state = state;

        case (state)

            IDLE: begin
                if (start)
                    next_state = LOAD_INPUTS;
            end

            LOAD_INPUTS: begin
                if (input_cnt == 5'd31)
                    next_state = COMPUTE_MAC;
            end

            COMPUTE_MAC: begin
                if (k_cnt == 3'd7)
                    next_state = SAVE_RESULT;
            end

            SAVE_RESULT: begin
                next_state = NEXT_ELEMENT;
            end

            NEXT_ELEMENT: begin
                if (row_i == 2'd3 && col_j == 2'd3)
                    next_state = DONE;
                else
                    next_state = COMPUTE_MAC;
            end

            DONE: begin
                next_state = IDLE;
            end

        endcase
    end

    // =============== INPUT BUFFER WRITE ======================
  
  	
	// write first element on start while in IDLE
	always_ff @(posedge clk) begin
    	if (rst) begin
        	input_cnt <= 0;
    	end
    	else if (state == IDLE && start) begin
        	// write element 0 immediately
        	input_cnt <= 1;
    	end
    	else if (state == LOAD_INPUTS) begin
        	if (input_cnt == 31)
            	input_cnt <= 0;
        	else
            	input_cnt <= input_cnt + 1;
    	end
	end

	assign inbuf_wr_en =
    	(state == IDLE && start) || (state == LOAD_INPUTS);

	assign inbuf_wr_addr = input_cnt;
	assign inbuf_wr_data = input_data;


    input_buffer u_input_buffer (
        .clk(clk),
        .rst(rst),
      	.comp_en(mac_en),
        .wr_en(inbuf_wr_en),
        .wr_addr(inbuf_wr_addr),
        .wr_data(inbuf_wr_data),
        .rd_addr(inbuf_rd_addr),
        .rd_data(inbuf_rd_data)
    );

    // ======== LOOP COUNTERS (i,j,k loops) ====================

    // inner product index k = 0..7
    always_ff @(posedge clk) begin
        if (rst || state != COMPUTE_MAC)
            k_cnt <= 3'd0;
        else if (mac_en)
            k_cnt <= k_cnt + 3'd1;
    end

    // row index i
    always_ff @(posedge clk) begin
        if (rst)
            row_i <= 2'd0;
        else if (state == NEXT_ELEMENT) begin
            if (row_i == 2'd3)
                row_i <= 2'd0;
            else
                row_i <= row_i + 2'd1;
        end
    end

    // column index j
    always_ff @(posedge clk) begin
        if (rst)
            col_j <= 2'd0;
        else if (state == NEXT_ELEMENT && row_i == 2'd3)
            col_j <= col_j + 2'd1;
    end

    // =========================================================
    // ===================== ROM ===============================
    // =========================================================

    rom_coeff u_rom (
        .clk (clk),
        .addr(rom_addr),
      	.comp_en(mac_en),
        .data(rom_data)
    );

    assign coeff_hi = rom_data[13:7];
    assign coeff_lo = rom_data[6:0];

    wire [1:0] pair_index = k_cnt[2:1];
    assign rom_addr = {col_j, pair_index};   // j*4 + pair

    // =========================================================
    // ====================== MAC ==============================
    // =========================================================

    mac_unit u_mac (
        .clk(clk),
        .rst(rst),
        .en(mac_en),
        .clr(mac_clr),
        .x(mac_x),
        .w(mac_w),
        .acc(mac_acc)
    );

    assign inbuf_rd_addr = {k_cnt, row_i};  // k*4 + i
  	assign mac_x = inbuf_rd_data;

    assign mac_w = (k_cnt[0] == 1'b0) ? coeff_hi : coeff_lo;
  
	always_ff @(posedge clk) begin
    if (rst)
        cnt_is_zero_d <= 1'b0;
    else
      cnt_is_zero_d <= (k_cnt == 0);
	end

  	assign mac_clr = (k_cnt == 0) & ~cnt_is_zero_d;
    assign mac_en  = (state == COMPUTE_MAC);
  
  // =========================================================
    // ========== STORE COMPLETED MAC INTO RESULT RAM ==========
    // =========================================================

    always_ff @(posedge clk) begin
        if (rst) begin
            res_index <= 0;
        end
        else if (state == SAVE_RESULT) begin
            result_ram[res_index] <= mac_acc;   // store full 18 bits
            res_index <= res_index + 1;
        end
    end

    // =========================================================
    // ===================== READ INTERFACE ====================
    // =========================================================
	
  	always_ff @(posedge clk) begin
    	if (rst)
        	prev_read_ram <= 1'b0;
    	else
        	prev_read_ram <= read_ram;
		end
	always_ff @(posedge clk) begin
    	if (rst) begin
        	read_index <= 0;
        	read_shift <= 0;
        	half_sel   <= 0;
        	read_data_out <= 0;
    	end

    	//  reset read pointers at start of read session
    	else if (read_ram && !prev_read_ram) begin
        	read_index <= 0;
        	half_sel   <= 0;
        	read_shift <= 0;
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
        	read_data_out <= 0;
    	end
	end

  

    // ===================== FINISH ============================

    always_ff @(posedge clk) begin
        if (rst)
            finish <= 1'b0;
        else if (state == DONE)
            finish <= 1'b1;
        else
            finish <= 1'b0;
    end

endmodule
