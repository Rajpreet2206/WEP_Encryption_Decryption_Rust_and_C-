
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
fn wep_decrypt(ciphertext_and_key: (&str, &[u8])) -> String {
    let (ciphertext, wep_key) = ciphertext_and_key;
    let binary_ciphertext = ciphertext.replace(" ", "");
    let mut plaintext = String::new();
    let key_length = wep_key.len();
    for chunk in binary_ciphertext.as_bytes().chunks(8) {
        let byte_str = std::str::from_utf8(chunk).unwrap();
        let encrypted_byte = u8::from_str_radix(byte_str, 2).unwrap();
        let decrypted_byte = encrypted_byte ^ wep_key[plaintext.len() % key_length];
        plaintext.push(decrypted_byte as char);
    }
    plaintext
}
fn main() {
    let ciphertext = "11011101 11011110 11101100 10101101 10011100 11001111 11001000 10101001 10110011 10011010 10001010 11010011 10100011 10101010 11001110 11011110 11010100 11101100 10110001 10001011 11001011 11001001 10100010 11111101 10011100 11001111 11011100 10111110 10111000 10011101 11011001 11010010 10100011 10110011 11001110";
    let wep_key = vec![0xAA, 0xBB, 0xCC, 0xDD, 0xEE];
    let decrypted_text = wep_decrypt((&ciphertext, &wep_key));
    let characters_count = count_characters(&ciphertext);
    println!("Number of characters: {}", characters_count);
    println!("Ciphertext (binary): {}", ciphertext);
    println!("Decrypted Text: {}", decrypted_text);
    let _duration = time_taken_by_the_function("wep_decrypt", wep_decrypt, (&ciphertext, &wep_key));
}

