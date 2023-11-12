#[starknet::component]
mod encoder_component {
    use core::traits::TryInto;
    use core::traits::Into;
    use core::array::ArrayTrait;
    use core::array::SpanTrait;
    use core::option::OptionTrait;

    use encoder::interface::IEncoder;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[embeddable_as(Encoder)]
    impl EncoderImpl<
        TContractState, +HasComponent<TContractState>
    > of IEncoder<ComponentState<TContractState>> {
        fn encode(self: @ComponentState<TContractState>, domain: (u128, u128, u128)) -> felt252 {
            let mut domain_array = preprocess(domain);

            let mut mul = 1;
            let mut output: u256 = 0;
            let mut i = 0;
            let str_size = domain_array.len();

            loop {
                match domain_array.pop_front() {
                    Option::Some(char) => {
                        // if char is a 'a' at the end of the word
                        if i == str_size - 1 && char == 'a' {
                            output += 37 * mul;
                        } else {
                            match get_char_pos(char) {
                                Option::Some(pos) => {
                                    output += mul * pos.into();
                                    mul *= 37 + 1;
                                },
                                Option::None(_) => { panic(array!['Unsupported character']); },
                            }
                        }
                        i += 1;
                    },
                    Option::None(_) => { break; },
                }
            };
            output.try_into().unwrap()
        }
    }

    fn preprocess(program: (u128, u128, u128)) -> Array<u128> {
        let mut arr = Default::default();

        let (domain_1, domain_2, domain_3) = program;

        rec_add_chars(ref arr, 16, domain_1);
        rec_add_chars(ref arr, 16, domain_2);
        rec_add_chars(ref arr, 16, domain_3);

        return arr;
    }

    fn rec_add_chars(ref arr: Array<u128>, str_len: felt252, str: u128) {
        if str_len == 0 {
            return;
        }
        let (str, char) = DivRem::div_rem(str, 256_u128.try_into().unwrap());
        rec_add_chars(ref arr, str_len - 1, str);
        if char != 0 {
            arr.append(char);
        }
    }

    fn get_char_pos(char: u128) -> Option<u256> {
        if char >= 97 && char <= 122 {
            Option::Some(char.into() - 97)
        } else if char >= 48 && char <= 57 {
            Option::Some(char.into() - 48 + 26)
        } else if char == 45 {
            Option::Some(37)
        } else {
            Option::None
        }
    }
}
