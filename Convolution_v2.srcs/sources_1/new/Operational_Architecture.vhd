library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Operational_Architecture is
    generic(
        Data_length    : integer := 128;
        Bias_length    : natural := 8
    );
    Port(
        Data_in  : in std_logic_vector((Data_length*Bits)-1 downto 0); --1024 datos    
        Bias     : in std_logic_vector(Bias_length-1 downto 0);  
        kernel   : in std_logic_vector(1 downto 0);
        clk, rst_RPS, CAP_RPS, EN_1, EN_1K, SEL : in std_logic;
        rst_RSP, CAP_RSP, EN_2 : in std_logic;                
        SR_Capture, AdderTree_Enable, clk_WAIT_0 : in std_logic;
        data_out : out std_logic_vector((Data_length*Bits)-1 downto 0)
    );
end Operational_Architecture;

architecture Behavioral of Operational_Architecture is
-- ************* Auxiliar signals parallel serial register *************
signal Data_out_RPS : std_logic_vector(7 downto 0) := x"00";

-- ************* Auxiliar signals Demux *************
signal kernel_in, matriz_in : std_logic_vector(7 downto 0) := x"00";

-- ************* Registers *************
signal Registros_kernel : Data_array(0 to 26);
signal Registros_matriz : Data_array(0 to 24);

-- ************* Mask Registers *************
signal Registros_Kernel_Mask, Registros_Matriz_Mask : Data_array(0 to 26);

-- ************* Adder Tree´s auxiliar signals *************
signal Data_out_5x5, Data_out_4x4, Data_out_3x3, Data_out_2x2 : Vector_Array(0 to 0)(21 downto 0);

-- ************* Adder Tree´s mask auxiliar signals *************
signal Salida_Mask_Adder_Tree : std_logic_vector(21 downto 0);

-- ************* Bias and reduction auxiliar signals *************
signal Data_in_RSP : std_logic_vector(7 downto 0);

-- ************* Auxiliar clocks *************
signal clk_EN_1, clk_EN_1K : std_logic;

begin
    clk_EN_1  <= clk and EN_1;
    clk_EN_1K <= clk and EN_1K; 
    
    Parallel_Serial_Register : entity work.Registro_paralelo_serie
    generic map(
        Data_length => Data_length
    )
    port map(
        clk => clk_WAIT_0,
        enable => EN_1 OR EN_1K,
        load => CAP_RPS,
        rst => rst_RPS,
        Data_in => Data_in,
        Data_out => Data_out_RPS
    );
    
    Demux1 : entity work.Demux
    generic map(
        Data_length => 8
    )
    port map(
        sel => SEL,
        entrada => Data_out_RPS,
        salida_1 => matriz_in,
        salida_0 => kernel_in
    );

    Kernel_Registers : entity work.Registros_kernel
    generic map(
        Data_length => 8,
        NUM_REGS => 27
    )    
    port map(
        clk => clk_EN_1K,    
        rst => '0',
        enable => '1',
        Data_in => kernel_in,
        Data_out => Registros_kernel
    );
    
    Matrix_Registers : entity work.Registros_Matriz
    generic map(
        Data_length => 8,
        Matriz_size => 132,
        ROW_LENGTH => 5,
        NUM_ROWS => 5,
        KERNEL_SIZE => 5 
    )
    port map(
        clk => clk_EN_1,
        rst => '0',
        enable => '1',
        Data_in => matriz_in,
        Data_out => Registros_matriz
    );
    
    Kernel_Mask : entity work.Mask_kernel
    generic map(
        NUM_REGS => 27 
    )
    port map(
        load => SR_Capture,    
        Tamano_kernel => kernel,
        Data_in => Registros_kernel,
        Data_out => Registros_Kernel_Mask
    );
    
    Matrix_Mask : entity work.Mask_Matriz
    generic map(
        NUM_REGS => 25 
    )    
    port map(
        load => SR_Capture,
        Tamano_kernel => kernel,
        Data_in => Registros_matriz,
        Data_out => Registros_Matriz_Mask
    );
    
    AdderTree : entity work.Adder_tree
    generic map(
        NUM_REGS => 27
    )
    port map(
        clk => clk_EN_1,
        load => AdderTree_Enable,
        Data_in_kernel => Registros_Kernel_Mask,
        Data_in_matriz => Registros_Matriz_Mask,
        Data_out_5x5 => Data_out_5x5, 
        Data_out_4x4 => Data_out_4x4, 
        Data_out_3x3 => Data_out_3x3, 
        Data_out_2x2 => Data_out_2x2
    );            
    
    Adder_Tree_Mask : entity work.Mask_Adder_tree
    port map(
        Tamano_kernel => kernel,
        Data_out_5x5 => Data_out_5x5, 
        Data_out_4x4 => Data_out_4x4, 
        Data_out_3x3 => Data_out_3x3, 
        Data_out_2x2 => Data_out_2x2, 
        Data_out => Salida_Mask_Adder_Tree
    );    
    
    BaR : entity work.Bias_and_reduction
    generic map(
        Data_in_length => 22,
        Bias_length => Bias_length 
    )
    port map(
        Bias => Bias,
        Data_in => Salida_Mask_Adder_Tree,
        Data_out => Data_in_RSP 
    );    
    
   Serial_Parallel_Register : entity work.Registro_serie_paralelo
    generic map(
        DATA_WIDTH => 8,
        TOTAL_WIDTH => 1024
    )
    port map(
        clk => clk,
        rst => rst_RSP,
        enable => EN_2,
        load => CAP_RSP,
        data_in => Data_in_RSP,
        data_out => data_out
    );
    
end Behavioral;
