module controller (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input logic [7:0] wr_data,


    // // status inputs
    // input  logic k_is_last,

    // control outputs
    output logic inbuf_wr_en,
    output logic [4:0] inbuf_wr_addr,
    output logic [7:0] inbuf_wr_data,

    output logic mac_en,
    output logic mac_clr,

    output logic [3:0] rom_addr,

    output logic [4:0] inbuf_rd_addr,
    

    output logic save_result,
    output logic [3:0] res_index,

    output logic finish
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

    // ---------- result index ----------
    logic [3:0] res_idx_r;
    logic one_matrix_calculated;
    //----------------------------------------------------
    // FSM state register
    //----------------------------------------------------
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
                else
                    next_state=state;
            end

            LOAD_INPUTS: begin
                if (input_cnt == 5'd31)
                    next_state = COMPUTE_MAC;
                else
                    next_state=state;
            end

            COMPUTE_MAC: begin
                if (k_cnt == 3'd7)
                    next_state = SAVE_RESULT;
                else
                    next_state=state;
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
            default: next_state=IDLE;
        endcase
    end

    // =============== INPUT BUFFER WRITE ======================
	// write first element on start while in IDLE
	always_ff @(posedge clk) begin
    	if (rst) begin
        	input_cnt <= 0;
    	end
    	else if (state == IDLE && start) begin
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
    assign inbuf_wr_data = wr_data;

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

    //----------------------------------------------------
    // MAC controls
    //----------------------------------------------------
	always_ff @(posedge clk) begin
    if (rst)
        one_matrix_calculated <= 1'b0;
    else
      one_matrix_calculated <= (k_cnt == 0);
	end

  	assign mac_clr = (k_cnt == 0) & ~one_matrix_calculated;
    assign mac_en  = (state == COMPUTE_MAC);	

    //----------------------------------------------------
    // ROM addressing
    //----------------------------------------------------
    wire [1:0] pair_index = k_cnt[2:1];
    assign rom_addr = {col_j, pair_index};

    //----------------------------------------------------
    // input buffer read address  (k*4 + i)
    //----------------------------------------------------
    assign inbuf_rd_addr = {k_cnt, row_i};

    //----------------------------------------------------
    // result index
    //----------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst)
            res_idx_r <= 0;
        else if (state == SAVE_RESULT)
            res_idx_r <= res_idx_r + 1;
    end

    assign res_index = res_idx_r;

    //----------------------------------------------------
    // finish signal
    //----------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst)
            finish <= 0;
        else if (state == DONE)
            finish <= 1;
        else
            finish <= 0;
    end

    //----------------------------------------------------
    // SAVE_RESULT pulse
    //----------------------------------------------------
    assign save_result = (state == SAVE_RESULT);

endmodule
