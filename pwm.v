module PWM (
    input wire clk,                // Clock do sistema
    input wire rst_n,              // Reset assíncrono ativo em nível baixo
    input wire [31:0] duty_cycle,  // Largura do pulso PWM (tempo em nível alto)
    input wire [31:0] period,      // Período total da onda PWM
    output reg pwm_out             // Saída PWM (1 quando ativo, 0 caso contrário)
);

    reg [31:0] counter; // Contador para controlar o tempo dentro do ciclo PWM

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset do módulo: zera contador e saída
            counter  <= 0;
            pwm_out  <= 0;
        end else begin
            // Reinicia contador ao final do ciclo
            if (counter < period - 1)
                counter <= counter + 1;
            else
                counter <= 0;

            // Gera sinal PWM: ativo durante o tempo do duty_cycle
            if (counter < duty_cycle)
                pwm_out <= 1;
            else
                pwm_out <= 0;
        end
    end

endmodule
