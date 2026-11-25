module lane_array(
    input       clk,
    input       rst_n,
    input[15:0] lane_en,

    output[15:0] lane_hits
);
    localparam [511:0] SEEDS = {
        32'hAA55AA55,
        32'hBB66BB66,
        32'hCC77CC77,
        32'hDD88DD88,
        32'hEE99EE99,
        32'hFFAFFFFF,
        32'h55AA55AA,
        32'h66BB66BB,
        32'h77CC77CC,
        32'h88DD88DD,
        32'h99EE99EE,
        32'h12345678,
        32'h98765432,
        32'h0F0F0F0F,
        32'hF0F0F0F0,
        32'hDEADBEEF
    };

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_lanes
            lane #(
                .SEED(SEEDS[i*32 +: 32]) // Each lane gets a unique seed - count up
            ) u_lane (
                .clk(clk),
                .rst_n(rst_n),
                .lane_en(lane_en[i]),
                .lane_hit(lane_hits[i])
            );
        end
    endgenerate
endmodule