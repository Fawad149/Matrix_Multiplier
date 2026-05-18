module controller (
    input  logic clk,
    input  logic rst,
    input  logic start,
  	input logic [13:0] coeff_data,
  	input logic [1:0] ram_write_cnt,


    output logic inbuf_wr_en,
    output logic [4:0] inbuf_wr_addr,
    output logic mac_en,
    output logic mac_clr,

    output logic [3:0] rom_addr,

    output logic [4:0] inbuf_rd_addr,
  	output logic [6:0]	coeff_out,

    output logic save_result,
  	output logic [8:0] res_index,

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

    state_t state;
    state_t next_state;

    // ---------- loop counters ----------
    logic [4:0] input_cnt=5'd0;
    logic [1:0] col_j;
    logic [2:0] k_cnt=3'd0;

    // ---------- result index ----------
  	logic [8:0] res_idx_r;
  
  	
  	logic [3:0] read_addr;
  
  	//----ROM-----
  	logic [6:0]  coeff_hi;
    logic [6:0]  coeff_lo;
    
    //---------- FSM state register------------------
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
              if(ram_write_cnt == 2'd3)
                next_state=NEXT_ELEMENT;
              else
                next_state=state;
            end

            NEXT_ELEMENT: begin
                if (col_j == 2'd3)
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

    // -------------INPUT BUFFER WRITE -----------
	always_ff @(posedge clk) begin
    	if (rst) begin
        	input_cnt <= 0;
    	end
    	else if (state == LOAD_INPUTS) begin
        	if (input_cnt == 31)
            	input_cnt <= 0;
        	else
            	input_cnt <= input_cnt + 1;
    	end
	end

	assign inbuf_wr_en = (state == LOAD_INPUTS);

	assign inbuf_wr_addr = input_cnt;

  //------------LOOP COUNTER -------------
    always_ff @(posedge clk) begin
        if (rst || state != COMPUTE_MAC)
            k_cnt <= 3'd0;
        else if (mac_en)
            k_cnt <= k_cnt + 3'd1;
    end

    // column index j
    always_ff @(posedge clk) begin
        if (rst)
            col_j <= 2'd0;
      else if (state == NEXT_ELEMENT)
            col_j <= col_j + 2'd1;
    end

    //---------MAC controls------------
	
  	assign coeff_out = (k_cnt[0] == 1'b0) ? coeff_hi : coeff_lo;
  	assign mac_clr = (state==SAVE_RESULT && ram_write_cnt == 2'd3);
  	assign mac_en  = (state == COMPUTE_MAC);	

    //----ROM addressing---------
  	assign coeff_hi = coeff_data[13:7];
    assign coeff_lo = coeff_data[6:0];
    wire [1:0] pair_index = k_cnt[2:1];
    assign rom_addr = {col_j, pair_index};

  
  	assign inbuf_rd_addr = k_cnt*4; //input buffer read address  (k*4 + i)

    //--------- result index ---------
    always_ff @(posedge clk) begin
        if (rst)
            res_idx_r <= 0;
      else if ((state == SAVE_RESULT))
            res_idx_r <= res_idx_r + 1;
    end

    assign res_index = res_idx_r;

    //---------finish ---------
    always_ff @(posedge clk) begin
        if (rst)
            finish <= 0;
        else if (state == DONE)
            finish <= 1;
        else
            finish <= 0;
    end

    assign save_result = (state == SAVE_RESULT);
	
`ifdef FORMAL
    always @(posedge clk) begin
        // ram_write_cnt stays within valid range
        assume(ram_write_cnt <= 2'd3);
    end


    // ---FSM state -------
    always @(posedge clk) begin
        assert(
            state == IDLE ||
            state == LOAD_INPUTS ||
            state == COMPUTE_MAC ||
            state == SAVE_RESULT ||
            state == NEXT_ELEMENT ||
            state == DONE
        );
    end


    // --FSM transition-----
    always @(posedge clk) begin
        if (!rst) begin
            case (state)
                IDLE:
                    assert(next_state == IDLE || next_state == LOAD_INPUTS);

                LOAD_INPUTS:
                    assert(next_state == LOAD_INPUTS || next_state == COMPUTE_MAC);

                COMPUTE_MAC:
                    assert(next_state == COMPUTE_MAC || next_state == SAVE_RESULT);

                SAVE_RESULT:
                    assert(next_state == SAVE_RESULT || next_state == NEXT_ELEMENT);

                NEXT_ELEMENT:
                    assert(next_state == COMPUTE_MAC || next_state == DONE);

                DONE:
                    assert(next_state == IDLE);
            endcase
        end
    end


    // ----Counter----
    always @(posedge clk) begin
        if (!rst && state != LOAD_INPUTS)
            assert(input_cnt == 0);
    end

    always @(posedge clk) begin
        if (!rst && state != COMPUTE_MAC)
            assert(k_cnt == 0);
    end


    // ----Control signal-----
    always @(posedge clk) begin
        assert(mac_en == (state == COMPUTE_MAC));
    end


    // ---- Liveness-------
    reg seen_start=1'b0;
    always @(posedge clk) begin
        if (rst)
            seen_start <= 1'b0;
        else if (start)
            seen_start <= 1'b1;
        else if (finish)
            seen_start <= 1'b0;

        // Once started, controller must not get stuck forever
        if (seen_start)
            if(finish)
                assert($past(state) != IDLE);
            else
                assert(state != IDLE);
    end

    // mac_clr only allowed when saving result
	always @(posedge clk) begin
    	if (!rst)
        	assert(mac_clr == (state == SAVE_RESULT && ram_write_cnt == 2'd3));
	end

	//mac_en and mac_clr can never be high together
	always @(posedge clk) begin
    	assert(!(mac_en && mac_clr));
	end

`endif

  
endmodule