#include <algorithm>
#include <numeric>
#include <span> 
#include <string>
#include <fstream>
#include <vector>
#include <ranges>
#include <print>
#include <math.h>

int part1(std::span<std::vector<int>> input) {
   return std::transform_reduce(input.cbegin(), input.cend(), 0, std::plus{}, [](std::span<int const> bank) {
      auto left = bank.cbegin();
      auto right = std::prev(bank.cend(), 1);

      auto const max_1 = std::ranges::max_element(left, right);
      auto const max_2 = std::ranges::max_element(std::next(max_1), bank.cend());

      return (10 * *max_1) + *max_2;
   });
}

long part2(std::span<std::vector<int>> input) {
   return std::transform_reduce(input.cbegin(), input.cend(), 0L, std::plus{}, [](std::span<int const> bank) {
      auto left = bank.cbegin();
      auto right = std::prev(bank.cend(), 11);
      auto exponent = 11;
      long number{};

      while (exponent >= 0) {
         auto const max = std::ranges::max_element(left, right);
         number += std::pow(10, exponent--) * *max;
         left = std::next(max);
         right = std::next(right);
      }

      return number;
   });
}

int main() {

   using namespace std::literals;

//    auto input = "987654321111111\n\
// 811111111111119\n\
// 234234234234278\n\
// 818181911112111"sv;


   std::ifstream f{ "input.txt" };
   std::string input{ std::istreambuf_iterator<char>{ f }, std::istreambuf_iterator<char>{} };
   f.close();

   auto v = std::ranges::views::split(input, '\n')
          | std::ranges::views::transform([](auto&& rng) {
               return std::string_view(rng.begin(), rng.end());
            })
          | std::ranges::views::filter([](auto sv) {
            return not sv.empty();
          })
          | std::ranges::views::transform([](std::string_view str) {
               auto ret = std::vector<int>{};
               ret.reserve(str.length());
               for (auto ch : str) {
                  ret.push_back(ch - 48);
               }
               return ret;
            })
            | std::ranges::to<std::vector>();

   auto const sol1 = part1(v);
   auto const sol2 = part2(v);
               
   std::print("Part 1: {0}\n", sol1);
   std::print("Part 2: {0}\n", sol2);

   return 0;
}
