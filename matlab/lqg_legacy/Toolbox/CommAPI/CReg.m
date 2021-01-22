classdef CReg
    methods (Static)
        function bin = load(bin_filename)
            fid = fopen(bin_filename, 'rb');
            bin = fread(fid, inf, 'uint8');
            fclose(fid);
        end
        
        function build(src_filename, bin_filename, entry_fcn, mem_loc, cc_flags, verbose, output_immediate_files)
            if nargin < 3
                error('Not enough arguments given.');
            end
            
            if nargin < 4
                %warning('Assuming relative addressing');
                mem_loc = '0x0';
            end
            
            if nargin < 5
                cc_flags = '';
            end

            if nargin < 6
                verbose = false;
            end
            
            if nargin < 7
                output_immediate_files = false;
            end                      

            % GNU tools
            CC      = 'arm-elf-gcc';
            OBJDUMP = 'arm-elf-objdump';
            OBJCOPY = 'arm-elf-objcopy';
            
            % Set up commands
            % TODO: Skriv filer till temp-mapp istället
            [pathstr, obj, ~] = fileparts(src_filename);
            obj_file  = [pathstr obj '.o'];
            elf_file  = [pathstr obj '.elf'];
            map_file  = [pathstr obj '.map'];
            lst_file  = [pathstr obj '.lst'];
            ihex_file = [pathstr obj '.hex'];
            ld_file   = [pathstr obj '.ld'];
            
            if output_immediate_files
                map_arg = [' -Wl,-Map,' map_file ' '];
            else
                map_arg = '';
            end
            
            start_section = ['.text.' entry_fcn];
            
            cc_cmd = [CC ' ' cc_flags ' -c -ffreestanding -fsigned-char -mcpu=arm7tdmi ' ...
                        ' -O3 ' ...
                        ' -Winline -Wall -Werror-implicit-function-declaration ' ...
                        ' --param max-inline-insns-single=1000 ' ...
                        ' -mthumb -mthumb-interwork -ffunction-sections -fdata-sections ' ...
                        ' -std=gnu99 ' ...
                        ' ' src_filename ' -o ' obj_file];

            ld_cmd = [CC ' -nostartfiles -Wl,-T,' ld_file ...
                        ' -mthumb -mthumb-interwork ' ...
                        ' -Wl,--allow-multiple-definition ' map_arg  ...
                        ' ' obj_file ' -lm  -o ' elf_file];

            lst_cmd = [OBJDUMP ' -d ' elf_file ' > ' lst_file];

            gen_ihex_cmd = [OBJCOPY ' -O ihex ' elf_file ' ' ihex_file];

            gen_bin_cmd = [OBJCOPY ' -O binary ' elf_file ' ' bin_filename];

            % Compile the C source file
            CReg.run_cmd(cc_cmd, verbose, 'Unable to compile file');
            
            % Generate the linker script
            CReg.gen_ld_script(ld_file, mem_loc, start_section);

            % Perform the linking
            CReg.run_cmd(ld_cmd, verbose, 'Unable to link files');

            if output_immediate_files
                % Disassemble the file
                CReg.run_cmd(lst_cmd, verbose, 'Unable to create lst file');

                % Generate ihex
                CReg.run_cmd(gen_ihex_cmd, verbose, 'Unable to create ihex file');
            end

            % Generate binary
            CReg.run_cmd(gen_bin_cmd, verbose, 'Unable to generate binary file');
            
            % Remove elf and object files
            delete(elf_file);
            delete(obj_file);
            delete(ld_file);
        end
    end
    
    methods (Access=private, Static)
        function gen_ld_script(ld_filename, mem_loc, start_section)
            fid = fopen(ld_filename, 'wt');
            fprintf(fid, 'SECTIONS\n{\n    . = %s;\n    .text : { *(%s .text) }\n}', mem_loc, start_section);
            fclose(fid);
        end
        
        function run_cmd(cmd, verbose, err_msg)
            if verbose
                disp(cmd);
            end

            [ret output] = system(cmd);
            if ret ~= 0
                disp(output);
                error(err_msg);
            end
        end
    end
end