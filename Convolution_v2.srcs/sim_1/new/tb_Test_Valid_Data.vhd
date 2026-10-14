library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity tb_Test_Valid_Data is
end tb_Test_Valid_Data;

architecture behavior of tb_Test_Valid_Data is
    constant C_Data_length : integer := 128;

    -- Señales de entrada (Inicializadas en 0)
    signal Data_in        : std_logic_vector((C_Data_length*Bits)-1 downto 0) := (others => '0');
    signal clk            : std_logic := '0';
    signal selector       : std_logic := '0';
    signal T_valid_in     : std_logic := '0';
    signal Bus_valid_Size : std_logic_vector(2 downto 0) := (others => '0');
    signal Padding        : std_logic_vector(1 downto 0) := (others => '0');
    signal kernel         : std_logic_vector(1 downto 0) := (others => '0');
    signal Stride         : std_logic_vector(1 downto 0) := (others => '0');

    -- Señales de salida
    signal T_ready_out            : std_logic;
    signal VALID_OUT              : std_logic;
    signal Salida_Mask_Adder_Tree : std_logic_vector(21 downto 0);

    -- Definición del periodo de reloj
    constant clk_period : time := 10 ns;

begin

    uut: entity work.Test_Valid_Data 
    generic map (
        Data_length => C_Data_length
    )
    port map (
        Data_in                => Data_in,
        clk                    => clk,
        selector               => selector,
        T_valid_in             => T_valid_in,
        Bus_valid_Size         => Bus_valid_Size,
        Padding                => Padding,
        kernel                 => kernel,
        Stride                 => Stride,
        T_ready_out            => T_ready_out,
        VALID_OUT              => VALID_OUT,
        Salida_Mask_Adder_Tree => Salida_Mask_Adder_Tree
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
        -- Inserta tus estímulos a partir de aquí
        for i in 0 to 127 loop
            Data_in( (1023 - (i*8)) downto (1016 - (i*8)) ) <= std_logic_vector(to_unsigned((i mod 5) + 1, 8));
        end loop;
        Bus_valid_Size <= "100"; --128x128
        Padding <= "00"; -- Padding de cero
        kernel <= "11"; -- kernel de 5x5
        Stride <= "01"; -- Stride de 1        
        
        --Se llena el kernel
        wait for 3*clk_period;
        T_valid_in <= '1';
        
        wait for 2*clk_period;
        T_valid_in <= '0';
        selector <= '1';
        
        --1era fila matriz
        wait for 34*clk_period;
        T_valid_in <= '1';
        
        wait for 2*clk_period;
        T_valid_in <= '0';
        
        --2da fila matriz
        wait for 140*clk_period;
        T_valid_in <= '1';

        wait for 2*clk_period;
        T_valid_in <= '0';
        
        --3era fila matriz
        wait for 140*clk_period;
        T_valid_in <= '1';

        wait for 2*clk_period;
        T_valid_in <= '0';       
        
        --4ta fila matriz
        wait for 140*clk_period;
        T_valid_in <= '1';

        wait for 2*clk_period;
        T_valid_in <= '0';         
        
        --5ta fila matriz
        wait for 140*clk_period;
        T_valid_in <= '1';

        wait for 2*clk_period;
        T_valid_in <= '0';          
        
        --6ta fila matriz. Si solo se llenan cinco no arranca la matriz
        wait for 140*clk_period;
        T_valid_in <= '1';

        wait for 2*clk_period;
        T_valid_in <= '0';         
        wait;
    end process;

end behavior;