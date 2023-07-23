#include <chrono>
#include <iostream>
#include <vector>
#include <cstdint>

// CUDA kernel to perform decryption on the GPU
__global__ void wep_decrypt_kernel(const char* ciphertext, size_t ciphertext_length, const uint8_t* wep_key, size_t key_length, char* decrypted_text) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = tid; i < ciphertext_length; i += stride) {
        if (ciphertext[i] != ' ') {
            // Convert 8-bit binary representation to an 8-bit integer
            uint8_t encrypted_byte = 0;
            for (int j = 0; j < 8; j++) {
                if (ciphertext[i + j] == '1') {
                    encrypted_byte |= (1 << (7 - j));
                }
            }
            decrypted_text[i] = encrypted_byte ^ wep_key[i / 8 % key_length];
        }
    }
}

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
std::string wep_decrypt(const std::string& ciphertext, const std::vector<uint8_t>& wep_key) {
    std::string plaintext;
    size_t key_length = wep_key.size();
    // Allocate memory on the host
    char* host_decrypted_text = new char[ciphertext.size() + 1];
    // Allocate memory on the device (GPU)
    char* device_ciphertext;
    char* device_decrypted_text;
    uint8_t* device_wep_key;
    size_t ciphertext_size = ciphertext.size();
    cudaMalloc((void**)&device_ciphertext, (ciphertext_size + 1) * sizeof(char));
    cudaMalloc((void**)&device_decrypted_text, (ciphertext_size + 1) * sizeof(char));
    cudaMalloc((void**)&device_wep_key, key_length * sizeof(uint8_t));
    // Copy data from host to device
    cudaMemcpy(device_wep_key, wep_key.data(), key_length * sizeof(uint8_t), cudaMemcpyHostToDevice);
    cudaMemcpy(device_ciphertext, ciphertext.c_str(), (ciphertext_size + 1) * sizeof(char), cudaMemcpyHostToDevice);
    // Launch the kernel on the GPU
    int num_threads_per_block = 256;
    int num_blocks = (ciphertext_size + num_threads_per_block - 1) / num_threads_per_block;
    wep_decrypt_kernel<<<num_blocks, num_threads_per_block>>>(device_ciphertext, ciphertext_size, device_wep_key, key_length, device_decrypted_text);
    // Copy the decrypted text back to the host
    cudaMemcpy(host_decrypted_text, device_decrypted_text, (ciphertext_size + 1) * sizeof(char), cudaMemcpyDeviceToHost);
    host_decrypted_text[ciphertext_size] = '\0';
    // Clean up memory on the device
    cudaFree(device_ciphertext);
    cudaFree(device_decrypted_text);
    cudaFree(device_wep_key);
    // Clean up memory on the host
    plaintext = std::string(host_decrypted_text);
    delete[] host_decrypted_text;
    return plaintext;
}
int main() {
    std::string ciphertext = "11011101 11011110 11101100 10101101 10011100 11001111 11001000 10101001 10110011 10011010 10001010 11010011 10100011 10101010 10111110 11011101 11011110 11101100 10101101 10011100 11001111 11001000 10101001 10110011 10011010 10001010 11010011 10100011 10101010 10111110\n"
    "11011101 11011110 11101100 10101101 10011100 11001111 11001000 10101001 10110011 10011010 10001010 11010011 10100011 10101010 10111110 11011101 11011110 11101100 10101101 10011100 11001111 11001000 10101001 10110011 10011010 10001010 11010011 10100011 10101010 10111110";
    std::vector<uint8_t> wep_key = { 0xAA, 0xBB, 0xCC, 0xDD, 0xEE };
    std::string decrypted_text = wep_decrypt(ciphertext, wep_key);
    int Characters_Count = countCharacters(ciphertext);
    std::cout << "Number of characters: " << Characters_Count << std::endl;
    //std::cout << "Decrypted Text: " << decrypted_text << std::endl;
    auto duration = time_taken_by_the_function<std::chrono::microseconds>("wep_decrypt", wep_decrypt, ciphertext, wep_key);
    return 0;
}
