library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity Adder_tree is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk, load_1, load_2 : in std_logic;
        Data_in_kernel      : in Data_array(0 to NUM_REGS-1);
        Data_in_matriz      : in Data_array(0 to NUM_REGS-1);
        Data_out_5x5        : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_4x4        : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_3x3        : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_2x2        : out Vector_Array(0 to 0)(21 downto 0)
    );
end Adder_tree;

architecture Behavioral of Adder_tree is
    signal Registros_kernel, Registros_matriz : Data_array(0 to NUM_REGS-1);

    signal P  : Vector_Array(0 to NUM_REGS-1)(15 downto 0);
    signal s1 : Vector_Array(0 to 11)(16 downto 0);
    signal s2 : Vector_Array(0 to 5)(17 downto 0);
    signal s3 : Vector_Array(0 to 2)(18 downto 0);
    signal s4 : Vector_Array(0 to 2)(19 downto 0);
    signal s5 : Vector_Array(0 to 0)(20 downto 0);
    signal s6 : Vector_Array(0 to 0)(21 downto 0); 
    
-- Registros de corrimiento
    signal kernel4x4 : Vector_Array(0 to 0)(21 downto 0); -- 1 ciclo de corrimiento de dato de 22 bits.
    signal kernel3x3 : Vector_Array(0 to 1)(19 downto 0); -- 2 ciclos de corrimiento de dato de 20 bits.
    signal kernel2x2 : Vector_Array(0 to 3)(17 downto 0); -- 4 ciclos de corrimiento de dato de 18 bits.

    signal k1x1        : Matrix_Array(0 to 3, 0 to 5)(15 downto 0); -- 4 datos de corrimiento de índice de registros 26, 18, 9 y 0. 6 ciclos de reloj de corrimiento.
    signal corrimiento : Matrix_Array(0 to 1, 0 to 1)(18 downto 0); -- 2 datos de corrimiento, ambos en el cuarto estado, donde máximo se hace un corrimiento de 2 ciclos de reloj. 
    
    signal load      : std_logic;

begin   
    
    --clk_load <= clk AND load;
    load <= load_1 OR load_2;
    
    Registros : entity work.AT_Registros
    generic map(
        NUM_REGS => NUM_REGS
    )
    port map(
        clk              => clk,
        load             => load,
        Data_in_kernel   => Data_in_kernel,
        Data_in_matriz   => Data_in_matriz,
        Registros_kernel => Registros_kernel,
        Registros_matriz => Registros_matriz
    );
    
    E1 : entity work.AT_E1
    generic map(
        NUM_REGS => NUM_REGS
    )
    port map(
        clk              => clk,
        load             => load,
        Registros_kernel => Registros_kernel,
        Registros_matriz => Registros_matriz,
        P                => P
    );
    
    E2 : entity work.AT_E2
    generic map(
        NUM_REGS => NUM_REGS
    )
    port map(
        clk  => clk,
        load => load,
        P    => P,
--        k1x1 => k1x1,
        s1   => s1
    );
    
    E3 : entity work.AT_E3
    port map(
        clk  => clk,
        load => load,
        s1   => s1,
--        k1x1 => k1x1,
        s2   => s2
    );
    
    E4 : entity work.AT_E4
    port map(
        clk  => clk,
        load => load,
        s2   => s2,
        s3   => s3
    );
    
    E5 : entity work.AT_E5
    port map(
        clk  => clk,
        load => load,
        s3   => s3,
        k1x1 => k1x1,
        s4   => s4
    );
    
    E6 : entity work.AT_E6
    port map(
        clk         => clk,
        load        => load,
        s4          => s4,
        corrimiento => corrimiento,
        s5          => s5
    );    
    
    E7 : entity work.AT_E7
    port map(
        clk         => clk,
        load        => load,
        s5          => s5,
        corrimiento => corrimiento,
        s6          => s6
    );     
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                
            -- Etapa 2 Suma        
                k1x1(0,0) <= P(26);
                k1x1(1,0) <= P(18);
                k1x1(2,0) <= P(9);
                k1x1(3,0) <= P(0);
                
            -- Etapa 3 Suma        
                k1x1(0,1) <= k1x1(0,0);
                k1x1(1,1) <= k1x1(1,0);            
                k1x1(2,1) <= k1x1(2,0);
                k1x1(3,1) <= k1x1(3,0);
    
            -- Etapa 4 Suma 
                --k1x1(0,2) <= k1x1(0,1);
                k1x1(1,2) <= k1x1(1,1);
                k1x1(2,2) <= k1x1(2,1);
                k1x1(3,2) <= k1x1(3,1);
                kernel2x2(0) <= s2(0);
                
            -- Etapa 5 Suma 
                --k1x1(0,3) <= k1x1(0,2);
                kernel2x2(1) <= kernel2x2(0);
                corrimiento(0,0) <= s3(1);
                corrimiento(0,1) <= s3(2);
                
            -- Etapa 6 Suma
                --k1x1(0,4) <= k1x1(0,3);
                kernel2x2(2) <= kernel2x2(1);
                kernel3x3(1) <= s4(0);
                corrimiento(1,1) <= corrimiento(0,1);
                
            -- Etapa 7 Suma 
                --k1x1(0,5) <= k1x1(0,4);
                kernel2x2(3) <= kernel2x2(2);
                kernel3x3(0) <= kernel3x3(1);                                                        
                kernel4x4(0) <= s5(0) & '0';
                                         
            end if;
        end if;
    end process;
    
    Data_out_5x5 <= s6;
    Data_out_4x4 <= kernel4x4;
    Data_out_3x3(0) <= kernel3x3(0) & "00";
    Data_out_2x2(0) <= kernel2x2(3) & "0000";
    --Data_out_1x1(0) <= k1x1(0,5) & "000000";
    
end Behavioral;