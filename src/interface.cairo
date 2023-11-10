#[starknet::interface]
trait IEncoder<TComponentState> {
    fn encode(self: @TComponentState, domain: (felt252, felt252)) -> felt252;
}
