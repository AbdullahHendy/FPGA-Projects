`timescale 1ns / 1ps

module gradual_bright_dec #
(
   parameter int duty_res = 8,
   parameter int gradient_counter_max = 2500000 //125M/gradient_freq //default 50Hz
)
(
    input clk,
    input rst,
    output led,
    output min
    );

    integer counter = 0;
    logic [duty_res:0] duty_reg;
    logic [duty_res:0] duty; 
    logic gradient_pulse; 
    logic min_reg;
        
    pwm #(
        .R(duty_res)
        )
        pwm1
        (
            .clk(clk),
            .rst(rst),
            .dvsr(32'd4883), //dvsr = 125M/(2^8 * 100), pwmFreq = 100Hz
            .duty(duty),
            .pwm_out(led)
        );     
 
 
    always_ff@(posedge clk, posedge rst) begin 
        if (rst) begin
            counter <= 0;
        end 
        else begin
            if (counter < gradient_counter_max - 1) begin
                counter <= counter + 1;
                gradient_pulse <= 0;
            end
            else begin
                counter <= 0;
                gradient_pulse <= 1;
            end
        end
    end 
  
    always_ff@(posedge gradient_pulse, posedge rst) begin
        if (rst) begin
            duty_reg <= 9'd2**duty_res;
            min_reg <= 1'b0;
        end
        else begin
            min_reg <= 1'b0;
            duty_reg <= duty_reg - 1;
            if(duty_reg == 0) begin
                duty_reg <= 9'd2**duty_res;
                min_reg <= 1'b1;
            end
        end    
    end    
    
    assign duty = duty_reg;
    assign min = min_reg;
         
endmodule
