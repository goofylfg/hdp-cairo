from starkware.cairo.common.uint256 import Uint256

struct HeaderProof {
    leaf_idx: felt,
    mmr_inclusion_proof_len: felt,
    rlp_encoded_header_len: felt,
    mmr_inclusion_proof: felt*, // these dont work
    rlp_encoded_header: felt*,
}

struct AccountProof {
	block: felt,
	// key: Uint256,
	proof_len: felt,
}

struct MMRMeta {
    mmr_id: felt,
    mmr_root: felt, // public (asserted in the output_ptr)
	mmr_size: felt,
	mmr_peaks_len: felt,
	// mmr_peaks: felt*,
}