module mc_pi_top(
    input       MAX10_CLK1_50,

    // KEY[0] = rst_n - IDLE, reseed, clear accumulator, and display
    // KEY[1] = run_en, clear accumulator, and display
    // both on edge from button release
    input[1:0]  KEY,

    // total samples (1-65536)
    input[3:0]  SW, 
    
    //hex displays
    output[7:0] HEX0,
    output[7:0] HEX1,
    output[7:0] HEX2,
    output[7:0] HEX3,
    output[7:0] HEX4,
    output[7:0] HEX5
);
    //input
    wire rst_n = KEY[0];
    wire run_en = ~KEY[1];
    wire[3:0] switch_val = SW;

    //signals
    wire pi_done;
    wire clear_accum;
    wire scale_en;
    wire[15:0] lane_en;
    wire[3:0] n_latched;

    fsm fsm_ (
        .clk(MAX10_CLK1_50),
        .rst_n(rst_n),
        .run_en(run_en),
        .n_val(switch_val),
        .pi_done(pi_done),
        .clear_accum(clear_accum),
        .lane_en(lane_en),
        .scale_en(scale_en),
        .n_latched(n_latched)
    );

    // sim outputs
    wire[15:0] lane_hits;
    wire[16:0] total_hits;
    wire[19:0] scaled_pi;

    lane_array lanes (
        .clk(MAX10_CLK1_50),
        .rst_n(rst_n),
        .lane_en(lane_en),
        .lane_hits(lane_hits)
    );

    accumulator accum_ (
        .clk(MAX10_CLK1_50),
        .rst_n(rst_n),
        .clear_accum(clear_accum),
        .lane_hits(lane_hits),
        .total(total_hits)
    );

    scaling_unit scale_ (
        .clk(MAX10_CLK1_50),
        .rst_n(rst_n),
        .en(scale_en),
        .n_val(n_latched),
        .total(total_hits),
        .pi_estimate(scaled_pi),
        .done(pi_done)
    );

    //display digits
    wire[3:0] dig5;
    wire[3:0] dig4;
    wire[3:0] dig3;
    wire[3:0] dig2;
    wire[3:0] dig1;
    wire[3:0] dig0;

    bin2digits conv_ (
        .clk(MAX10_CLK1_50),
        .rst_n(rst_n),
        .update(pi_done),
        .bin(scaled_pi),
        .dig5(dig5),
        .dig4(dig4),
        .dig3(dig3),
        .dig2(dig2),
        .dig1(dig1),
        .dig0(dig0)
    );

    display_driver hex_5 (
        .digit(dig5),
        .decimal(1'b1),
        .seg(HEX5)
    );
    display_driver hex_4 (
        .digit(dig4),
        .decimal(1'b0),
        .seg(HEX4)
    );
    display_driver hex_3 (
        .digit(dig3),
        .decimal(1'b0),
        .seg(HEX3)
    );
    display_driver hex_2 (
        .digit(dig2),
        .decimal(1'b0),
        .seg(HEX2)
    );
    display_driver hex_1 (
        .digit(dig1),
        .decimal(1'b0),
        .seg(HEX1)
    );
    display_driver hex_0 (
        .digit(dig0),
        .decimal(1'b0),
        .seg(HEX0)
    );
endmodule