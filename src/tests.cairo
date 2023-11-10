use core::option::OptionTrait;
use core::array::ArrayTrait;
use starknet::testing;
use debug::PrintTrait;

use encoder_component::main::encoder_component::{InternalImpl, component_state_for_testing};

#[starknet::contract]
mod DummyContract {
    use starknet::ContractAddress;
    use encoder_component::main::encoder_component;

    component!(path: encoder_component, storage: encoder_storage, event: EncoderEvent);

    impl EncoderComponent = encoder_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        encoder_storage: encoder_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        EncoderEvent: encoder_component::Event
    }
}

type TestingState =
    encoder_component::main::encoder_component::ComponentState<DummyContract::ContractState>;

impl TestingStateDefault of Default<TestingState> {
    fn default() -> TestingState {
        component_state_for_testing()
    }
}


#[test]
#[available_gas(20000000000)]
fn test_encode() {
    // let mut unsafe_state = EncoderImpl::unsafe_new_contract_state();

    // let domain = array!['aaa'].span();
    // let mut encoded_domain = EncoderImpl::encode(@unsafe_state, ('aaa', ''));
    // assert(encoded_domain == 53428, 'Error while encoding domain');

    let mut encoder_component: TestingState = Default::default();

    let domain = ('iris', '');
// let mut encoded_domain = encoder_component.encode(domain);
// assert(encoded_domain == 999902, 'Error while encoding domain');
}
// #[test]
// #[available_gas(20000000000)]
// fn test_encode_domain_too_long() {
//     let mut unsafe_state = EncoderImpl::unsafe_new_contract_state();

//     let domain = array!['iris'].span();
//     let mut encoded_domain = EncoderImpl::encode(@unsafe_state, domain);
//     assert(encoded_domain == 999902, 'Error while encoding domain');
// }


