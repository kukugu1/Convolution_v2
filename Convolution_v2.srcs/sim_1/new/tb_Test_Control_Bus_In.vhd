library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity tb_Test_Control_Bus_In is
end tb_Test_Control_Bus_In;

architecture behavior of tb_Test_Control_Bus_In is

    -- Parámetros (Generics) mapeados a constantes para dimensionar señales
    constant C_Data_length : integer := 128;

    -- Señales de entrada (Inicializadas en 0)
    signal Data_in        : std_logic_vector((C_Data_length*Bits)-1 downto 0) := (others => '0');
    signal clk            : std_logic := '0';
    signal selector       : std_logic := '0';
    signal T_valid_in     : std_logic := '0';
    signal Bus_valid_Size : std_logic_vector(2 downto 0) := (others => '0');
    signal Padding        : std_logic_vector(1 downto 0) := (others => '0');

    -- Señales de salida
    signal T_ready_out : std_logic;
    signal Data_out_k  : Data_array(0 to 26);
    signal Data_out_m  : Data_array(0 to 24);

    -- Definición del periodo de reloj
    constant clk_period : time := 10 ns;

begin

    -- Instanciación del Unit Under Test (UUT)
    uut: entity work.Test_Control_Bus_In 
    generic map (
        Data_length => C_Data_length
    )
    port map (
        Data_in        => Data_in,
        clk            => clk,
        selector       => selector,
        T_valid_in     => T_valid_in,
        Bus_valid_Size => Bus_valid_Size,
        Padding        => Padding,
        T_ready_out    => T_ready_out,
        Data_out_k     => Data_out_k,
        Data_out_m     => Data_out_m
    );

    -- Generación del reloj principal
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Proceso principal para inyectar estímulos
    stim_proc: process
    begin
        -- Espera inicial sugerida para estabilización
        --wait for 100 ns;

        -- Inserta el resto de tus estímulos a partir de aquí
        for i in 0 to 127 loop
            Data_in((1023 - (i*8)) downto (1016 - (i*8))) <= std_logic_vector(to_unsigned(i + 1, 8));
        end loop;
        Bus_valid_Size <= "100"; --128x128
        Padding <= "00"; -- Padding de cero
        
        --Se llena el kernel
        wait for 3*clk_period;
        T_valid_in <= '1';
        
        wait for 2*clk_period;
        T_valid_in <= '0';
        selector <= '1';
        
        -- 1era fila matriz (comportamiento inicial)
        wait for 34*clk_period;
        T_valid_in <= '1';
        wait for 2*clk_period;
        T_valid_in <= '0';
        
        -- Filas 2 a 130 (comportamiento repetitivo)
        for i in 2 to 132 loop
            selector <= '0';   
            wait for 140*clk_period;
            T_valid_in <= '1';
            
            wait for 2*clk_period;
            T_valid_in <= '0';
        end loop;
        
        wait;
    end process;

end behavior;