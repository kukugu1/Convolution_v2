library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Test_Valid_Data is
    generic(
        Data_length : integer := 128
    );
    Port( 
        Data_in  : in std_logic_vector((Data_length*Bits)-1 downto 0); --1024 datos para 128 registros de 8 bits
        clk, selector, T_valid_in : in std_logic;
        Bus_valid_Size            : in std_logic_vector(2 downto 0);
        Padding, kernel, Stride   : in std_logic_vector(1 downto 0);
        T_ready_out, VALID_OUT    : out std_logic;
        Salida_Mask_Adder_Tree    : out std_logic_vector(21 downto 0)
    );
end Test_Valid_Data;

architecture Behavioral of Test_Valid_Data is
signal EN_1, EN_1M, EN_1K           : std_logic;
signal rst_RPS, CAP_RPS, SEL        : std_logic;
signal clk_EN_1M, clk_EN_1K         : std_logic;
signal Data_out_RPS                 : std_logic_vector(7 downto 0) := x"00";
signal kernel_in, matriz_in         : std_logic_vector(7 downto 0) := x"00";
signal AdderTree_Enable, SR_Capture : std_logic;
signal Registros_kernel             : Data_array(0 to 26);
signal Registros_matriz             : Data_array(0 to 24);
signal Registros_Kernel_Mask, Registros_Matriz_Mask : Data_array(0 to 26);
signal Data_out_5x5, Data_out_4x4, Data_out_3x3, Data_out_2x2 : Vector_Array(0 to 0)(21 downto 0);

begin

    clk_EN_1M <= clk and EN_1M;
    clk_EN_1K <= clk and EN_1K;
    EN_1      <= EN_1M OR EN_1K;
    
    CBI : entity work.Control_Bus_in
    generic map(
        kernel_size => 27,
        matriz_size => 128
    )
    port map(
        clk            => clk,
        selector       => selector,
        T_valid        => T_valid_in,
        Bus_valid_Size => Bus_valid_Size,
        Padding        => Padding,
        rst            => rst_RPS,
        CAP            => CAP_RPS,
        EN_1K          => EN_1K,
        EN_1           => EN_1M,
        SEL            => SEL,
        T_ready        => T_ready_out
    );
    
    Parallel_Serial_Register : entity work.Registro_paralelo_serie
    generic map(
        Data_length => Data_length
    )
    port map(
        clk      => clk,
        enable   => EN_1,
        load     => CAP_RPS,
        rst      => rst_RPS,
        Data_in  => Data_in,
        Data_out => Data_out_RPS
    );
    
    Demux1 : entity work.Demux
    generic map(
        Data_length => 8
    )
    port map(
        sel      => SEL,
        entrada  => Data_out_RPS,
        salida_1 => matriz_in,
        salida_0 => kernel_in
    );

    Kernel_Registers : entity work.Registros_kernel
    generic map(
        Data_length => 8,
        NUM_REGS    => 27
    )    
    port map(
        clk      => clk_EN_1K,    
        rst      => '0',
        enable   => '1',
        Data_in  => kernel_in,
        Data_out => Registros_kernel
    );
    
    Matrix_Registers : entity work.Registros_Matriz
    generic map(
        Data_length => 8,
        Matriz_size => 132,
        ROW_LENGTH  => 5,
        NUM_ROWS    => 5,
        KERNEL_SIZE => 5 
    )
    port map(
        clk      => clk_EN_1M,
        rst      => '0',
        enable   => '1',
        Data_in  => matriz_in,
        Data_out => Registros_matriz
    );
    
    VD : entity work.Valid_Data
    generic map(
        DELAY_AdderTree_Enable => 1,
        DELAY_VALID_OUT        => 8
    )
    port map(
        clk              => clk_EN_1M,
        Bus_valid_Size   => Bus_valid_Size,
        kernel           => kernel,
        Stride           => Stride,
        Padding          => Padding,
        SR_Capture       => SR_Capture,
        AdderTree_Enable => AdderTree_Enable,
        VALID_OUT        => VALID_OUT
    );
    
    Kernel_Mask : entity work.Mask_kernel
    generic map(
        NUM_REGS => 27 
    )
    port map(
        clk           => clk,
        load          => SR_Capture,    
        Tamano_kernel => kernel,
        Data_in       => Registros_kernel,
        Data_out      => Registros_Kernel_Mask
    );
    
    Matrix_Mask : entity work.Mask_Matriz
    generic map(
        NUM_REGS => 25
    )    
    port map(
        clk           => clk,    
        load          => SR_Capture,
        Tamano_kernel => kernel,
        Data_in       => Registros_matriz,
        Data_out      => Registros_Matriz_Mask
    );
    
    AdderTree : entity work.Adder_tree
    generic map(
        NUM_REGS => 27
    )
    port map(
        clk            => clk_EN_1M,
        load           => AdderTree_Enable,
        Data_in_kernel => Registros_Kernel_Mask,
        Data_in_matriz => Registros_Matriz_Mask,
        Data_out_5x5   => Data_out_5x5, 
        Data_out_4x4   => Data_out_4x4, 
        Data_out_3x3   => Data_out_3x3, 
        Data_out_2x2   => Data_out_2x2
    );            
    
    Adder_Tree_Mask : entity work.Mask_Adder_tree
    port map(
        Tamano_kernel => kernel,
        Data_out_5x5  => Data_out_5x5, 
        Data_out_4x4  => Data_out_4x4, 
        Data_out_3x3  => Data_out_3x3, 
        Data_out_2x2  => Data_out_2x2, 
        Data_out      => Salida_Mask_Adder_Tree
    );        

end Behavioral;
