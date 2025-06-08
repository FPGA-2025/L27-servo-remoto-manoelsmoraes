module servo #(
    parameter CLK_FREQ = 25_000_000, // Clock da FPGA (25 MHz por padrão)
    parameter PERIOD    = 800_000     // Período da PWM: 20 ms (25 MHz / 50 Hz)
)(
    input  wire clk,         // Clock do sistema
    input  wire rst_n,       // Reset assíncrono ativo em nível baixo
    output wire servo_out    // Saída conectada ao pino do servo motor
);

    // Constantes de duty_cycle para o SG90
    localparam [31:0] DUTY_MIN = PERIOD * 5 / 100;  // 5% → 1 ms
    localparam [31:0] DUTY_MAX = PERIOD * 10 / 100; // 10% → 2 ms
    localparam [31:0] DELAY_CYCLES = CLK_FREQ * 5;  // 5 segundos = 5 * 25M = 125M ciclos

    reg [31:0] delay_counter = 0; // Contador para aguardar 5 segundos
    reg        state = 0;         // Estado atual: 0 = mínimo, 1 = máximo
    reg [31:0] duty_cycle = DUTY_MIN; // Duty cycle atual, inicia no mínimo

    // Alterna entre DUTY_MIN e DUTY_MAX a cada 5 segundos
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_counter <= 0;
            state         <= 0;
            duty_cycle    <= DUTY_MIN;
        end else begin
            if (delay_counter < DELAY_CYCLES - 1)
                delay_counter <= delay_counter + 1;
            else begin
                delay_counter <= 0;       // Zera contador
                state <= ~state;          // Troca estado (toggle)
                if (state == 0)
                    duty_cycle <= DUTY_MAX; // Vai para posição máxima
                else
                    duty_cycle <= DUTY_MIN; // Volta para posição mínima
            end
        end
    end

    // Instancia o módulo PWM
    PWM pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .period(PERIOD),
        .pwm_out(servo_out)
    );

endmodule
