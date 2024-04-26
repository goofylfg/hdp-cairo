from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, KeccakBuiltin, PoseidonBuiltin
from starkware.cairo.common.dict_access import DictAccess
from packages.eth_essentials.lib.mpt import verify_mpt_proof
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.builtin_keccak.keccak import keccak
from starkware.cairo.common.alloc import alloc
from src.types import Account, AccountProof, Header, AccountValues
from packages.eth_essentials.lib.block_header import extract_state_root_little
from src.memorizer import HeaderMemorizer, AccountMemorizer

from src.decoders.header_decoder import HeaderDecoder, HeaderField

// Initializes the accounts, ensuring that the passed address matches the key.
// Params:
// - accounts: empty accounts array that the accounts will be writte too.
// - n_accounts: the number of accounts to initialize.
// - index: the current index of the account being initialized.
func populate_account_segments{
    range_check_ptr, bitwise_ptr: BitwiseBuiltin*, keccak_ptr: KeccakBuiltin*
}(accounts: Account*, n_accounts: felt, index: felt) {
    alloc_locals;
    if (index == n_accounts) {
        return ();
    } else {
        local account: Account;
        let (proofs: AccountProof*) = alloc();

        %{
            def write_account(account_ptr, proofs_ptr, account):
                memory[account_ptr._reference_value] = segments.gen_arg(hex_to_int_array(account["address"]))
                memory[account_ptr._reference_value + 1] = hex_to_int(account["account_key"]["low"])
                memory[account_ptr._reference_value + 2] = hex_to_int(account["account_key"]["high"])
                memory[account_ptr._reference_value + 3] = len(account["proofs"])
                memory[account_ptr._reference_value + 4] = proofs_ptr._reference_value

            def write_proofs(ptr, proofs):
                offset = 0
                for proof in proofs:
                    memory[ptr._reference_value + offset] = proof["block_number"]
                    memory[ptr._reference_value + offset + 1] = len(proof["proof"])
                    memory[ptr._reference_value + offset + 2] = segments.gen_arg(proof["proof_bytes_len"])
                    memory[ptr._reference_value + offset + 3] = segments.gen_arg(nested_hex_to_int_array(proof["proof"]))
                    offset += 4

            account = program_input["accounts"][ids.index]

            write_proofs(ids.proofs, account["proofs"])
            write_account(ids.account, ids.proofs, account)
        %}

        // ensure that address matches the key
        let (hash: Uint256) = keccak(account.address, 20);
        assert account.key.low = hash.low;
        assert account.key.high = hash.high;

        assert accounts[index] = account;

        return populate_account_segments(accounts=accounts, n_accounts=n_accounts, index=index + 1);
    }
}

// Verifies the validity of all of the accounts account_proofs
// Params:
// - accounts: the accounts to verify.
// - accounts_len: the number of accounts to verify.
// - pow2_array: the array of powers of 2.
func verify_n_accounts{
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
    headers: Header*,
    header_dict: DictAccess*,
    account_dict: DictAccess*,
    pow2_array: felt*,
}(accounts: Account*, accounts_len: felt, account_values: AccountValues*, account_value_idx: felt) {
    alloc_locals;
    if (accounts_len == 0) {
        return ();
    }

    let account_idx = accounts_len - 1;

    let account_value_idx = verify_account(
        account=accounts[account_idx],
        account_values=account_values,
        account_value_idx=account_value_idx,
        proof_idx=0,
    );

    return verify_n_accounts(
        accounts=accounts,
        accounts_len=accounts_len - 1,
        account_values=account_values,
        account_value_idx=account_value_idx,
    );
}

// Verifies the validity of an account's account_proofs
// Params:
// - account: the account to verify.
// - proof_idx: the index of the proof to verify.
// - pow2_array: the array of powers of 2.
func verify_account{
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
    headers: Header*,
    header_dict: DictAccess*,
    account_dict: DictAccess*,
    pow2_array: felt*,
}(
    account: Account, account_values: AccountValues*, account_value_idx: felt, proof_idx: felt
) -> felt {
    alloc_locals;
    if (proof_idx == account.proofs_len) {
        return account_value_idx;
    }

    let account_proof = account.proofs[proof_idx];

    // get state_root from verified headers
    let header = HeaderMemorizer.get(account_proof.block_number);
    let state_root = HeaderDecoder.get_field(header.rlp, HeaderField.STATE_ROOT);

    let (value: felt*, value_len: felt) = verify_mpt_proof(
        mpt_proof=account_proof.proof,
        mpt_proof_bytes_len=account_proof.proof_bytes_len,
        mpt_proof_len=account_proof.proof_len,
        key_little=account.key,
        n_nibbles_already_checked=0,
        node_index=0,
        hash_to_assert=state_root,
        pow2_array=pow2_array,
    );

    // write verified account state
    assert account_values[account_value_idx] = AccountValues(values=value, values_len=value_len);

    // add account to memorizer
    AccountMemorizer.add(account.address, account_proof.block_number, account_value_idx);

    return verify_account(
        account=account,
        account_values=account_values,
        account_value_idx=account_value_idx + 1,
        proof_idx=proof_idx + 1,
    );
}
