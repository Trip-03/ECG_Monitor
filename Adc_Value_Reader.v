module adc_to_heart_rate_converter (
    input wire clk,
    input wire reset,
    input wire [9:0] adc_in,
    input wire [7:0] max_heart_rate_possible,
    input wire [7:0] max_continous_checks,
    input wire measuring,
    input wire [7:0] min_heart_threshold,
    input wire [7:0] max_heart_threshold,

    output reg done,
    output reg [7:0] heart_beats_count,
    output reg [7:0] heart_beats_without_violations,
    output reg [7:0] min_heart_beats_threshold_violations,
    output reg [7:0] max_heart_beats_threshold_violations,
    output reg [7:0] heart_rate_avg,
    output reg [7:0] heart_beat_val_live
);

    reg [63:0] heart_rate_sum;  // Accumulator 

    always @(posedge clk) begin
        if (reset || !measuring) begin
            heart_beats_count <= 0;
            heart_beats_without_violations <= 0;
            min_heart_beats_threshold_violations <= 0;
            max_heart_beats_threshold_violations <= 0;
            heart_rate_avg <= 0;
            heart_beat_val_live <= 0;
            heart_rate_sum <= 0;
            done <= 0;
        end 
        else if (measuring) begin
            heart_beat_val_live <= (adc_in * max_heart_rate_possible) / 1023;
            heart_rate_sum <= heart_rate_sum + heart_beat_val_live;
            // Count total beats
            heart_beats_count <= heart_beats_count + 1;

            // Threshold checks
            if (heart_beat_val_live < min_heart_threshold)
                min_heart_beats_threshold_violations <= min_heart_beats_threshold_violations + 1;
            else if (heart_beat_val_live > max_heart_threshold)
                max_heart_beats_threshold_violations <= max_heart_beats_threshold_violations + 1;
            else begin
                heart_beats_without_violations <= heart_beats_without_violations + 1;
            end

            // Average calculation
                heart_rate_avg <= heart_rate_sum / (heart_beats_count); 

            // Done flag to indicate state change to display
            if (heart_beats_count >= max_continous_checks || adc_in==0) begin
                done <= 1'b1;
            end
        end
    end

endmodule
