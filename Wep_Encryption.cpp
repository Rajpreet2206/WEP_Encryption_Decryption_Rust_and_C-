
#include <iostream>
#include <string>
#include <vector>
#include <cstdint>
#include <iomanip>
#include <bitset>
#include <chrono>
int countCharacters(const std::string& str) {
    return str.size();
}
template<typename Duration, typename Function, typename... Args>
Duration time_taken_by_the_function(const std::string& function_name, Function&& function, Args&&... args) {
    auto Tstart = std::chrono::high_resolution_clock::now();
    std::forward<Function>(function)(std::forward<Args>(args)...);
    auto Tend = std::chrono::high_resolution_clock::now();
    auto time_duration = std::chrono::duration_cast<Duration>(Tend - Tstart);
    std::cout << "Executing the '" << function_name << "' took " << time_duration.count() << " microseconds" << std::endl;
    return time_duration;
}
std::string wep_encrypt(const std::string& plaintext, const std::vector<uint8_t>& wep_key) {
    std::string ciphertext;
    size_t key_length = wep_key.size();
    for (size_t i = 0; i < plaintext.size(); i++) {
        char encrypted_byte = plaintext[i] ^ wep_key[i % key_length];
        ciphertext += encrypted_byte;
    }
    return ciphertext;
}
std::string to_binary(const std::string& input) {
    std::string binary;
    for (const auto& byte : input) {
        binary += std::bitset<8>(byte).to_string();
    }
    return binary;
}
int main() {
    std::string plaintext = "we present how to learn regression models on Lie groups\n"
                            "and apply our formulation to visual object tracking tasks. Many transformations used\n"
                            "order approximation to the geodesic error";
    int Characters_Count =  countCharacters(plaintext);
    std::cout << "Number of characters: " << Characters_Count << std::endl;
    std::vector<uint8_t> wep_key = { 0xAA, 0xBB, 0xCC, 0xDD, 0xEE };
    auto duration = time_taken_by_the_function<std::chrono::microseconds>("wep_encrypt", wep_encrypt, plaintext, wep_key);
    std::string ciphertext = wep_encrypt(plaintext, wep_key);
    return 0;
}
