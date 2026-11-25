

module fsm(
    input       clk,
    input       rst_n,
    input       run_en,

    // sample count (1-65536)
    input[3:0]  n_val,

    // pi calculated - display
    input       pi_done,
    
    // clear accumulator
    output              clear_accum,

    // bitmask - lanes used depends on N
    // SW=0 - 1 lane
    // SW=1 - 2 lanes
    // SW=2 - 4 lanes
    // SW=3 - 8 lanes
    // SW>3 - 16 lanes
    output[15:0]        lane_en,

    // accum done, start scale
    output              scale_en,

    //latched n
    output reg [3:0]    n_latched
);
    // State machine
    localparam [2:0] IDLE = 3'b000,
                     LOAD = 3'b001,
                     RUN = 3'b010,
                     DRAIN = 3'b011,
                     SCALE = 3'b100,
                     DONE = 3'b101;

    reg [2:0] state, next_state;

    // clocks to wait for lanes
    reg[12:0] counter;

    // lane mask - up to 16 lanes - depends on n_latched - active during RUN
    wire [15:0] lane_mask = (n_latched < 4) ? ((16'b1 << (1 << n_latched)) - 16'b1) : 16'hFFFF;

    // Implement state machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // Determine next state
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (run_en) begin
                    next_state = LOAD;
                end
            end

            LOAD: begin
                next_state = RUN;
            end

            RUN: begin
                if (counter == 0) begin
                    next_state = DRAIN;
                end
            end

            DRAIN: begin
                if (counter == 0) begin
                    next_state = SCALE;
                end
            end

            SCALE: begin
                if (pi_done) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                if (run_en) begin
                    next_state = LOAD;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // counter, lanes, pulses
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            n_latched <= 0;
        end
        else begin
            if((state == IDLE || state == DONE) && run_en) begin
                counter <= 0; // reset counter on run_en
                n_latched <= n_val; // latch n value for lane mask
            end
            else if (state == LOAD) begin
                // RUN cycles = N/lanes;  counter = cycles - 1
                // SW <= 4 - 2 cycles
                counter <= (n_latched <= 4) ? 13'b1 : ((13'b1 << (n_latched - 4'b11)) - 13'b1);
            end
            else if (state == RUN) begin
                counter <= (counter == 13'b0) ? 13'b10 : counter - 1; // set drain counter to 2 when done
            end
            else if (state == DRAIN) begin
                counter <= (counter != 13'b0) ? counter - 1 : 13'b0; // don't go negative
            end
        end
    end

    assign clear_accum = (state == LOAD);

    assign lane_en = (state == RUN) ? lane_mask : 16'b0;

    assign scale_en = (state == SCALE);
endmodule
