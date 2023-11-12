#[starknet::interface]
trait IEncoder<TComponentState> {
    fn encode(self: @TComponentState, domain: (u128, u128, u128)) -> felt252;
}
