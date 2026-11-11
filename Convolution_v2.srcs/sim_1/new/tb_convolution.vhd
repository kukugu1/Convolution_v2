library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity tb_Convolution is
end tb_Convolution;

architecture behavior of tb_Convolution is
    constant C_Data_length : integer := 128;
    constant C_Bias_length : integer := 8;

    -- Señales de entrada
    signal Data_in        : std_logic_vector((C_Data_length*Bits)-1 downto 0) := (others => '0');
    signal Bias           : std_logic_vector(C_Bias_length-1 downto 0) := (others => '0');
    signal clk            : std_logic := '0';
    signal selector       : std_logic := '0';
    signal T_valid_in     : std_logic := '0';
    signal T_ready_in     : std_logic := '0';
    signal Bus_valid_Size : std_logic_vector(2 downto 0) := (others => '0');
    signal Padding        : std_logic_vector(1 downto 0) := (others => '0');
    signal kernel         : std_logic_vector(1 downto 0) := (others => '0');
    signal Stride         : std_logic_vector(1 downto 0) := (others => '0');

    -- Señales de salida
    signal T_ready_out : std_logic;
    signal T_valid_out : std_logic;
    signal data_out    : std_logic_vector((4224)-1 downto 0);

    -- Definición del periodo de reloj
    constant clk_period : time := 10 ns;

begin

    uut: entity work.Convolution 
    generic map (
        Data_length => C_Data_length,
        Bias_length => C_Bias_length
    )
    port map (
        Data_in        => Data_in,
        Bias           => Bias,
        clk            => clk,
        selector       => selector,
        T_valid_in     => T_valid_in,
        T_ready_in     => T_ready_in,
        Bus_valid_Size => Bus_valid_Size,
        Padding        => Padding,
        kernel         => kernel,
        Stride         => Stride,
        T_ready_out    => T_ready_out,
        T_valid_out    => T_valid_out,
        data_out       => data_out
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        -- De cinco a uno
--        for i in 0 to 127 loop
--            Data_in((1023 - (i*8)) downto (1016 - (i*8))) <= std_logic_vector(to_unsigned((i mod 5) + 1, 8));
--        end loop;

        -- De 1 a 128
        for i in 0 to 127 loop
            Data_in((1023 - (i*8)) downto (1016 - (i*8))) <= std_logic_vector(to_unsigned(i + 1, 8));
        end loop;
        
        Bias           <= x"01"; -- 0000 0001
        Bus_valid_Size <= "100"; --128x128
        Padding        <= "00"; -- Padding de cero
        kernel         <= "11"; -- kernel de 5x5
        Stride         <= "01"; -- Stride de 1
        
        --Se llena el kernel
        wait for 3*clk_period;
        T_valid_in <= '1';
        
        wait for 2*clk_period;
        T_valid_in <= '0';
        selector   <= '1';
        
        -- 1era fila matriz (comportamiento inicial)
        wait for 34*clk_period;
        T_valid_in <= '1';
        wait for 2*clk_period;
        T_valid_in <= '0';
        selector <= '0';
        
        -- Filas 2 a 130 (comportamiento repetitivo)
        for i in 2 to 5 loop
            selector   <= '0';   
            wait for 140*clk_period;
            T_valid_in <= '1';
            
            wait for 2*clk_period;
            T_valid_in <= '0';
        end loop; 
       
        wait;
    end process;

end behavior;