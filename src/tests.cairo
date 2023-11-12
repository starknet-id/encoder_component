use core::option::OptionTrait;
use core::array::ArrayTrait;
use starknet::testing;
use debug::PrintTrait;

use encoder::main::encoder_component::{EncoderImpl, component_state_for_testing};

#[starknet::contract]
mod DummyContract {
    use starknet::ContractAddress;
    use encoder::main::encoder_component;

    component!(path: encoder_component, storage: encoder_storage, event: EncoderEvent);

    impl EncoderComponent = encoder_component::EncoderImpl<ContractState>;

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
type TestingState = encoder::main::encoder_component::ComponentState<DummyContract::ContractState>;

impl TestingStateDefault of Default<TestingState> {
    fn default() -> TestingState {
        component_state_for_testing()
    }
}

#[test]
#[available_gas(20000000000)]
fn test_encode() {
    let mut encoder_component: TestingState = Default::default();

    let domain = ('iris', '', '');
    let encoded_domain = encoder_component.encode(domain);
    assert(encoded_domain == 999902, 'Error while encoding domain');
}

#[test]
#[available_gas(20000000000)]
fn test_encode_long_domain() {
    let mut encoder_component: TestingState = Default::default();

    let domain = ('aaaaaaaaaaaaaaaa', 'aaaaaaaaaaaaaaa', '');
    let mut encoded_domain = encoder_component.encode(domain);
    encoded_domain.print();
    assert(
        encoded_domain == 9156080926865681083420392471922737802512525426688,
        'Error while encoding domain'
    );

    // 47 a
    let domain = ('aaaaaaaaaaaaaaaa', 'aaaaaaaaaaaaaaaa', 'aaaaaaaaaaaaaaa');
    let encoded_domain = encoder_component.encode(domain);
    assert(
        encoded_domain == 173080112351456268124053801378276551092162672915177425369094246922356523008,
        'Error while encoding domain'
    );

    let domain = ('0123456789012345', '6789001234567890', '1234567890');
    let encoded_domain = encoder_component.encode(domain);
    assert(
        encoded_domain == 1590776337696498851524821521508998826074315224802694556884844578564,
        'Error while encoding domain'
    );
}
