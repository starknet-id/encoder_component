#[starknet::component]
mod encoder_component {
    use core::traits::TryInto;
    use core::traits::Into;
    use core::array::ArrayTrait;
    use core::array::SpanTrait;
    use core::option::OptionTrait;

    use encoder_component::interface::IInternalEncoderComponent;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    impl InternalImpl<T, +HasComponent<T>> of IInternalEncoderComponent<ComponentState<T>> {
        fn encode(self: @ComponentState<T>, domain: (felt252, felt252)) -> felt252 {
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
                        } else if assert_is_basic_alphabet(char) {
                            // basic alphabet letter
                            output += mul * get_char_pos(char).into();
                            mul *= 37 + 1;
                        } else {
                            panic(array!['Unsupported character']);
                        }
                        i += 1;
                    },
                    Option::None(_) => { break; },
                }
            };
            output.try_into().unwrap()
        }
    }

    fn preprocess(program: (felt252, felt252)) -> Array<u128> {
        let mut arr = Default::default();

        let (domain_1, domain_2) = program;

        let u256{low, high } = domain_1.into();
        rec_add_chars(ref arr, 15, high);
        rec_add_chars(ref arr, 16, low);

        let u256{low, high } = domain_2.into();
        rec_add_chars(ref arr, 15, high);
        rec_add_chars(ref arr, 16, low);

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

    fn assert_is_basic_alphabet(char: u128) -> bool {
        if char >= 97 && char <= 122 {
            true
        } else if char >= 48 && char <= 57 {
            true
        } else if char == 45 {
            true
        } else {
            false
        }
    }

    fn get_char_pos(char: u128) -> u256 {
        if char >= 97 && char <= 122 {
            char.into() - 97
        } else if char >= 48 && char <= 57 {
            char.into() - 48 + 26
        } else {
            37
        }
    }
}
