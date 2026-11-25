module average(
    input       clk,
    input       rst_n,
    input       en,
    input       pi_done,
    input[19:0] this_run, //from scaling_unit
    
    output[19:0] new_pi
);
    reg  [19:0] avg_pi;
    reg updated; // edge of pi_done
    reg first_done; 

    wire [20:0] sum = {1'b0, this_run} + {1'b0, avg_pi};
    wire [19:0] next_avg_pi = sum[20:1]; // divide by 2

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            avg_pi <= 20'b0;
            updated <= 0;
        end
        else begin
            updated <= pi_done;
            if (pi_done & ~updated) begin
                avg_pi <= first_done ? next_avg_pi: this_run; //don't div by 2 on first run - avg_pi=0
                first_done <= 1'b1;
            end
        end
    end

    assign new_pi = en ? avg_pi : this_run;

endmodule