
//Final Encrypt
use std::time::Instant;
fn count_characters(s: &str) -> usize {
    s.chars().count()
}
fn time_taken_by_the_function<F, R, Args>(function_name: &str, function: F, args: Args) -> R
where
    F: FnOnce(Args) -> R,
{
    let t_start = Instant::now();
    let result = function(args);
    let t_end = Instant::now();
    let time_duration = t_end - t_start;
    println!(
        "Executing the '{}' took {} microseconds",
        function_name,
        time_duration.as_micros()
    );
    result
}
fn wep_encrypt(plaintext_and_key: (&str, &[u8])) -> String {
    let (plaintext, wep_key) = plaintext_and_key;
    let key_length = wep_key.len();
    let mut ciphertext = String::new();
    for (i, byte) in plaintext.bytes().enumerate() {
        let encrypted_byte = byte ^ wep_key[i % key_length];
        ciphertext.push_str(&format!("{:08b}", encrypted_byte));
    }
    ciphertext
}
fn to_binary(input: &str) -> String {
    let mut binary = String::new();
    for byte in input.bytes() {
        binary.push_str(&format!("{:08b}", byte));
    }
    binary
}
fn main() {
    let plaintext = "we present how to learn regression models on Lie groups\n\
                     we present how to learn regression models on Lie groups\n\
                     order approximation to the geodesic error";
    let characters_count = count_characters(plaintext);
    println!("Number of characters: {}", characters_count);
    let wep_key = vec![0xAA, 0xBB, 0xCC, 0xDD, 0xEE];
    let _duration = time_taken_by_the_function("wep_encrypt", wep_encrypt, (plaintext, &wep_key));
    let ciphertext = wep_encrypt((plaintext, &wep_key));
    println!("Ciphertext (binary): {}", ciphertext);
}


