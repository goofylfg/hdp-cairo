%builtins output pedersen range_check bitwise keccak poseidon

from starkware.cairo.common.cairo_builtins import (
    PoseidonBuiltin,
    BitwiseBuiltin,
    KeccakBuiltin,
    HashBuiltin,
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.builtin_keccak.keccak import keccak, keccak_bigend

// Verifiers:
from src.verifiers.account_verifier import populate_account_segments, verify_n_accounts
from src.verifiers.storage_item_verifier import (
    populate_storage_item_segments,
    verify_n_storage_items,
)
from src.verifiers.header_verifier import verify_headers_inclusion
from src.verifiers.mmr_verifier import verify_mmr_meta
from src.verifiers.transaction_verifier import verify_n_transaction_proofs

from src.types import (
    Header,
    MMRMeta,
    Account,
    AccountValues,
    StorageItem,
    TransactionProof,
    Transaction,
    ComputationalTask,
)

from src.memorizer import (
    HeaderMemorizer,
    AccountMemorizer,
    StorageMemorizer,
    TransactionMemorizer,
    MEMORIZER_DEFAULT,
)
from packages.eth_essentials.lib.utils import pow2alloc128, write_felt_array_to_dict_keys

from src.tasks.computational import Task
from src.merkle import compute_tasks_root, compute_results_root
from src.chain_info import fetch_chain_info

func main{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    run{
        output_ptr=output_ptr,
        pedersen_ptr=pedersen_ptr,
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        keccak_ptr=keccak_ptr,
        poseidon_ptr=poseidon_ptr,
    }();

    return ();
}

func run{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;

    // Header Params
    local headers_len: felt;
    let (headers: Header*) = alloc();

    // MMR Params
    local mmr_meta: MMRMeta;

    // Account Params
    let (accounts: Account*) = alloc();
    let (account_values: AccountValues*) = alloc();
    local accounts_len: felt;

    // Storage Params
    let (storage_items: StorageItem*) = alloc();
    let (storage_values: Uint256*) = alloc();
    local storage_items_len: felt;

    // Transaction Params
    let (transaction_proofs: TransactionProof*) = alloc();
    let (transactions: Transaction*) = alloc();
    local transaction_proof_len: felt;

    // Memorizers
    let (header_dict, header_dict_start) = HeaderMemorizer.initialize();
    let (account_dict, account_dict_start) = AccountMemorizer.initialize();
    let (storage_dict, storage_dict_start) = StorageMemorizer.initialize();
    let (transaction_dict, transaction_dict_start) = TransactionMemorizer.initialize();

    // Task Params
    let (tasks: ComputationalTask*) = alloc();
    local tasks_len: felt;

    let (results: Uint256*) = alloc();

    // Misc
    let pow2_array: felt* = pow2alloc128();
    local chain_id: felt;

    %{
        from tools.py.utils import split_128, count_leading_zero_nibbles_from_hex

        debug_mode = False
        def conditional_print(*args):
            if debug_mode:
                print(*args)

        def hex_to_int(x):
            return int(x, 16)

        def hex_to_int_array(hex_array):
            return [int(x, 16) for x in hex_array]

        def nested_hex_to_int_array(hex_array):
            return [[int(x, 16) for x in y] for y in hex_array]

        def write_headers(ptr, headers):
            offset = 0
            ids.headers_len = len(headers)

            for header in headers:
                memory[ptr._reference_value + offset] = segments.gen_arg(hex_to_int_array(header["rlp"]))
                memory[ptr._reference_value + offset + 1] = len(header["rlp"])
                memory[ptr._reference_value + offset + 2] = header["rlp_bytes_len"]
                memory[ptr._reference_value + offset + 3] = header["proof"]["leaf_idx"]
                memory[ptr._reference_value + offset + 4] = len(header["proof"]["mmr_path"])
                memory[ptr._reference_value + offset + 5] = segments.gen_arg(hex_to_int_array(header["proof"]["mmr_path"]))
                offset += 6

        def write_tx_proofs(ptr, program_input):
            offset = 0
            if "transactions" in program_input:
                tx_proofs = program_input["transactions"]
                ids.transaction_proof_len = len(tx_proofs)

                for tx_proof in tx_proofs:
                    leading_zeroes = count_leading_zero_nibbles_from_hex(tx_proof["key"])
                    (key_low, key_high) = split_128(int(tx_proof["key"], 16))

                    memory[ptr._reference_value + offset] = tx_proof["block_number"]
                    memory[ptr._reference_value + offset + 1] = len(tx_proof["proof"])
                    memory[ptr._reference_value + offset + 2] = segments.gen_arg(tx_proof["proof_bytes_len"])
                    memory[ptr._reference_value + offset + 3] = segments.gen_arg(nested_hex_to_int_array(tx_proof["proof"]))
                    memory[ptr._reference_value + offset + 4] = key_low
                    memory[ptr._reference_value + offset + 5] = key_high
                    memory[ptr._reference_value + offset + 6] = leading_zeroes

                    offset += 7
            else:
                ids.transaction_proof_len = 0

        def write_mmr_meta(mmr_meta):
            ids.mmr_meta.id = mmr_meta["id"]
            ids.mmr_meta.root = hex_to_int(mmr_meta["root"])
            ids.mmr_meta.size = mmr_meta["size"]
            ids.mmr_meta.peaks_len = len(mmr_meta["peaks"])
            ids.mmr_meta.peaks = segments.gen_arg(hex_to_int_array(mmr_meta["peaks"]))
            # ids.chain_id = mmr_meta["chain_id"]

        # MMR Meta
        write_mmr_meta(program_input['mmr'])

        # Header Params
        write_headers(ids.headers, program_input["headers"])

        # Account + Storage Params
        ids.accounts_len = len(program_input['accounts'])
        ids.storage_items_len = len(program_input['storages'])

        # Transaction params
        write_tx_proofs(ids.transaction_proofs, program_input)

        # Task and Datalake
        ids.tasks_len = len(program_input['tasks'])
    %}

    // Check 1: Ensure we have a valid pair of mmr_root and peaks
    verify_mmr_meta{pow2_array=pow2_array}(mmr_meta);

    // Write the peaks to the dict if valid
    let (local peaks_dict) = default_dict_new(default_value=0);
    tempvar peaks_dict_start = peaks_dict;
    write_felt_array_to_dict_keys{dict_end=peaks_dict}(
        array=mmr_meta.peaks, index=mmr_meta.peaks_len - 1
    );

    // Fetch matching chain info
    let (local chain_info) = fetch_chain_info(1);

    // Check 2: Ensure the header is contained in a peak, and that the peak is known
    verify_headers_inclusion{
        range_check_ptr=range_check_ptr,
        poseidon_ptr=poseidon_ptr,
        pow2_array=pow2_array,
        peaks_dict=peaks_dict,
        header_dict=header_dict,
    }(headers=headers, mmr_size=mmr_meta.size, n_headers=headers_len, index=0);

    populate_account_segments(accounts=accounts, n_accounts=accounts_len, index=0);

    populate_storage_item_segments(
        storage_items=storage_items, n_storage_items=storage_items_len, index=0
    );

    // Check 3: Ensure the account proofs are valid
    verify_n_accounts{
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        keccak_ptr=keccak_ptr,
        headers=headers,
        header_dict=header_dict,
        account_dict=account_dict,
        pow2_array=pow2_array,
    }(
        accounts=accounts,
        accounts_len=accounts_len,
        account_values=account_values,
        account_value_idx=0,
    );

    // Check 4: Ensure the account slot proofs are valid
    verify_n_storage_items{
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        keccak_ptr=keccak_ptr,
        account_values=account_values,
        account_dict=account_dict,
        storage_dict=storage_dict,
        pow2_array=pow2_array,
    }(
        storage_items=storage_items,
        storage_items_len=storage_items_len,
        storage_values=storage_values,
        state_idx=0,
    );

    // Check 5: Verify the transaction proofs
    verify_n_transaction_proofs{
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        poseidon_ptr=poseidon_ptr,
        keccak_ptr=keccak_ptr,
        transactions=transactions,
        transaction_dict=transaction_dict,
        headers=headers,
        header_dict=header_dict,
        pow2_array=pow2_array,
        chain_info=chain_info,
    }(tx_proofs=transaction_proofs, tx_proofs_len=transaction_proof_len, index=0);

    %{ print("headers verified") %}
    // Verified data is now in memorizer, and can be used for further computation
    Task.init{
        range_check_ptr=range_check_ptr,
        bitwise_ptr=bitwise_ptr,
        keccak_ptr=keccak_ptr,
        tasks=tasks,
        pow2_array=pow2_array,
    }(tasks_len, 0);

    Task.execute{
        range_check_ptr=range_check_ptr,
        pedersen_ptr=pedersen_ptr,
        bitwise_ptr=bitwise_ptr,
        poseidon_ptr=poseidon_ptr,
        account_dict=account_dict,
        account_values=account_values,
        storage_dict=storage_dict,
        storage_values=storage_values,
        header_dict=header_dict,
        headers=headers,
        transaction_dict=transaction_dict,
        transactions=transactions,
        pow2_array=pow2_array,
        tasks=tasks,
    }(results=results, tasks_len=tasks_len, index=0);

    let tasks_root = compute_tasks_root{
        range_check_ptr=range_check_ptr, bitwise_ptr=bitwise_ptr, keccak_ptr=keccak_ptr
    }(tasks=tasks, tasks_len=tasks_len);

    let results_root = compute_results_root{
        range_check_ptr=range_check_ptr, bitwise_ptr=bitwise_ptr, keccak_ptr=keccak_ptr
    }(tasks=tasks, results=results, tasks_len=tasks_len);

    %{
        print(f"Tasks Root: {hex(ids.tasks_root.low)} {hex(ids.tasks_root.high)}")
        print(f"Results Root: {hex(ids.results_root.low)} {hex(ids.results_root.high)}")
    %}

    // Post Verification Checks: Ensure the roots match the expected roots
    %{
        if "results_root" in program_input:
            assert ids.results_root.low == hex_to_int(program_input["results_root"]["low"]), "Expected results root mismatch"
            assert ids.results_root.high == hex_to_int(program_input["results_root"]["high"]), "Expected results root mismatch"

        if "tasks_root" in program_input:
            assert ids.tasks_root.low == hex_to_int(program_input["tasks_root"]["low"]), "Expected tasks root mismatch"
            assert ids.tasks_root.high == hex_to_int(program_input["tasks_root"]["high"]), "Expected tasks root mismatch"
    %}

    // Post Verification Checks: Ensure dict consistency
    default_dict_finalize(peaks_dict_start, peaks_dict, 0);
    default_dict_finalize(header_dict_start, header_dict, MEMORIZER_DEFAULT);
    default_dict_finalize(account_dict_start, account_dict, MEMORIZER_DEFAULT);
    default_dict_finalize(storage_dict_start, storage_dict, MEMORIZER_DEFAULT);
    default_dict_finalize(transaction_dict_start, transaction_dict, MEMORIZER_DEFAULT);

    [ap] = mmr_meta.root;
    [ap] = [output_ptr], ap++;

    [ap] = mmr_meta.size;
    [ap] = [output_ptr + 1], ap++;

    [ap] = results_root.low;
    [ap] = [output_ptr + 2], ap++;

    [ap] = results_root.high;
    [ap] = [output_ptr + 3], ap++;

    [ap] = tasks_root.low;
    [ap] = [output_ptr + 4], ap++;

    [ap] = tasks_root.high;
    [ap] = [output_ptr + 5], ap++;

    [ap] = output_ptr + 6, ap++;
    let output_ptr = output_ptr + 6;

    return ();
}
