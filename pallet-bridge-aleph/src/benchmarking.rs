#![cfg(feature = "runtime-benchmarks")]

use codec::Encode;
use frame_benchmarking::{benchmarks, whitelisted_caller};
use frame_support::sp_runtime::traits::Header;
use frame_system::RawOrigin;
use sp_runtime::{
	traits::{One, Zero},
	DigestItem,
};

use crate::{
	pallet::{Call, Config, CurrentAuthoritySet, ImportedHeaders, Pallet},
	AlephJustification, BridgedHeader,
};
use bp_aleph_header_chain::{
	aleph_justification::test_utils::{generate_authority_set, generate_justification, Seeds},
	AuthoritySet, ChainWithAleph, ConsensusLog, InitializationData, ALEPH_ENGINE_ID,
};
use bp_runtime::BasicOperatingMode;

const MIN_AUTHORITIES_COUNT: u32 = 4;

fn seed_from_u8(i: u8) -> [u8; 32] {
	let mut seed = [0u8; 32];
	seed[0] = i;
	seed
}

// Note: we assume that we won't have more than 100 authorities in session.
// Otherwise, benchmark will fail.
fn initial_seeds(count: u8) -> Seeds {
	(0..count).map(|i| seed_from_u8(2 * i)).collect()
}

fn seeds_for_authority_change(count: u8) -> Seeds {
	(0..count).map(|i| seed_from_u8(2 * i + 1)).collect()
}

fn prepare_initial_authority_set(count: u8) -> AuthoritySet {
	generate_authority_set(initial_seeds(count))
}

fn prepare_authority_change(count: u8) -> DigestItem {
	DigestItem::Consensus(
		ALEPH_ENGINE_ID,
		ConsensusLog::AlephAuthorityChange(generate_authority_set(seeds_for_authority_change(
			count,
		)))
		.encode(),
	)
}

fn prepare_authority_change_header<T: Config>(new_authorities_count: u8) -> BridgedHeader<T> {
	let mut header: BridgedHeader<T> = bp_test_utils::test_header(One::one());
	header.digest_mut().logs.push(prepare_authority_change(new_authorities_count));
	header
}

fn prepare_initialization_data<T: Config>(
	initial_authorities_count: u8,
) -> InitializationData<BridgedHeader<T>> {
	let header = bp_test_utils::test_header(Zero::zero());
	let authority_list = prepare_initial_authority_set(initial_authorities_count);
	let operating_mode = BasicOperatingMode::Normal;
	InitializationData { header: Box::new(header), authority_list, operating_mode }
}

fn prepare_benchmark<T: Config>(
	initial_authorities_count: u8,
	new_authorities_count: u8,
) -> (BridgedHeader<T>, AlephJustification) {
	let initialization_data = prepare_initialization_data::<T>(initial_authorities_count);
	Pallet::<T>::bootstrap_bridge(initialization_data);
	let header = prepare_authority_change_header::<T>(new_authorities_count);
	let justification = generate_justification(
		&header.hash().clone().encode(),
		&initial_seeds(initial_authorities_count),
	);
	(header, justification)
}

benchmarks! {
	submit_finality_proof {
		let x in MIN_AUTHORITIES_COUNT .. T::BridgedChain::MAX_AUTHORITIES_COUNT;
		let y in MIN_AUTHORITIES_COUNT .. T::BridgedChain::MAX_AUTHORITIES_COUNT;
		let caller: T::AccountId = whitelisted_caller();
		let (header, justification) = prepare_benchmark::<T>(x.try_into().unwrap(), y.try_into().unwrap());
	}: submit_finality_proof(RawOrigin::Signed(caller), header, justification)
	verify {
		let genesis_header: BridgedHeader<T> = bp_test_utils::test_header(Zero::zero());
		let header: BridgedHeader<T> = prepare_authority_change_header::<T>(y.try_into().unwrap());
		let expected_hash = header.hash();

		// We assert that the new header has been imported.
		assert!(<ImportedHeaders<T>>::contains_key(expected_hash));

		// Check that the authority set has been updated.
		assert_eq!(Into::<AuthoritySet>::into(<CurrentAuthoritySet<T>>::get()), generate_authority_set(seeds_for_authority_change(y.try_into().unwrap())));

		// We assert that genesis header has been pruned, so our benchmark
		// checks the heaviest possible computation.
		assert!(!<ImportedHeaders<T>>::contains_key(genesis_header.hash()));
	}

	impl_benchmark_test_suite!(Pallet, crate::mock::new_test_ext(), crate::mock::TestRuntime)
}
