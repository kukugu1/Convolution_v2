library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity Adder_tree is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk, load      : in std_logic;
        Data_in_kernel : in Data_array(0 to NUM_REGS-1);
        Data_in_matriz : in Data_array(0 to NUM_REGS-1);
        Data_out_5x5   : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_4x4   : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_3x3   : out Vector_Array(0 to 0)(21 downto 0);
        Data_out_2x2   : out Vector_Array(0 to 0)(21 downto 0)
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
    attribute use_dsp       : string;
    attribute use_dsp of P  : signal is "yes";    
    
-- Registros de corrimiento
    signal kernel4x4 : Vector_Array(0 to 0)(21 downto 0);           
    signal kernel3x3 : Vector_Array(0 to 1)(19 downto 0); 
    signal kernel2x2 : Vector_Array(0 to 3)(17 downto 0);

    signal k1x1        : Matrix_Array(0 to 3, 0 to 5)(15 downto 0);
    signal corrimiento : Matrix_Array(0 to 1, 0 to 1)(18 downto 0);
    
    signal clk_load  : std_logic;

    begin   
    
    clk_load <= clk AND load;
            
    process(clk_load)
    begin
        if rising_edge(clk_load) then
            Registros_kernel <= Data_in_kernel;
            Registros_matriz <= Data_in_matriz;
                   
        --  Etapa 1 Multiplicación
            for i in 0 to NUM_REGS-1 loop
                P(i) <= std_logic_vector(
                    signed(Registros_kernel(i)) * signed(Registros_matriz(i))
                    );
            end loop;   

        -- Etapa 2 Suma        
            k1x1(0,0) <= P(26);
            k1x1(1,0) <= P(18);            
            k1x1(2,0) <= P(9);
            k1x1(3,0) <= P(0);                                                
            for i in 0 to 11 loop    
                s1(i) <= std_logic_vector(
                    resize(signed(P(PAR_ALTO_1(i))), 17) + 
                    resize(signed(P(PAR_BAJO_1(i))), 17)
                );                   
            end loop; 
            
        -- Etapa 3 Suma        
            k1x1(0,1) <= k1x1(0,0);
            k1x1(1,1) <= k1x1(1,0);            
            k1x1(2,1) <= k1x1(2,0);
            k1x1(3,1) <= k1x1(3,0);               
            for i in 0 to 5 loop    
                s2(i) <= std_logic_vector(
                    resize(signed(s1(PAR_ALTO_2(i))), 18) + 
                    resize(signed(s1(PAR_BAJO_2(i))), 18)
                );                  
            end loop;   

        -- Etapa 4 Suma 
            --k1x1(0,2) <= k1x1(0,1);
            k1x1(1,2) <= k1x1(1,1);            
            k1x1(2,2) <= k1x1(2,1);
            k1x1(3,2) <= k1x1(3,1);         
            kernel2x2(0) <= s2(0);
            for i in 0 to 2 loop
                s3(i) <= std_logic_vector(
                    resize(signed(s2(PAR_ALTO_3(i))), 19) + 
                    resize(signed(s2(PAR_BAJO_3(i))), 19)
                );               
            end loop;  
            
        -- Etapa 5 Suma 
            --k1x1(0,3) <= k1x1(0,2);
            kernel2x2(1) <= kernel2x2(0);                    
            corrimiento(0,0) <= s3(1);
            corrimiento(0,1) <= s3(2);            
            for i in 0 to 2 loop               
                s4(i) <= std_logic_vector(
                    resize(signed(s3(PAR_ALTO_4(i))), 20) + 
                    resize(signed(k1x1(PAR_BAJO_4(i),2)), 20)
                );
            end loop;   
            
        -- Etapa 6 Suma
            --k1x1(0,4) <= k1x1(0,3);
            kernel2x2(2) <= kernel2x2(1);
            kernel3x3(1) <= s4(0);                                            
            corrimiento(1,1) <= corrimiento(0,1);         
            s5(0) <= std_logic_vector(
                      resize(signed(s4(0)), 21) + resize(signed(corrimiento(0,0)), 21)
                  );
                  
        -- Etapa 7 Suma 
            --k1x1(0,5) <= k1x1(0,4);
            kernel2x2(3) <= kernel2x2(2);
            kernel3x3(0) <= kernel3x3(1);                                                        
            kernel4x4(0) <= s5(0) & '0';
            s6(0) <= std_logic_vector(
                      resize(signed(s5(0)), 22) + resize(signed(corrimiento(1,1)), 22)
                  );                                                                        
        end if;
    end process;
    
    Data_out_5x5 <= s6;
    Data_out_4x4 <= kernel4x4;
    Data_out_3x3(0) <= kernel3x3(0) & "00";
    Data_out_2x2(0) <= kernel2x2(3) & "0000";
    --Data_out_1x1(0) <= k1x1(0,5) & "000000";
    
end Behavioral;