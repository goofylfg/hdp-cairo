from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from src.hdp.types import BlockSampledDataLake, BlockSampledComputationalTask
from src.hdp.tasks.block_sampled_task import AGGREGATE_FN
namespace BlockSampledDataLakeMocker {
    
    func get_header_property() -> (datalake_input: felt*, datalake_input_bytes_len: felt, datalake: BlockSampledDataLake, property_type: felt) {
        alloc_locals;

        let (datalake_input: felt*) = alloc();
        local datalake: BlockSampledDataLake;
        local datalake_bytes_len: felt;

        %{
            ids.datalake.block_range_start = 5382810
            ids.datalake.block_range_end = 5382815
            ids.datalake.increment = 1
            ids.datalake.property_type = 1
            ids.datalake.properties = segments.gen_arg([1, 8])
            ids.datalake.hash.low = 107436943091682614843991191375763387426
            ids.datalake.hash.high = 43197761823970343188211903881620784812

            datalake_input = [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x9a22520000000000, 0x0, 0x0, 0x0, 0x9f22520000000000, 0x0, 0x0, 0x0, 0x100000000000000, 0x0, 0x0, 0x0, 0xa000000000000000, 0x0, 0x0, 0x0, 0x200000000000000, 0x801, 0x0, 0x0, 0x0]
            ids.datalake_bytes_len = 224
            segments.write_arg(ids.datalake_input, datalake_input)
        %}

        return (
            datalake_input,
            datalake_bytes_len,
            datalake,
            1
        );
    }

    func get_account_property() -> (datalake_input: felt*, datalake_input_bytes_len: felt, datalake: BlockSampledDataLake, property_type: felt) {
        alloc_locals;

        let (datalake_input) = alloc();
        local datalake: BlockSampledDataLake;
        local datalake_bytes_len: felt;

        %{
            ids.datalake.block_range_start = 4952100
            ids.datalake.block_range_end = 4952120
            ids.datalake.increment = 1
            ids.datalake.property_type = 2
            ids.datalake.properties = segments.gen_arg([0x2, 0xaad30603936f2c7f, 0x12f5986a6c3a6b73, 0xd43640f7, 0x1])
            ids.datalake.hash.low = 171115948030875793627051908460499129522
            ids.datalake.hash.high = 56570840644286196296062165637174297103

            datalake_input = [0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x24904b0000000000,0x0,0x0,0x0,0x38904b0000000000,0x0,0x0,0x0,0x100000000000000,0x0,0x0,0x0,0xa000000000000000,0x0,0x0,0x0,0x1600000000000000,0xd30603936f2c7f02,0xf5986a6c3a6b73aa,0x1d43640f712,0x0]        
            ids.datalake_bytes_len = 224
            segments.write_arg(ids.datalake_input, datalake_input)
        %}

        return (
            datalake_input,
            datalake_bytes_len,
            datalake,
            2
        );
    }

    func get_storage_property() -> (datalake_input: felt*, datalake_input_bytes_len: felt, datalake: BlockSampledDataLake, property_type: felt) {
        alloc_locals;

        let (datalake_input) = alloc();
        local datalake: BlockSampledDataLake;
        local datalake_bytes_len: felt;

        %{
            ids.datalake.block_range_start = 5382810
            ids.datalake.block_range_end = 5382815
            ids.datalake.increment = 1
            ids.datalake.property_type = 3
            ids.datalake.properties = segments.gen_arg([0x3, 0x3b7ce9ddbc1ce75, 0x8568f69565aa0e20, 0x20b962c9, 0x0, 0x0, 0x0, 0x200000000000000])
            ids.datalake.hash.low = 215828760250207880142328954482205465726
            ids.datalake.hash.high = 268581037684598511895223889006659959396

            datalake_input = [0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x9a22520000000000,0x0,0x0,0x0,0x9f22520000000000,0x0,0x0,0x0,0x100000000000000,0x0,0x0,0x0,0xa000000000000000,0x0,0x0,0x0,0x3500000000000000,0xb7ce9ddbc1ce7503,0x68f69565aa0e2003,0x20b962c985,0x0,0x0,0x0,0x200000000,0x0]
            ids.datalake_bytes_len = 256
            segments.write_arg(ids.datalake_input, datalake_input)
        %}

        return (
            datalake_input,
            datalake_bytes_len,
            datalake,
            3
        );
    }
}

