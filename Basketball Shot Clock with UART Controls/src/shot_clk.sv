`timescale 1ns / 1ps

module shot_clk(
    input sysclk,
    input rst,
    
    //input hold,
    
    input rx,
    output tx,
    output [6:0] seg,
    output sel,
    output buzzer,
    output [3:0] leds //test
    );
    
    localparam clk_freq = 50000000;
    localparam pwm_res = 8; 

    logic sel_reg;
    logic [3:0] disp_val_1 = 4'd4; 
    logic [3:0] disp_val_2 = 4'd2; 
    logic [3:0] disp_val;
    
    typedef enum logic {run, stop} state;
    state curr_state;    
    logic div_clk;
    logic clk;
    logic [29:0] counter = 30'd0;
    logic buzz_flag;
    logic [pwm_res:0] duty;
    logic [pwm_res:0] duty_reg;
       
    logic [29:0] disp_counter = 30'd0;
    logic [29:0] duty_counter = 30'd0;   
    
    //////////////////////////////////////
    logic wr_uart;
    logic rd_uart;
    logic tx_full;
    logic rx_empty;
    logic [7:0] r_data;
    logic [7:0] w_data;
    localparam uart_dvsr = 68; // sysclk/(baudrate * samples) - 1 //baudrate = 115200
    //////////////////////////////////////


      clk_wiz_0 clk0
      (
      // Clock out ports  
      .clk_out1(clk),
     // Clock in ports
      .clk_in1(sysclk)
      );
          
    disp_ctrl ssd_1(
      .disp_val(disp_val),
      .seg_out (seg)
      );
       
    pwm #(
        .R(pwm_res)
        )
        pwm1
        (
            .clk(clk),
            .rst(rst),
            .dvsr(32'd325), //dvsr = 50M/(2^8 * 600) //600Hz sound
            .duty(duty),
            .pwm_out(buzzer)
        );
    
    uart_top # (
            .D_BITS(8),
            .STOP_SAMPLES(16),
            .FIFO_ADDR_W(4)
        )
        uart1
        (
            .clk_uart(sysclk),
            .rst_uart(rst),
            .wr_uart(wr_uart),
            .rd_uart(rd_uart),
            .dvsr_uart(uart_dvsr),
            .rx_uart(rx),
            .w_data_uart(w_data),
            .tx_full_uart(tx_full),
            .rx_empty_uart(rx_empty),
            .r_data_uart(r_data),
            .tx_uart(tx)
        );
    
    
    
    always_ff@(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            div_clk <= 0;
        end 
        else begin
            if (counter == (clk_freq/2) - 1) begin
                div_clk <= !div_clk;
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
    
    always_ff@(posedge div_clk, posedge rst) begin
        if ((rst == 1'b1) || (r_data == 8'd114)) begin //114 r in ascii (reset)
            curr_state <= run;
            disp_val_1 <= 4'd4;
            disp_val_2 <= 4'd2;
            buzz_flag <=  1'b0;
        end
        else begin //rising edge of clk
            case (curr_state)
                run: begin
                        if (r_data == 8'd115) begin //115 s in ascii (stop)
                            curr_state <= stop;
                        end
                        else begin    
                            if (!(disp_val_2 == 0 && disp_val_1 == 0)) begin
                                disp_val_1 <= disp_val_1 - 1;
                                disp_val_2 <= disp_val_2;
                                if (disp_val_1 == 0) begin
                                    disp_val_1 <= 4'd9;
                                    disp_val_2 <= disp_val_2 - 1;
                                end 
                            end                       
                            else begin
                                buzz_flag <=  1'b1;
                                disp_val_2 <= 4'd0;
                                disp_val_1 <= 4'd0;   
                            end
                        end
                     end
                    
                stop: begin
                        buzz_flag <=  1'b0;
                        if (r_data == 8'd112) begin //112 p in ascii (play)
                            curr_state <= run;
                        end
                        else begin
                            disp_val_1 <= disp_val_1;
                            disp_val_2 <= disp_val_2;
                        end
                      end                      
            endcase         
        end
    end     
             
    always_ff@(posedge clk, posedge rst) begin
        if (rst == 1'b1) begin //114 r in ascii (reset)
            sel_reg <= 1'b0;
            disp_counter <= 30'd0;
        end
        else begin //rising edge of clk
            if (disp_counter == 30'd100000) begin 
                sel_reg <= 1'b1;
                disp_val <= disp_val_2;
                disp_counter <= disp_counter + 1;
            end
            else if (disp_counter == 30'd200000) begin
                sel_reg <= 1'b0;
                disp_val <= disp_val_1;
                disp_counter <= 30'd0;
            end
            else begin
                disp_counter <= disp_counter + 1;
            end
        end
    end 
    
    always_ff@(posedge clk, posedge rst) begin
        if ((rst == 1'b1) || (r_data == 8'd114)) begin //114 r in ascii (reset)
            duty_reg <= 0;
            duty_counter <= 0;
        end        
        else begin //rising edge of clk
            if (buzz_flag == 1'b1) begin
                if (duty_counter < 75000000) begin //1.5 second buzzer
                    duty_reg <= 64;
                    duty_counter <= duty_counter + 1;                    
                end
                else begin
                    duty_reg <= 0;
                end
            end
        end 
    end     
    
    
    assign sel = sel_reg;
    assign duty = duty_reg;
    assign leds = (buzz_flag == 1'b1) ? 4'b1111 : 0;;
    assign rd_uart = 1;
            
endmodule

