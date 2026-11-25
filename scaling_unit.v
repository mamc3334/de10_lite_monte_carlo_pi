module scaling_unit(
    input       clk,
    input       rst_n,
    input       en,
    input[3:0]  n_val, // latched n
    input[16:0] total,    // from accumulator

    output reg[19:0] pi_estimate, // max 999999
    output reg       done
);
    // pi_estimate = 4*hits/2^n
    // multiply by 100000 for display
    //400000 * 2^16 needs 35 bits
    wire[34:0] product = {18'b0,total} * 35'd400000;

    // n+1
    wire [4:0] n_shift = {1'b0, n_val} + 5'b1;

    //ready
    reg ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
            pi_estimate <= 32'b0;
            ready <= 1'b0;
        end
        else if (ready) begin
            done <= 1'b1;
            ready <= 1'b0;
        end
        else if (en) begin
            done <= 1'b0;
            ready <= 1'b1;
            pi_estimate <= product >> n_shift;
        end
    end

endmodule