namespace BlockSampledTaskMocker {

    func get_init_data() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt**,
        tasks_bytes_len: felt*,
        datalake: BlockSampledDataLake,
        datalakes_inputs: felt**,
        datalakes_bytes_len: felt*,
        tasks_len: felt
    ) {
        alloc_locals;

        let (datalake_input, datalake_bytes_len, datalake, prop_id) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        let (tasks_bytes_len) = alloc();

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little
            # mocks python params that are available during full flow
            block_sampled_tasks = [{'property_type': 1 }]
            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
            segments.write_arg(ids.tasks_bytes_len, [len(task_bytes)])
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}

        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0x407E98D423A7BB2DBF09B0E42601FC9B, high=0xEF8B01F35B404615F0339EEFAE7719A2),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.AVG, //avg
            ctx_operator=0,
            ctx_value=Uint256(low=0, high=0),
        );

        let (tasks_inputs: felt**) = alloc();
        let (datalakes_inputs: felt**) = alloc();
        let (datalakes_bytes_len: felt*) = alloc();
        assert tasks_inputs[0] = task_input;
        assert datalakes_inputs[0] = datalake_input;
        assert datalakes_bytes_len[0] = datalake_bytes_len;
    

        return (task, tasks_inputs, tasks_bytes_len, datalake, datalakes_inputs, datalakes_bytes_len, 1);
    }

    func get_avg_task() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt*,
        tasks_bytes_len: felt,
        datalake: BlockSampledDataLake
    ) {
        alloc_locals;

        let (_, _, datalake, _) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        local tasks_bytes_len: felt;

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little

            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
            ids.tasks_bytes_len = len(task_bytes)
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}

        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0x407E98D423A7BB2DBF09B0E42601FC9B, high=0xEF8B01F35B404615F0339EEFAE7719A2),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.AVG, //avg
            ctx_operator=0,
            ctx_value=Uint256(low=0, high=0),
        );

        return (task, task_input, tasks_bytes_len, datalake);
    }

    func get_sum_task() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt*,
        tasks_bytes_len: felt,
        datalake: BlockSampledDataLake
    ) {
        alloc_locals;

        let (_, _, datalake, _) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        local tasks_bytes_len: felt;

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little
            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F20000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
            ids.tasks_bytes_len = len(task_bytes)
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}

        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0x3CB6684D1B4B7FDEA3FBACAEA422C944, high=0x02F8516E3F7BE7FCCFDE22FB4A98DF37),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.SUM,
            ctx_operator=0,
            ctx_value=Uint256(low=0, high=0),
        );

        return (task, task_input, tasks_bytes_len, datalake);
    }

    func get_min_task() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt*,
        tasks_bytes_len: felt,
        datalake: BlockSampledDataLake
    ) {
        alloc_locals;

        let (_, _, datalake, _) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        local tasks_bytes_len: felt;

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little
            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F20000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
            ids.tasks_bytes_len = len(task_bytes)
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}
        
        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0x9F439795EE0CA868B463479E5A905BF0, high=0x72CEFA1188B199ECEEAB39767CD32605),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.MIN,
            ctx_operator=0,
            ctx_value=Uint256(low=0, high=0),
        );

        return (task, task_input, tasks_bytes_len, datalake);
    }

    func get_max_task() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt*,
        tasks_bytes_len: felt,
        datalake: BlockSampledDataLake
    ) {
        alloc_locals;

        let (_, _, datalake, _) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        local tasks_bytes_len: felt;

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little
            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F20000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
            ids.tasks_bytes_len = len(task_bytes)
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}
        
        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0x1CD2E160D860B4D1BD1E327B6AA209BD, high=0xCABA4809710EB228D6A31DE1B852DFB7),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.MAX,
            ctx_operator=0,
            ctx_value=Uint256(low=0, high=0),
        );

        return (task, task_input, tasks_bytes_len, datalake);
    }

    func get_count_if_task() -> (
        task: BlockSampledComputationalTask,
        tasks_inputs: felt*,
        tasks_bytes_len: felt,
        datalake: BlockSampledDataLake
    ) {
        alloc_locals;

        let (_, _, datalake, _) = BlockSampledDataLakeMocker.get_header_property();
        let (task_input) = alloc();
        local tasks_bytes_len: felt;

        %{
            from tools.py.utils import bytes_to_8_bytes_chunks_little
            task_bytes = bytes.fromhex("22B4DA4CC94620C9DFCC5AE7429AD350AC86587E6D9925A6209587EF17967F200000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000186a0")
            ids.tasks_bytes_len = len(task_bytes)
            segments.write_arg(ids.task_input, bytes_to_8_bytes_chunks_little(task_bytes))
        %}

        let task = BlockSampledComputationalTask(
            hash=Uint256(low=0xAE5641FEA9032C936D7E54D7CF36E2C3, high=0xA53CFAB970F9780B3C39CFAC1DD3D425),
            datalake=datalake,
            aggregate_fn_id=AGGREGATE_FN.COUNT,
            ctx_operator=1,
            ctx_value=Uint256(low=0x186a0, high=0),
        );

        return (task, task_input, tasks_bytes_len, datalake);
    }



    // func get_avg_params() -> (input: felt*, hash_low: felt, hash_high: felt, aggregate_fn_id: felt) {
    //     let (params) = alloc();
    //     %{
    //         avg_param = [0x7b57a805b1991c7e,0xa25f1b72f077813f,0x8c59e10a5510fa64,0xca0ed388358a01bf,0x677661,0x0,0x0,0x0,0x0,0x0,0x0,0x6000000000000000,0x0,0x0,0x0,0x0]
    //         segments.write_arg(ids.params, avg_param)
    //     %}

    //     let datalake_hash_low = 215828760250207880142328954482205465726;
    //     let datalake_hash_high = 268581037684598511895223889006659959396;
    //     let aggregate_fn_id = 0;

    //     return (params, datalake_hash_low, datalake_hash_high, aggregate_fn_id);
    // }
    // func get_sum_params() -> (input: felt*, hash_low: felt, hash_high: felt, aggregate_fn_id: felt) {
    //     let (params) = alloc();
    //     %{
    //         avg_param = [0x7b57a805b1991c7e,0xa25f1b72f077813f,0x8c59e10a5510fa64,0xca0ed388358a01bf,0x6d7573,0x0,0x0,0x0,0x0,0x0,0x0,0x6000000000000000,0x0,0x0,0x0,0x0]
    //         segments.write_arg(ids.params, avg_param)
    //     %}

    //     let datalake_hash_low = 215828760250207880142328954482205465726;
    //     let datalake_hash_high = 268581037684598511895223889006659959396;
    //     let aggregate_fn_id = 1;

    //     return (params, datalake_hash_low, datalake_hash_high, aggregate_fn_id);
    // }

    // func get_min_params() -> (input: felt*, hash_low: felt, hash_high: felt, aggregate_fn_id: felt) {
    //     let (params) = alloc();
    //     %{
    //         avg_param = [0xed3d140441724ef1, 0x90fec1bdd5a2342a, 0x43c796f33033209a, 0xd9c318e200d6db8f, 0x6e696d, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x6000000000000000, 0x0, 0x0, 0x0, 0x0]
    //         segments.write_arg(ids.params, avg_param)
    //     %}

    //     let datalake_hash_low = 192731604340388351313785861398408089329;
    //     let datalake_hash_high = 289455477656395998637945769668287602842;
    //     let aggregate_fn_id = 2;

    //     return (params, datalake_hash_low, datalake_hash_high, aggregate_fn_id);
    // }

    // func get_max_params() -> (input: felt*, hash_low: felt, hash_high: felt, aggregate_fn_id: felt) {
    //     let (params) = alloc();
    //     %{
    //         avg_param = [0xed3d140441724ef1, 0x90fec1bdd5a2342a, 0x43c796f33033209a, 0xd9c318e200d6db8f, 0x78616d, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x6000000000000000, 0x0, 0x0, 0x0, 0x0]
    //         segments.write_arg(ids.params, avg_param)
    //     %}

    //     let datalake_hash_low = 192731604340388351313785861398408089329;
    //     let datalake_hash_high = 289455477656395998637945769668287602842;
    //     let aggregate_fn_id = 3;

    //     return (params, datalake_hash_low, datalake_hash_high, aggregate_fn_id);
    // }
}



