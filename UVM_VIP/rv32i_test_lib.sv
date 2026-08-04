






















`ifndef RV32I_TEST_LIB_SV
`define RV32I_TEST_LIB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import rv32i_pkg::*;




class rv32i_base_test extends uvm_test;
    `uvm_component_utils(rv32i_base_test)

    rv32i_env env;

    function new(string name = "rv32i_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = rv32i_env::type_id::create("env", this);
    endfunction




    task run_seq(rv32i_base_seq seq_h);
        seq_h.env_h = env;
        seq_h.start(env.agent.sequencer);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass : rv32i_base_test








class rv32i_smoke_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_smoke_test)
    function new(string name = "rv32i_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_smoke_seq seq;
        phase.raise_objection(this);
        seq = rv32i_smoke_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_smoke_test




class rv32i_alu_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_alu_test)
    function new(string name = "rv32i_alu_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_alu_r_seq    rseq;
        rv32i_alu_i_seq    iseq;
        rv32i_lui_auipc_seq uiseq;
        phase.raise_objection(this);
        rseq  = rv32i_alu_r_seq   ::type_id::create("rseq");
        iseq  = rv32i_alu_i_seq   ::type_id::create("iseq");
        uiseq = rv32i_lui_auipc_seq::type_id::create("uiseq");
        run_seq(rseq);
        env.reset_reference_model();
        run_seq(iseq);
        env.reset_reference_model();
        run_seq(uiseq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_alu_test




class rv32i_branch_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_branch_test)
    function new(string name = "rv32i_branch_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_branch_seq seq;
        phase.raise_objection(this);
        seq = rv32i_branch_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_branch_test




class rv32i_jump_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_jump_test)
    function new(string name = "rv32i_jump_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_jump_seq seq;
        phase.raise_objection(this);
        seq = rv32i_jump_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_jump_test




class rv32i_forwarding_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_forwarding_test)
    function new(string name = "rv32i_forwarding_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_forwarding_seq seq;
        phase.raise_objection(this);
        seq = rv32i_forwarding_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_forwarding_test




class rv32i_hazard_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_hazard_test)
    function new(string name = "rv32i_hazard_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_loaduse_seq seq;
        phase.raise_objection(this);
        seq = rv32i_loaduse_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_hazard_test




class rv32i_loadstore_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_loadstore_test)
    function new(string name = "rv32i_loadstore_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_loadstore_seq seq;
        phase.raise_objection(this);
        seq = rv32i_loadstore_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_loadstore_test




class rv32i_memcover_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_memcover_test)

    function new(string name = "rv32i_memcover_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_memcover_seq seq;
        phase.raise_objection(this);
        seq = rv32i_memcover_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_memcover_test




class rv32i_csr_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_csr_test)
    function new(string name = "rv32i_csr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_csr_seq seq;
        phase.raise_objection(this);
        seq = rv32i_csr_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_csr_test




class rv32i_trap_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_trap_test)
    function new(string name = "rv32i_trap_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_trap_seq seq;
        phase.raise_objection(this);
        seq = rv32i_trap_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_trap_test




class rv32i_irq_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_irq_test)
    function new(string name = "rv32i_irq_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_irq_seq seq;
        phase.raise_objection(this);
        seq = rv32i_irq_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_irq_test




class rv32i_reset_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_reset_test)
    function new(string name = "rv32i_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_reset_mid_seq seq;
        phase.raise_objection(this);
        seq = rv32i_reset_mid_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_reset_test




class rv32i_misalign_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_misalign_test)
    function new(string name = "rv32i_misalign_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_misalign_seq seq;
        phase.raise_objection(this);
        seq = rv32i_misalign_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_misalign_test




class rv32i_random_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_random_test)
    function new(string name = "rv32i_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_random_seq seq;
        phase.raise_objection(this);
        seq = rv32i_random_seq::type_id::create("seq");
        if (!seq.randomize()) `uvm_error(get_name(), "Failed to randomize random_seq")
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_random_test




class rv32i_covclose_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_covclose_test)
    function new(string name = "rv32i_covclose_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        rv32i_covclose_seq seq;
        phase.raise_objection(this);
        seq = rv32i_covclose_seq::type_id::create("seq");
        run_seq(seq);
        phase.drop_objection(this);
    endtask
endclass : rv32i_covclose_test




class rv32i_regression_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_regression_test)
    function new(string name = "rv32i_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_name(), ">>>>>> REGRESSION START <<<<<<", UVM_NONE)

        begin rv32i_smoke_seq s = rv32i_smoke_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_alu_r_seq s = rv32i_alu_r_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_alu_i_seq s = rv32i_alu_i_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_lui_auipc_seq s = rv32i_lui_auipc_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_branch_seq s = rv32i_branch_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_jump_seq s = rv32i_jump_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_forwarding_seq s = rv32i_forwarding_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_loaduse_seq s = rv32i_loaduse_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_loadstore_seq s = rv32i_loadstore_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_csr_seq s = rv32i_csr_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_trap_seq s = rv32i_trap_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_irq_seq s = rv32i_irq_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_reset_mid_seq s = rv32i_reset_mid_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin rv32i_misalign_seq s = rv32i_misalign_seq::type_id::create("s"); run_seq(s); env.reset_reference_model(); end
        begin
            rv32i_random_seq s = rv32i_random_seq::type_id::create("s");
            void'(s.randomize());
            run_seq(s);
        end

        `uvm_info(get_name(), ">>>>>> REGRESSION COMPLETE <<<<<<", UVM_NONE)
        phase.drop_objection(this);
    endtask
endclass : rv32i_regression_test

`endif
