#[starknet::interface]
trait IInternalEncoderComponent<TComponentState> {
    fn encode(self: @TComponentState, domain: (felt252, felt252)) -> felt252;
}
