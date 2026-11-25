module accumulator(
    input               clk,
    input               rst_n,
    input               clear_accum,
    input[15:0]         lane_hits,

    output reg[16:0]    total
);
//TODO: update
    function [4:0] popcnt16(input [15:0] x);
        integer i;
        begin
            popcnt16 = 5'b0;
            for (i = 0; i < 16; i = i + 1) begin
                popcnt16 = popcnt16 + x[i];
            end
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total <= 16'b0;
        end
        else if (clear_accum) begin
            total <= 16'b0;
        end
        else begin
            total <= total + {11'b0, popcnt16(lane_hits)};
        end
    end

endmodule

//TODO - optimize based on dynamic number of lanes - curr always uses all 16 lane