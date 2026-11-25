module bin2digits (
    input clk,
    input rst_n,
    input update,
    input [19:0] bin,

    output reg[3:0] dig5,
    output reg[3:0] dig4,
    output reg[3:0] dig3,
    output reg[3:0] dig2,
    output reg[3:0] dig1,
    output reg[3:0] dig0
);
    reg[23:0] digits; // datatype filled with dig<0-5>
    wire[19:0] bin_cap = (bin > 20'd999999) ? 20'd999999 : bin;
    integer i;

    always @(*) begin
        digits = 28'd0;

        for (i = 19; i >= 0; i = i - 1) begin
            // Add 3 to any digit >= 5 before shifting
            if (digits[3:0] >= 5) begin
                digits[3:0] = digits[3:0] + 4'd3;
            end
            if (digits[7:4] >= 5) begin
                digits[7:4] = digits[7:4] + 4'd3;
            end
            if (digits[11:8] >= 5) begin
                digits[11:8] = digits[11:8] + 4'd3;
            end
            if (digits[15:12] >= 5) begin 
                digits[15:12] = digits[15:12] + 4'd3;
            end
            if (digits[19:16] >= 5) begin 
                digits[19:16] = digits[19:16] + 4'd3;
            end
            if (digits[23:20] >= 5) begin
                digits[23:20] = digits[23:20] + 4'd3;
            end

            // Shift left by 1 and bring in the next bit
            digits = {digits[23:0], bin_cap[i]};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            dig5 <= 4'b0;
            dig4 <= 4'b0;
            dig3 <= 4'b0;
            dig2 <= 4'b0;
            dig1 <= 4'b0;
            dig0 <= 4'b0;
        end
        else if (update) begin
            {dig5, dig4, dig3, dig2, dig1, dig0} = digits;
        end
    end
endmodule
